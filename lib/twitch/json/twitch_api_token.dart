import 'package:json_annotation/json_annotation.dart';

part 'twitch_api_token.g.dart';

@JsonSerializable()
class TwitchApiToken {
  TwitchApiToken(this.accessToken, this.expiresIn, this.tokenType, this.scope)
      : receivedAt = DateTime.now();

  factory TwitchApiToken.fromJson(Map<String, dynamic> json) =>
      _$TwitchApiTokenFromJson(json);

  Map<String, dynamic> toJson() => _$TwitchApiTokenToJson(this);

  @JsonKey(includeToJson: false, includeFromJson: false)
  final DateTime receivedAt;

  @JsonKey(name: 'access_token')
  final String accessToken;

  /// Seconds until this token expires
  @JsonKey(name: 'expires_in')
  final int expiresIn;

  @JsonKey(name: 'token_type')
  final String tokenType;

  @JsonKey(name: 'scope')
  final List<String> scope;

  bool isExpired() {
    final now = DateTime.now();
    return receivedAt.add(Duration(seconds: expiresIn)).isBefore(now);
  }
}
