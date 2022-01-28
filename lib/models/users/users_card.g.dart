// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users_card.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsersCard _$UsersCardFromJson(Map<String, dynamic> json) => UsersCard(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      name: json['name'] as String,
      createTime: DateTime.parse(json['createTime'] as String),
      groupName: json['groupName'] as String,
      totalPeople: json['totalPeople'] as int? ?? 0,
      type: json['type'] as int,
      groupType: json['groupType'] as int,
      yearRange: json['yearRange'] as String? ?? '',
    );

Map<String, dynamic> _$UsersCardToJson(UsersCard instance) => <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'name': instance.name,
      'createTime': instance.createTime.toIso8601String(),
      'groupName': instance.groupName,
      'totalPeople': instance.totalPeople,
      'type': instance.type,
      'groupType': instance.groupType,
      'yearRange': instance.yearRange,
    };
