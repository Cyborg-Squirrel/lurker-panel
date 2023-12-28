import 'package:http/http.dart';
import 'package:lurker_panel/twitch/json/twitch_api_token.dart';

const twitchApiHost = 'api.twitch.tv';
const twitchOauthHost = 'id.twitch.tv';
const twitchOauthPath = '/oauth/twitch';

abstract class TwitchApi {
  Future<Response> execute(TwitchApiToken token);
}
