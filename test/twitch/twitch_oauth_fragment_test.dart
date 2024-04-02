import 'package:flutter_test/flutter_test.dart';
import 'package:lurker_panel/twitch/model/twitch_oauth_fragment.dart';

void main() {
  test('uri decode', () {
    const string =
        'http://localhost:3000/#access_token=abcdefg&scope=&state=MTMw&token_type=bearer';
    final uri = Uri.parse(string);
    final fragment = uri.fragment;
    final fragmentObject = TwitchOauthFragment.fromString(fragment);

    expect(fragmentObject.tokenType, equals('bearer'));
    expect(fragmentObject.state, equals('MTMw'));
    expect(fragmentObject.accessToken, equals('abcdefg'));
  });
}
