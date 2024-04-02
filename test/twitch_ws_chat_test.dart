import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lurker_panel/twitch/twitch_api_client.dart';
import 'package:twitch_chat/twitch_chat.dart';

void main() {
  test('Twitch api test', () async {
    WidgetsFlutterBinding.ensureInitialized();
    final client = TwitchApiClientImpl();
    await client.init();
    await Future<void>.delayed(const Duration(seconds: 10));
    final user = await client.getUser('razorcrab');
    final userJson = jsonEncode(user.toJson());
    print(userJson);
  });

  test('TwitchChat test', () async {
    final chat = TwitchChat.anonymous('femaleunix');
    chat.connect();
    await Future<void>.delayed(const Duration(seconds: 2));
    final isConnected = chat.isConnected.value;
    print('isConnected $isConnected');
    final sub = chat.chatStream.listen((event) {
      print(event);
    });

    await Future<void>.delayed(const Duration(seconds: 10));
    await sub.cancel();
  });

  test('WebSocket test', () async {
    final webSocket =
        await WebSocket.connect('wss://irc-ws.chat.twitch.tv:443');
    print('Websocket connected');
    final wsStreamSub = webSocket.listen((event) {
      print(event);
    });

    webSocket.add('PASS SCHMOOPIIE');
    webSocket.add('NICK justinfan23418');
    webSocket.add('USER justinfan23418 8 * :justinfan23418');
    webSocket.add('JOIN #hasanabi');

    await Future<void>.delayed(const Duration(seconds: 10));
    print('Closing');
    await wsStreamSub.cancel();
    webSocket.close();
  });
}
