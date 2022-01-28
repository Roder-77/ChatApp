import 'package:json_annotation/json_annotation.dart';
part 'chat_user.g.dart';

@JsonSerializable()
class ChatUser {
  ChatUser({
    required this.chatroomId,
    required this.memberId,
    required this.name,
    required this.imageUrl,
  });

  final int chatroomId;
  final String memberId;
  final String name;
  final String imageUrl;

  factory ChatUser.fromJson(Map<String, dynamic> json) =>
      _$ChatUserFromJson(json);

  Map<String, dynamic> toJson() => _$ChatUserToJson(this);
}
