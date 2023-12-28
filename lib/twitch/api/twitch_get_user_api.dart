import 'package:http/http.dart' as http;
import 'package:lurker_panel/config/lurker_panel_config.dart';
import 'package:lurker_panel/twitch/api/twitch_api.dart';
import 'package:lurker_panel/twitch/json/twitch_api_token.dart';

import '../../di/dependency_manager.dart';

class TwitchGetUserApi extends TwitchApi {
  TwitchGetUserApi(this.login);

  final String login;

  @override
  Future<http.Response> execute(TwitchApiToken token) {
    final config = getIt<LurkerPanelConfig>();
    final queryParams = <String, String>{
      'login': login,
    };
    final getUsersUri = Uri(
      scheme: 'https',
      host: twitchApiHost,
      path: '/helix/users',
      queryParameters: queryParams,
    );
    final headers = <String, String>{
      'Authorization': 'Bearer ${token.accessToken}',
      'Client-Id': config.clientId,
    };

    return http.get(getUsersUri, headers: headers);
  }
}
