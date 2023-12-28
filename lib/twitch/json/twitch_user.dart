import 'package:json_annotation/json_annotation.dart';

part 'twitch_user.g.dart';

@JsonSerializable()
class TwitchUser {
  TwitchUser(
    this.id,
    this.login,
    this.displayName,
    this.type,
    this.broadcasterType,
    this.description,
    this.profileImageUrl,
    this.offlineImageUrl,
    this.viewCount,
    this.email,
    this.createdAt,
  );

  factory TwitchUser.fromJson(Map<String, dynamic> json) =>
      _$TwitchUserFromJson(json);

  Map<String, dynamic> toJson() => _$TwitchUserToJson(this);

  final String id;

  /// Login name, likely just the lowercase version of displayName
  final String login;

  @JsonKey(name: 'display_name')
  final String displayName;

  /// Not mapped to an enum. Type is Twitch staff/admin/global mod.
  final String type;

  @JsonKey(name: 'broadcaster_type')
  final String broadcasterType;

  /// Channel description
  final String description;

  @JsonKey(name: 'profile_image_url')
  final String profileImageUrl;

  @JsonKey(name: 'offline_image_url')
  final String offlineImageUrl;

  /// Marked as deprecated by Twitch
  @JsonKey(name: 'view_count')
  final int? viewCount;

  final String? email;

  /// RFC3339 formatted timestamp of when the account was created
  @JsonKey(name: 'created_at')
  final String createdAt;

  @JsonKey(includeToJson: false, includeFromJson: false)
  DateTime get createdAtDateTime => DateTime.parse(createdAt);
}
