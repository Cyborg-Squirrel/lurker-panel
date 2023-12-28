import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurker_panel/model/lurker_model.dart';
import 'package:lurker_panel/twitch/twitch_api_client.dart';
import 'package:twitch_chat/twitch_chat.dart';

import '../di/dependency_manager.dart';
import '../states/lurker_grid_state.dart';

class LurkerGridCubit extends Cubit<LurkerGridState> {
  LurkerGridCubit() : super(LurkerGridState.empty());

  final _twitchApiClient = getIt<TwitchApiClient>();
  StreamSubscription? _chatStreamSub;
  final _lurkerList = <LurkerModel>[];

  void onLoad() async {
    final stream = await _twitchApiClient.getChatStream();
    _chatStreamSub = stream.listen(_onChatMessage);
  }

  void _onChatMessage(dynamic message) async {
    if (message is ChatMessage) {
      final lurkerInList = _lurkerList
          .where((l) => l.name.toLowerCase() == message.username.toLowerCase());
      LurkerModel? model;
      if (lurkerInList.isNotEmpty) {
        final lurkerModel = lurkerInList.first;
        model = LurkerModel(
          profileImageUrl: lurkerModel.profileImageUrl,
          name: message.username,
          lurkingStartedAt: lurkerModel.lurkingStartedAt,
          chatsSinceLurk: lurkerModel.chatsSinceLurk + 1,
        );
        _lurkerList.removeWhere(
            (l) => l.name.toLowerCase() == message.username.toLowerCase());
      }

      if (message.message.startsWith('!lurk')) {
        final userModel = await _twitchApiClient.getUser(message.username);
        model = LurkerModel(
          profileImageUrl: userModel.profileImageUrl,
          name: userModel.displayName,
          lurkingStartedAt: DateTime.now(),
          chatsSinceLurk: 0,
        );
      } else if (message.message.startsWith('!unlurk')) {
        _lurkerList.removeWhere(
            (l) => l.name.toLowerCase() == message.username.toLowerCase());
        emit(LurkerGridState(lurkerList: _lurkerList));
        return;
      }

      if (model != null) {
        _lurkerList.add(model);
        _lurkerList
            .sort((a, b) => a.lurkingStartedAt.compareTo(b.lurkingStartedAt));
        emit(LurkerGridState(lurkerList: _lurkerList));
      }
    }
  }

  void onScreenResized(Size newSize) {
    // TODO: implement onScreenResized
  }

  void dispose() {
    _chatStreamSub?.cancel();
  }
}
