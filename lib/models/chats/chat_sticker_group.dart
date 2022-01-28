import 'package:json_annotation/json_annotation.dart';
part 'chat_sticker_group.g.dart';

@JsonSerializable()
class ChatStickerGroup {
  ChatStickerGroup({
    required this.id,
    required this.imagePath,
    required this.order,
    this.isSelected = false,
  });

  final int id;
  final String imagePath;
  final int order;
  late bool isSelected;

  factory ChatStickerGroup.fromJson(Map<String, dynamic> json) =>
      _$ChatStickerGroupFromJson(json);
  Map<String, dynamic> toJson() => _$ChatStickerGroupToJson(this);
}
