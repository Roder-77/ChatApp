// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatUser _$ChatUserFromJson(Map<String, dynamic> json) => ChatUser(
      chatroomId: json['chatroomId'] as int,
      memberId: json['memberId'] as String,
      name: json['name'] as String,
      imageUrl: json['imageUrl'] as String,
    );

Map<String, dynamic> _$ChatUserToJson(ChatUser instance) => <String, dynamic>{
      'chatroomId': instance.chatroomId,
      'memberId': instance.memberId,
      'name': instance.name,
      'imageUrl': instance.imageUrl,
    };
