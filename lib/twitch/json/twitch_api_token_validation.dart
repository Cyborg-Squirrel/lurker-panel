import 'package:json_annotation/json_annotation.dart';

part 'twitch_api_token_validation.g.dart';

@JsonSerializable()
class TwitchApiTokenValidation {
  TwitchApiTokenValidation(
      this.clientId, this.login, this.scopes, this.userId, this.expiresIn);

  factory TwitchApiTokenValidation.fromJson(Map<String, dynamic> json) =>
      _$TwitchApiTokenValidationFromJson(json);

  Map<String, dynamic> toJson() => _$TwitchApiTokenValidationToJson(this);

  @JsonKey(name: 'client_id')
  final String clientId;

  final String? login;

  final List<String>? scopes;

  @JsonKey(name: 'user_id')
  final String? userId;

  @JsonKey(name: 'expires_in')
  final int expiresIn;
}
