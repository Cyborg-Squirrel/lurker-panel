// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twitch_mod.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwitchMod _$TwitchModFromJson(Map<String, dynamic> json) => TwitchMod(
      json['user_id'] as String,
      json['user_login'] as String,
      json['user_name'] as String,
    );

Map<String, dynamic> _$TwitchModToJson(TwitchMod instance) => <String, dynamic>{
      'user_id': instance.userId,
      'user_login': instance.userLogin,
      'user_name': instance.username,
    };
