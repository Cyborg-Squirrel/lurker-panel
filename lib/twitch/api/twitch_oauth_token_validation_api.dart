import 'package:http/http.dart' as http;
import 'package:lurker_panel/twitch/json/twitch_api_token.dart';

import '../model/twitch_oauth_fragment.dart';
import 'twitch_api.dart';

class TwitchOAuthTokenValidationApi extends TwitchApi {
  @override
  Future<http.Response> execute(TwitchApiToken token) async {
    final authorization = token.accessToken;
    return _getWithAuthorization(authorization);
  }

  Future<http.Response> executeWithFragment(TwitchOauthFragment fragment) {
    final authorization = fragment.accessToken;
    return _getWithAuthorization(authorization);
  }

  Future<http.Response> _getWithAuthorization(String authorization) {
    final headers = <String, String>{
      'Authorization': 'OAuth $authorization',
    };
    final oauthUri = Uri(
      scheme: 'https',
      host: twitchOauthHost,
      path: '/oauth2/validate',
    );

    return http.get(oauthUri, headers: headers);
  }
}
