// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'twitch_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TwitchUser _$TwitchUserFromJson(Map<String, dynamic> json) => TwitchUser(
      json['id'] as String,
      json['login'] as String,
      json['display_name'] as String,
      json['type'] as String,
      json['broadcaster_type'] as String,
      json['description'] as String,
      json['profile_image_url'] as String,
      json['offline_image_url'] as String,
      json['view_count'] as int?,
      json['email'] as String?,
      json['created_at'] as String,
    );

Map<String, dynamic> _$TwitchUserToJson(TwitchUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'login': instance.login,
      'display_name': instance.displayName,
      'type': instance.type,
      'broadcaster_type': instance.broadcasterType,
      'description': instance.description,
      'profile_image_url': instance.profileImageUrl,
      'offline_image_url': instance.offlineImageUrl,
      'view_count': instance.viewCount,
      'email': instance.email,
      'created_at': instance.createdAt,
    };
