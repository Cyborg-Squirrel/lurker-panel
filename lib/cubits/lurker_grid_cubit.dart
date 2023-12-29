import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lurker_panel/config/lurker_panel_config.dart';
import 'package:lurker_panel/model/lurker_model.dart';
import 'package:lurker_panel/twitch/json/twitch_mod.dart';
import 'package:lurker_panel/twitch/twitch_api_client.dart';
import 'package:twitch_chat/twitch_chat.dart';

import '../di/dependency_manager.dart';
import '../states/lurker_grid_state.dart';

class LurkerGridCubit extends Cubit<LurkerGridState> {
  LurkerGridCubit() : super(LurkerGridState.empty());

  final _lurkCommand = '!lurk';
  final _unlurkCommand = '!unlurk';

  final _twitchApiClient = getIt<TwitchApiClient>();
  StreamSubscription? _chatStreamSub;
  final _lurkerList = <LurkerModel>[];
  final _mods = <TwitchMod>[];
  final _config = getIt<LurkerPanelConfig>();

  void onLoad() async {
    await _listenToChatStream();
    _mods.addAll(await _twitchApiClient.getMods());
  }

  Future<void> _listenToChatStream() async {
    print('Listening to Twitch chat...');
    final stream = await _twitchApiClient.getChatStream();
    await _chatStreamSub?.cancel();
    _chatStreamSub = stream.listen(_onChatMessage, onError: (e) {
      print('Error in Twitch chat stream');
      print(e.toString());
    });
  }

  void _onChatMessage(dynamic message) async {
    if (message is ChatMessage) {
      print('Chat message received');
      print('${_lurkerList.length} lurkers');

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

      if (message.message.startsWith(_lurkCommand)) {
        print('${message.username} is now lurking');
        final userModel = await _twitchApiClient.getUser(message.username);
        model = LurkerModel(
          profileImageUrl: userModel.profileImageUrl,
          name: userModel.displayName,
          lurkingStartedAt: DateTime.now(),
          chatsSinceLurk: 0,
        );
      } else if (message.message.startsWith(_unlurkCommand)) {
        print('${message.username} used the unlurk command');
        final userInModList =
            _mods.where((m) => m.username == message.username);
        final messageString = message.message;

        if ((userInModList.isNotEmpty ||
                message.username == _config.channel.toLowerCase()) &&
            messageString.length > _unlurkCommand.length) {
          final unlurkUserString = messageString.split(' ').last.trim();
          if (unlurkUserString.isNotEmpty) {
            print('${message.username} unlurked $unlurkUserString');
            _lurkerList.removeWhere(
                (l) => l.name.toLowerCase() == unlurkUserString.toLowerCase());
            emit(LurkerGridState(lurkerList: _lurkerList));
            return;
          }
        }

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

  void unlurk(LurkerModel lurkerModel) {
    _lurkerList.remove(lurkerModel);
    emit(LurkerGridState(lurkerList: _lurkerList));
  }
}
