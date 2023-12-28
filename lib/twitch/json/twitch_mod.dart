import 'package:json_annotation/json_annotation.dart';

part 'twitch_mod.g.dart';

@JsonSerializable()
class TwitchMod {
  TwitchMod(this.userId, this.userLogin, this.username);

  factory TwitchMod.fromJson(Map<String, dynamic> json) =>
      _$TwitchModFromJson(json);

  Map<String, dynamic> toJson() => _$TwitchModToJson(this);

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'user_login')
  final String userLogin;

  @JsonKey(name: 'user_name')
  final String username;
}
