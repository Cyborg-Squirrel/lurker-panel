import 'package:http/http.dart' as http;

import 'package:lurker_panel/twitch/json/twitch_api_token.dart';

import '../../config/lurker_panel_config.dart';
import '../../di/dependency_manager.dart';
import 'twitch_api.dart';

class TwitchGetModeratorsApi extends TwitchApi {
  TwitchGetModeratorsApi(this.broadcasterId);

  final String broadcasterId;

  @override
  Future<http.Response> execute(TwitchApiToken token) {
    final config = getIt<LurkerPanelConfig>();
    final queryParams = <String, String>{
      'broadcaster_id': broadcasterId,
    };
    final getUsersUri = Uri(
      scheme: 'https',
      host: twitchApiHost,
      path: '/helix/moderation/moderators',
      queryParameters: queryParams,
    );
    final headers = <String, String>{
      'Authorization': 'Bearer ${token.accessToken}',
      'Client-Id': config.clientId,
    };

    return http.get(getUsersUri, headers: headers);
  }
}
