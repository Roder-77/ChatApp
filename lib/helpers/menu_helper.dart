// ignore_for_file: avoid_print

import 'package:chat/helpers/database_helper.dart';
import 'package:chat/models/menus/menu.dart';
import 'package:chat/models/menus/menu_group.dart';

class MenuHelper {
  /// 取得菜單列表
  static Future<List<Menu>> getMenus() async {
    try {
      final db = await DatabaseHelper.db;

      final menus = await db.rawQuery(
        '''
          SELECT *
          FROM default_menus
          ORDER BY gorder
        ''',
      );

      return menus.map((e) => Menu.fromJson(e)).toList();
    } catch (ex) {
      print('getMenus fail, $ex');
      return [];
    }
  }

  /// 取得菜單群組列表
  static Future<List<MenuGroup>> getMenuGroups(String menuId) async {
    try {
      final db = await DatabaseHelper.db;
      final menuGroups = await db.rawQuery(
        '''
          SELECT * FROM menu_group
          WHERE menuId = ?
        ''',
        [menuId],
      );

      return menuGroups.map((e) => MenuGroup.fromJson(e)).toList();
    } catch (ex) {
      print('getMenuGroups fail, $ex');
      return [];
    }
  }
}
