// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lurker_panel_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LurkerPanelConfig _$LurkerPanelConfigFromJson(Map<String, dynamic> json) =>
    LurkerPanelConfig(
      json['clientId'] as String,
      json['channel'] as String,
      json['username'] as String,
      json['oauthCallbackPort'] as int,
    );

Map<String, dynamic> _$LurkerPanelConfigToJson(LurkerPanelConfig instance) =>
    <String, dynamic>{
      'clientId': instance.clientId,
      'channel': instance.channel,
      'username': instance.username,
      'oauthCallbackPort': instance.oauthCallbackPort,
    };
