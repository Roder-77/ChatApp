// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatCard _$ChatCardFromJson(Map<String, dynamic> json) => ChatCard(
      id: json['id'] as int,
      imageUrl: json['imageUrl'] as String,
      name: json['name'] as String,
      groupType: json['groupType'] as int,
      groupId: json['groupId'] as String?,
      message: json['message'] as String?,
      type: json['type'] as int?,
      unread: json['unread'] as int,
      time: json['time'] as int?,
      lastestMessageId: json['lastestMessageId'] as int,
    );

Map<String, dynamic> _$ChatCardToJson(ChatCard instance) => <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'name': instance.name,
      'groupType': instance.groupType,
      'groupId': instance.groupId,
      'message': instance.message,
      'type': instance.type,
      'unread': instance.unread,
      'time': instance.time,
      'lastestMessageId': instance.lastestMessageId,
    };
