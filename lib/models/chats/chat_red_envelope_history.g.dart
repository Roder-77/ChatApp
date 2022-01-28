// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_red_envelope_history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatRedEnvelopeHistory _$ChatRedEnvelopeHistoryFromJson(
        Map<String, dynamic> json) =>
    ChatRedEnvelopeHistory(
      redEnvelopeId: json['redEnvelopeId'] as int,
      points: json['points'] as int,
      memberId: json['memberId'] as String,
      updateTime: json['updateTime'] as int,
      name: json['name'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );

Map<String, dynamic> _$ChatRedEnvelopeHistoryToJson(
        ChatRedEnvelopeHistory instance) =>
    <String, dynamic>{
      'redEnvelopeId': instance.redEnvelopeId,
      'points': instance.points,
      'memberId': instance.memberId,
      'updateTime': instance.updateTime,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
    };
