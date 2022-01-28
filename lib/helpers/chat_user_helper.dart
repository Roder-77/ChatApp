// ignore_for_file: avoid_print

import 'package:chat/helpers/database_helper.dart';
import 'package:chat/models/botton_model.dart';
import 'package:chat/models/users/users_card.dart';

class ChatUserHelper {
  static Future<List<UsersCard>> getUserGroups(ChatListType type) async {
    try {
      final db = await DatabaseHelper.db;
      final groups = await db.rawQuery(
        '''
          SELECT *
          FROM USER_GROUP
          WHERE type = ?
          ORDER BY createTime DESC
        ''',
        [type == ChatListType.myTeachers ? 0 : 1],
      );

      return groups.map((e) => UsersCard.fromJson(e)).toList();
    } catch (ex) {
      print('getUserGroups fail, $ex');
      return [];
    }
  }
}
