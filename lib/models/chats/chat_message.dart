import 'package:json_annotation/json_annotation.dart';
part 'chat_message.g.dart';

@JsonSerializable()
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.chatroomId,
    required this.message,
    required this.type,
    required this.memberId,
    required this.name,
    required this.imageUrl,
    required this.createTime,
    this.dateRange = '',
  });

  final int id;
  final int chatroomId;
  final String message;
  final int type;
  final String memberId;
  final String name;
  final String imageUrl;
  final int createTime;
  late String dateRange;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  factory ChatMessage.fromFCMJson(Map<String, dynamic> json) => ChatMessage(
        id: int.parse(json['id']),
        chatroomId: int.parse(json['chatroomId']),
        message: json['message'] as String,
        type: int.parse(json['type']),
        memberId: json['memberId'] as String,
        name: json['name'] as String,
        imageUrl: json['imageUrl'] as String,
        createTime: int.parse(json['createTime']),
        dateRange: json['dateRange'] as String? ?? '',
      );
}

enum ChatType { text, sticker, redEnvelope, image, file }
