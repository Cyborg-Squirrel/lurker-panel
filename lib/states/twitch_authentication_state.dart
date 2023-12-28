abstract class TwitchAuthenticationState {}

class TwitchAuthenticationInitState extends TwitchAuthenticationState {}

class TwitchOAuthLinkGeneratedState extends TwitchAuthenticationState {
  TwitchOAuthLinkGeneratedState(this.link);

  final String link;
}

class TwitchOAuthCompleteState extends TwitchAuthenticationState {}

class TwitchOAuthFailedState extends TwitchAuthenticationState {
  TwitchOAuthFailedState(this.errorMessage);

  final String errorMessage;
}
