import 'package:json_annotation/json_annotation.dart';
part 'chat_sticker.g.dart';

@JsonSerializable()
class ChatSticker {
  ChatSticker({
    this.id = 0,
    this.groupId = 0,
    this.imagePath = '',
  });

  final int id;
  final int groupId;
  final String imagePath;

  factory ChatSticker.fromJson(Map<String, dynamic> json) =>
      _$ChatStickerFromJson(json);
  Map<String, dynamic> toJson() => _$ChatStickerToJson(this);
}
