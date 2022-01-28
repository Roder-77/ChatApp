// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_sticker_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatStickerGroup _$ChatStickerGroupFromJson(Map<String, dynamic> json) =>
    ChatStickerGroup(
      id: json['id'] as int,
      imagePath: json['imagePath'] as String,
      order: json['order'] as int,
      isSelected: json['isSelected'] as bool? ?? false,
    );

Map<String, dynamic> _$ChatStickerGroupToJson(ChatStickerGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imagePath': instance.imagePath,
      'order': instance.order,
      'isSelected': instance.isSelected,
    };
