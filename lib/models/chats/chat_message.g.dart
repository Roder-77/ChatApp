// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
      id: json['id'] as int,
      chatroomId: json['chatroomId'] as int,
      message: json['message'] as String,
      type: json['type'] as int,
      memberId: json['memberId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
      createTime: json['createTime'] as int,
      dateRange: json['dateRange'] as String? ?? '',
    );

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatroomId': instance.chatroomId,
      'message': instance.message,
      'type': instance.type,
      'memberId': instance.memberId,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
      'createTime': instance.createTime,
      'dateRange': instance.dateRange,
    };
