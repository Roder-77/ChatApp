import 'package:json_annotation/json_annotation.dart';
part 'menu.g.dart';

@JsonSerializable()
class Menu {
  Menu({
    required this.menuId,
    required this.menuName,
    required this.icon,
  });

  final String menuId;
  final String menuName;
  final String icon;
  
  factory Menu.fromJson(Map<String, dynamic> json) => _$MenuFromJson(json);
  Map<String, dynamic> toJson() => _$MenuToJson(this);
}
