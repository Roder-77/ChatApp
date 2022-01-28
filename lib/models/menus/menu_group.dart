import 'dart:convert';

import 'package:chat/models/menus/sub_menu.dart';

class MenuGroup {
  MenuGroup({
    required this.id,
    required this.type,
    required this.menuId,
    required this.subMenus,
  });

  final String id;
  final String type;
  final String menuId;
  final List<SubMenu> subMenus;

  factory MenuGroup.fromJson(Map<String, dynamic> json) => MenuGroup(
        id: json['id'] as String,
        type: json['type'] as String,
        menuId: json['menuId'] as String,
        subMenus: (jsonDecode(json['subMenus']) as List<dynamic>)
            .map((e) => SubMenu.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
