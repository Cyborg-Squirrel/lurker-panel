import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:lurker_panel/config/lurker_panel_config.dart';
import 'package:lurker_panel/cubits/lurker_grid_cubit.dart';
import 'package:lurker_panel/cubits/twitch_authentication_cubit.dart';
import 'package:lurker_panel/twitch/twitch_api_client.dart';

final getIt = GetIt.asNewInstance();

class DependencyManager {
  Future<void> configure() async {
    await registerConfig();
    getIt.registerSingleton<TwitchApiClient>(TwitchApiClientImpl());
    getIt.registerSingleton<LurkerGridCubit>(LurkerGridCubit());
    getIt.registerSingleton<TwitchAuthenticationCubit>(
        TwitchAuthenticationCubit());
  }

  Future<void> registerConfig() async {
    final configString = await rootBundle.loadString('assets/config.json');
    final configJsonMap = jsonDecode(configString);
    final config = LurkerPanelConfig.fromJson(configJsonMap);
    getIt.registerSingleton<LurkerPanelConfig>(config);
  }
}
