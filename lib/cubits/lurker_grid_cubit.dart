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

  /// Counter for exponential backoff on reconnections
  int _reconnects = 0;

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
      _resetChat();
    });
  }

  Future<void> _resetChat() async {
    if (_reconnects < 9) {
      _reconnects++;
    }

    await _chatStreamSub?.cancel();
    await Future<void>.delayed(Duration(seconds: 2 ^ _reconnects));
    await _listenToChatStream();
  }

  void _onChatMessage(dynamic message) async {
    if (message is ChatMessage) {
      print('Chat message received');
      print('${_lurkerList.length} lurkers');
      final messageString = message.message.trim();

      if (messageString.startsWith(_lurkCommand)) {
        print('${message.username} is now lurking');
        final userModel = await _twitchApiClient.getUser(message.username);
        final model = LurkerModel(
          profileImageUrl: userModel.profileImageUrl,
          name: userModel.displayName,
          lurkingStartedAt: DateTime.now(),
          chatsSinceLurk: 0,
        );
        _lurkerList.add(model);
        _update();
      } else if (messageString.startsWith(_unlurkCommand)) {
        print('${message.username} used the unlurk command');
        final userInModList =
            _mods.where((m) => m.username == message.username);

        if ((userInModList.isNotEmpty ||
                message.username == _config.channel.toLowerCase()) &&
            messageString.length > _unlurkCommand.length) {
          final unlurkUserString = messageString.split(' ').last.trim();
          if (unlurkUserString.isNotEmpty) {
            print('${message.username} unlurked $unlurkUserString');
            _lurkerList.removeWhere(
                (l) => l.name.toLowerCase() == unlurkUserString.toLowerCase());
            _update();
            return;
          } else {
            return;
          }
        }

        _lurkerList.removeWhere(
            (l) => l.name.toLowerCase() == message.username.toLowerCase());
        _update();
      } else {
        for (var i = 0; i < _lurkerList.length; i++) {
          if (_lurkerList[i].name.toLowerCase() == message.username) {
            _lurkerList[i].incrementChatsSinceLurk();
            _update();
            return;
          }
        }
      }
    }
  }

  void _update() {
    print('${_lurkerList.length} lurkers');
    _lurkerList
        .sort((a, b) => a.lurkingStartedAt.compareTo(b.lurkingStartedAt));
    emit(LurkerGridState(lurkerList: _lurkerList));
  }

  void dispose() {
    _chatStreamSub?.cancel();
  }

  void unlurk(LurkerModel lurkerModel) {
    _lurkerList.remove(lurkerModel);
    emit(LurkerGridState(lurkerList: _lurkerList));
  }
}
