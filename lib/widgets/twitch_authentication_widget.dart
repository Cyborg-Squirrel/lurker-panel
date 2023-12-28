import 'package:flutter/material.dart';
import 'package:lurker_panel/cubits/twitch_authentication_cubit.dart';
import 'package:lurker_panel/widgets/lurker_grid_widget.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../di/dependency_manager.dart';
import '../states/twitch_authentication_state.dart';

class TwitchAuthenticationWidget extends StatelessWidget {
  const TwitchAuthenticationWidget({super.key});

  static const route = '/twitch-oauth';

  @override
  Widget build(BuildContext context) {
    const title = 'Authenticate with Twitch';
    final cubit = getIt<TwitchAuthenticationCubit>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text(title),
      ),
      body: StreamBuilder(
        stream: cubit.stream,
        initialData: cubit.state,
        builder: (BuildContext context,
            AsyncSnapshot<TwitchAuthenticationState> snapshot) {
          if (snapshot.hasData) {
            final state = snapshot.data;

            if (state is TwitchAuthenticationInitState) {
              cubit.generateOauthLink();
            } else if (state is TwitchOAuthLinkGeneratedState) {
              return Center(
                child: TextButton(
                  onPressed: () {
                    cubit.onLinkClicked();
                    launchUrlString(state.link);
                  },
                  child: const Text('Go to Twitch'),
                ),
              );
            } else if (state is TwitchOAuthCompleteState) {
              WidgetsBinding.instance.addPostFrameCallback((_) =>
                  Navigator.of(context)
                      .pushReplacementNamed(LurkerGridWidget.route));
              return const Placeholder();
            } else if (state is TwitchOAuthFailedState) {
              return Center(
                child: Column(
                  children: [
                    Text(state.errorMessage),
                    TextButton(
                      onPressed: () {
                        cubit.generateOauthLink();
                      },
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              );
            }
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}
