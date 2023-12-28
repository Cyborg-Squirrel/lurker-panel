// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twitch_api_token_validation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwitchApiTokenValidation _$TwitchApiTokenValidationFromJson(
        Map<String, dynamic> json) =>
    TwitchApiTokenValidation(
      json['client_id'] as String,
      json['login'] as String?,
      (json['scopes'] as List<dynamic>?)?.map((e) => e as String).toList(),
      json['user_id'] as String?,
      json['expires_in'] as int,
    );

Map<String, dynamic> _$TwitchApiTokenValidationToJson(
        TwitchApiTokenValidation instance) =>
    <String, dynamic>{
      'client_id': instance.clientId,
      'login': instance.login,
      'scopes': instance.scopes,
      'user_id': instance.userId,
      'expires_in': instance.expiresIn,
    };
