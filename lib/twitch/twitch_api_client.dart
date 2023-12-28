import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:lurker_panel/config/lurker_panel_config.dart';
import 'package:lurker_panel/twitch/api/twitch_get_user_api.dart';
import 'package:lurker_panel/twitch/api/twitch_oauth_token_validation_api.dart';
import 'package:lurker_panel/twitch/json/twitch_api_token.dart';
import 'package:lurker_panel/twitch/json/twitch_api_token_validation.dart';
import 'package:lurker_panel/twitch/model/twitch_oauth_fragment.dart';
import 'package:twitch_chat/twitch_chat.dart';

import '../di/dependency_manager.dart';
import 'api/twitch_api.dart';
import 'json/twitch_user.dart';
import 'package:http/http.dart' as http;

abstract class TwitchApiClient {
  Future get twitchOAuthFuture;

  Future<void> init();

  String generateTwitchOAuthUrl();

  Future<TwitchUser> getUser(String login);

  Future<Stream<dynamic>> getChatStream();
}

class TwitchApiClientImpl extends TwitchApiClient {
  final _clientId = getIt<LurkerPanelConfig>().clientId;
  TwitchApiToken? _token;

  final _requiredScopes = ['chat:read'];

  /// Http server to listen for the OAuth callback
  HttpServer? _httpServer;
  final _address =
      'http://localhost:${getIt<LurkerPanelConfig>().oauthCallbackPort}';
  final _port = getIt<LurkerPanelConfig>().oauthCallbackPort;

  /// State string to send and receive from Twitch in OAuth flow
  String? _state;

  late Completer _twitchOAuthCompleter;

  @override
  Future get twitchOAuthFuture => _twitchOAuthCompleter.future;

  TwitchChat? _twitchChat;

  @override
  Future<void> init() async {
    print('Initializing the Twitch api client...');

    await _httpServer?.close();
    _twitchChat?.close();
    _twitchOAuthCompleter = Completer.sync();
    _httpServer = await HttpServer.bind(InternetAddress.anyIPv4, _port);
    _httpServer!.listen(_onHttpRequestReceived);
  }

  @override
  String generateTwitchOAuthUrl() {
    final randomIntA = Random().nextInt(2 ^ 32);
    final randomIntB = Random().nextInt(2 ^ 32);
    final randomIntC = Random().nextInt(2 ^ 32);
    final randomIntD = Random().nextInt(2 ^ 32);
    final encodedRandom = String.fromCharCodes(
        '$randomIntA$randomIntB$randomIntC$randomIntD'.codeUnits);
    _state = encodedRandom;

    final queryParams = <String, String>{
      'client_id': _clientId,
      'redirect_uri': _address,
      'response_type': 'token',
      'scope': _getScopesString(),
      'state': _state!,
    };
    final oauthUri = Uri(
      scheme: 'https',
      host: twitchOauthHost,
      path: '/oauth2/authorize',
      queryParameters: queryParams,
    );

    return oauthUri.toString();
  }

  bool _handleTokenValidationResponse(
      http.Response response, String accessToken, String tokenType) {
    if (response.statusCode > 199 && response.statusCode < 300) {
      print('Got a token validation response from Twitch!');
      final responseJson = jsonDecode(response.body);
      print('response json: $responseJson');
      final validation = TwitchApiTokenValidation.fromJson(responseJson);
      _token = TwitchApiToken(
        accessToken,
        validation.expiresIn,
        tokenType,
        validation.scopes ?? [],
      );
      return true;
    } else {
      print('Error ${response.statusCode} validating token ${response.body}');
      return false;
    }
  }

  Future<bool> _validateTokenFromFragment(TwitchOauthFragment fragment) async {
    print('Validating token with Twitch OAuth fragment...');
    final response =
        await TwitchOAuthTokenValidationApi().executeWithFragment(fragment);
    return _handleTokenValidationResponse(
      response,
      fragment.accessToken,
      fragment.tokenType,
    );
  }

  Future<bool> _validateToken() async {
    print('Validating token with Twitch...');
    if (_token == null) {
      /// No fragment from OAuth flow or _token
      return false;
    } else if (_token?.isExpired() == true) {
      /// Token is past expiration
      return false;
    }

    final response = await TwitchOAuthTokenValidationApi().execute(_token!);
    return _handleTokenValidationResponse(
      response,
      _token!.accessToken,
      _token!.tokenType,
    );
  }

