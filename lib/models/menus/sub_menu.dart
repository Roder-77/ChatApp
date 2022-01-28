import 'package:json_annotation/json_annotation.dart';
part 'sub_menu.g.dart';

@JsonSerializable()
class SubMenu {
  SubMenu({
    this.id = '',
    this.type = '',
    this.jsonData = '',
  });

  final String id;
  final String type;
  final String jsonData;
  
  factory SubMenu.fromJson(Map<String, dynamic> json) => _$SubMenuFromJson(json);
  Map<String, dynamic> toJson() => _$SubMenuToJson(this);
}
