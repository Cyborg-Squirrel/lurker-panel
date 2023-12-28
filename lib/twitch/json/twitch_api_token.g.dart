// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twitch_api_token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwitchApiToken _$TwitchApiTokenFromJson(Map<String, dynamic> json) =>
    TwitchApiToken(
      json['access_token'] as String,
      json['expires_in'] as int,
      json['token_type'] as String,
      (json['scope'] as List<dynamic>).map((e) => e as String).toList(),
    );

Map<String, dynamic> _$TwitchApiTokenToJson(TwitchApiToken instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'expires_in': instance.expiresIn,
      'token_type': instance.tokenType,
      'scope': instance.scope,
    };
