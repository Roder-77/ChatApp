import 'package:json_annotation/json_annotation.dart';
part 'chat_red_envelope_history.g.dart';

@JsonSerializable()
class ChatRedEnvelopeHistory {
  ChatRedEnvelopeHistory({
    required this.redEnvelopeId,
    required this.points,
    required this.memberId,
    required this.updateTime,
    this.name,
    this.imageUrl
  });

  final int redEnvelopeId;
  final int points;
  final String memberId;
  final int updateTime;
  final String? name;
  final String? imageUrl;

  factory ChatRedEnvelopeHistory.fromJson(Map<String, dynamic> json) =>
      _$ChatRedEnvelopeHistoryFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRedEnvelopeHistoryToJson(this);
}
