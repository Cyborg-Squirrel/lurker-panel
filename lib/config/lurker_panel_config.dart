import 'package:json_annotation/json_annotation.dart';

part 'lurker_panel_config.g.dart';

@JsonSerializable()
class LurkerPanelConfig {
  LurkerPanelConfig(this.clientId, this.channel, this.username, this.oauthCallbackPort);

  factory LurkerPanelConfig.fromJson(Map<String, dynamic> json) =>
      _$LurkerPanelConfigFromJson(json);

  Map<String, dynamic> toJson() => _$LurkerPanelConfigToJson(this);

  final String clientId;
  final String channel;
  final String username;
  final int oauthCallbackPort;
}