  @override
  Future<TwitchUser> getUser(String login) async {
    final tokenIsValid = await _validateToken();
    if (!tokenIsValid) {
      print('Token is invalid');
      throw Exception('Invalid token. Unable to make Twitch api request.');
    }

    final getUserApi = TwitchGetUserApi(login);
    final response = await getUserApi.execute(_token!);

    if (response.statusCode > 199 && response.statusCode < 300) {
      print('Got user from Twitch!');
      final responseJson = jsonDecode(response.body);
      final userData = responseJson['data'].first;
      return TwitchUser.fromJson(userData);
    } else if (response.statusCode == 503) {
      /// TODO we can retry once if we get a status code 503
    }

    print(
        'Error ${response.statusCode} requesting user from Twitch ${response.body}');
    throw Exception('Unable to get user');
  }

  void _onHttpRequestReceived(HttpRequest request) async {
    final uri = request.uri;

    if (uri.path == twitchOauthPath) {
      print('Received forwarded OAuth');
      final completer = Completer.sync();
      Uint8List bodyBytes = Uint8List(request.contentLength);
      int receivedBytes = 0;
      request.listen((bytes) {
        for (var i = 0; i < bytes.length; i++) {
          bodyBytes[receivedBytes] = bytes[i];
          receivedBytes++;
        }

        if (bodyBytes.length == request.contentLength) {
          completer.complete();
        }
      });

      await completer.future
          .timeout(const Duration(seconds: 3), onTimeout: () {});

      /// Respond to the request with an empty ok response
      request.response
        ..statusCode = HttpStatus.ok
        ..close();

      if (bodyBytes.isEmpty) {
        /// Timed out waiting for the Twitch OAuth forward
        _twitchOAuthCompleter.completeError(
            Exception('Timed out waiting for Twitch OAuth forward.'));
        return;
      }

      final bodyString = String.fromCharCodes(bodyBytes);
      final uri = Uri.parse(bodyString);

      if (uri.hasFragment) {
        /// OAuth success
        final fragment = TwitchOauthFragment.fromString(uri.fragment);
        if (fragment.state != _state) {
          /// Bad state, potential spoofing attack
          _twitchOAuthCompleter
              .completeError(Exception('Error in Twitch OAuth response.'));
          return;
        }
        if (fragment.accessToken.isEmpty) {
          /// No access token
          _twitchOAuthCompleter
              .completeError(Exception('Missing access token.'));
          return;
        }

        final isValid = await _validateTokenFromFragment(fragment);
        if (isValid) {
          _twitchOAuthCompleter.complete();
          await _httpServer?.close(force: true);
        } else {
          _twitchOAuthCompleter
              .completeError(Exception('Token was generated but invalid.'));
          return;
        }
      } else {
        /// OAuth error
        _twitchOAuthCompleter
            .completeError(Exception('Error during OAuth flow.'));
        return;
      }
    } else if (uri.path == '/myicon.png') {
      print('Responding to request for favicon');
      final iconByteData = await rootBundle.load('assets/web/myicon.png');
      final iconData = iconByteData.buffer.asUint8List();
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.parse('image/png')
        ..headers.contentLength = iconData.length
        ..add(iconData)
        ..close();
    } else if (uri.path == '/forwarding-script.js') {
      print('Responding to request for javascript');
      final javascriptString =
          await rootBundle.loadString('assets/web/forwarding-script.js');
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.parse('application/javascript')
        ..write(javascriptString)
        ..close();
    } else if (uri.path == '/' || uri.path.isEmpty) {
      print('Responding with Twitch OAuth forward page');
      final responsePage =
          await rootBundle.loadString('assets/web/oauth-forwarding.html');
      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write(responsePage)
        ..close();
    }
  }

  String _getScopesString() {
    if (_requiredScopes.isEmpty) {
      return '';
    } else if (_requiredScopes.length < 2) {
      return _requiredScopes.first;
    } else {
      String scopesString = '';
      for (var i = 0; i < _requiredScopes.length; i++) {
        scopesString += '${_requiredScopes[i]} ';
      }

      return scopesString.trim();
    }
  }

  @override
  Future<Stream<dynamic>> getChatStream() async {
    final tokenIsValid = await _validateToken();
    if (!tokenIsValid) {
      print('Token is invalid');
      throw Exception('Invalid token. Unable to make Twitch api request.');
    }

    final config = getIt<LurkerPanelConfig>();
    final connectionCompleter = Completer.sync();
    _twitchChat ??= TwitchChat(config.channel, config.username, _token!.accessToken, onConnected: () {
      if (!connectionCompleter.isCompleted) {
        connectionCompleter.complete();
      }
    });
    _twitchChat?.connect();

    await connectionCompleter.future;
    return _twitchChat!.chatStream;
  }
}
