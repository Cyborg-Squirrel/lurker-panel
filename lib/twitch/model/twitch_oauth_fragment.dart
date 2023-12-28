class TwitchOauthFragment {
  TwitchOauthFragment({
    required this.accessToken,
    required this.scope,
    required this.state,
    required this.tokenType,
  });

  factory TwitchOauthFragment.fromString(String fragment) {
    final map = _decodeUriFragment(fragment);
    return TwitchOauthFragment(
      accessToken: map['access_token'] ?? '',
      scope: [],
      state: map['state'] ?? '',
      tokenType: map['token_type'] ?? '',
    );
  }

  final String accessToken;
  final List<String> scope;
  final String state;
  final String tokenType;

  static Map<String, String> _decodeUriFragment(String fragment) {
    final fragmentMap = <String, String>{};
    final keyValPairs = fragment.split('&');
    for (var i = 0; i < keyValPairs.length; i++) {
      final keyValPair = keyValPairs[i].split('=');
      fragmentMap[keyValPair.first] = keyValPair.last;
    }

    return fragmentMap;
  }
}
