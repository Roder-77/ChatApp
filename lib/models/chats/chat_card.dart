import 'package:json_annotation/json_annotation.dart';
import 'package:chat/generated/l10n.dart';
import 'package:chat/models/chats/chat_message.dart';
part 'chat_card.g.dart';

@JsonSerializable()
class ChatCard {
  ChatCard({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.groupType,
    required this.groupId,
    required this.message,
    required this.type,
    required this.unread,
    required this.time,
    required this.lastestMessageId,
  });

  final int id;
  final String imageUrl;
  final String name;
  final int groupType;
  final String? groupId;
  final String? message;
  final int? type;
  final int unread;
  final int? time;
  final int lastestMessageId;

  String get displayMessage {
    if (type == null) return '';

    switch (ChatType.values[type!]) {
      case ChatType.text:
        return message!;
      case ChatType.sticker:
        return S.current.sticker;
      case ChatType.redEnvelope:
        return S.current.red_envelope;
      case ChatType.image:
        return S.current.picture;
      case ChatType.file:
        return S.current.file;
    }
  }

  factory ChatCard.fromJson(Map<String, dynamic> json) =>
      _$ChatCardFromJson(json);
  Map<String, dynamic> toJson() => _$ChatCardToJson(this);
}
