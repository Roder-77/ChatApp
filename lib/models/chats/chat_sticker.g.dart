// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_sticker.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSticker _$ChatStickerFromJson(Map<String, dynamic> json) => ChatSticker(
      id: json['id'] as int? ?? 0,
      groupId: json['groupId'] as int? ?? 0,
      imagePath: json['imagePath'] as String? ?? '',
    );

Map<String, dynamic> _$ChatStickerToJson(ChatSticker instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'imagePath': instance.imagePath,
    };
