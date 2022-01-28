import 'package:json_annotation/json_annotation.dart';
part 'users_card.g.dart';

@JsonSerializable()
class UsersCard {
  UsersCard({
    required this.id,
    required this.imageUrl,
    required this.name,
    required this.createTime,
    required this.groupName,
    this.totalPeople = 0,
    required this.type,
    required this.groupType,
    this.yearRange = '',
  });

  final String id;
  final String imageUrl;
  final String name;
  final DateTime createTime;
  final String groupName;
  final int totalPeople;
  final int type;
  final int groupType;
  late String yearRange;

  factory UsersCard.fromJson(Map<String, dynamic> json) => _$UsersCardFromJson(json);
  Map<String, dynamic> toJson() => _$UsersCardToJson(this);
}