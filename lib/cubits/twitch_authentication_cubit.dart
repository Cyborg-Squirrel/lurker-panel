import 'package:flutter_bloc/flutter_bloc.dart';

import '../di/dependency_manager.dart';
import '../states/twitch_authentication_state.dart';
import '../twitch/twitch_api_client.dart';

class TwitchAuthenticationCubit extends Cubit<TwitchAuthenticationState> {
  TwitchAuthenticationCubit() : super(TwitchAuthenticationInitState());

  final _apiClient = getIt<TwitchApiClient>();
  bool _linkClickedAwaitingTwitchResponse = false;

  void generateOauthLink() {
    final oauthUrl = _apiClient.generateTwitchOAuthUrl();
    emit(TwitchOAuthLinkGeneratedState(oauthUrl));
  }

  void onLinkClicked() {
    if (!_linkClickedAwaitingTwitchResponse) {
      _linkClickedAwaitingTwitchResponse = true;
      _apiClient.twitchOAuthFuture.then((_) {
        _linkClickedAwaitingTwitchResponse = false;
        emit(TwitchOAuthCompleteState());
      }).onError((error, stackTrace) {
        _linkClickedAwaitingTwitchResponse = false;
        emit(TwitchOAuthFailedState(error.toString()));
      });
    }
  }
}
