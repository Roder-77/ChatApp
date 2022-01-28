// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:chat/models/botton_model.dart';
import 'package:chat/helpers/global_helper.dart';

import 'api_helper.dart';
import 'database_helper.dart';

class DatabaseSyncHelper {
  /// 同步菜單群組
  static Future syncMenuGroups(String appAccessToken) async {
    try {
      final result = await APIHelper.callAPI(
        HttpMethod.get,
        ApiPath.getMenuGroups,
      );

      if (result['status'] != 200) {
        print(result['message']);
        return;
      }

      final db = await DatabaseHelper.db;
      List<dynamic> data = result['data'];

      await db.transaction((txn) async {
        for (var item in data) {
          await txn.execute(
            '''
              REPLACE INTO menu_group
                (id , type, menuId, subMenus)
              VALUES
                (?, ?, ?, ?)
            ''',
            [
              item['id'],
              item['type'],
              item['menuId'],
              jsonEncode(item['subMenus']),
            ],
          );
        }
      });
    } catch (ex) {
      print('syncMenuGroups fail, $ex');
    }
  }

  /// 同步聊天室列表
  static Future syncChatrooms() async {
    try {
      final result = await APIHelper.callAPI(
        HttpMethod.get,
        ApiPath.getMemberChatrooms,
      );

      if (result['status'] != 200) {
        print(result['message']);
        return;
      }

      final db = await DatabaseHelper.db;
      List<dynamic> data = result['data'];

      await db.transaction((txn) async {
        for (var item in data) {
          await txn.execute(
            '''
              REPLACE INTO CHATROOM
                (id , name, imageUrl, groupType, groupId, message, type, time, lastestMessageId, unread)
              VALUES
                (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''',
            [
              item['id'],
              item['name'],
              item['imageUrl'],
              item['groupType'],
              item['groupId'],
              item['message'],
              item['type'],
              item['time'],
              item['lastestMessageId'],
              item['unread'],
            ],
          );
        }
      });
    } catch (ex) {
      print('syncChatrooms fail, $ex');
    }
  }

  /// 同步聊天室成員列表
  static Future syncChatroomUsers(int chatroomId) async {
    try {
      final result = await APIHelper.callAPI(
        HttpMethod.get,
        '${ApiPath.getChatroomUsers}?chatroomId=$chatroomId',
      );

      if (result['status'] != 200) {
        print(result['message']);
        return;
      }

      final db = await DatabaseHelper.db;
      List<dynamic> data = result['data'];

      await db.transaction((txn) async {
        for (var item in data) {
          await txn.execute(
            '''
              REPLACE INTO CHATROOM_USER
                (chatroomId , memberId, name, imageUrl, isDelete)
              VALUES
                (?, ?, ?, ?, ?)
            ''',
            [
              item['chatroomId'],
              item['memberId'],
              item['name'],
              item['imageUrl'],
              item['isDelete'],
            ],
          );
        }
      });
    } catch (ex) {
      print('syncChatroomUsers fail, $ex');
    }
  }

  /// 同步聊天室訊息列表
  static Future syncChatroomMessages(
      int chatroomId, int lastestMessageId) async {
    try {
      final queryString = Uri(queryParameters: {
        'chatroomId': chatroomId.toString(),
        'messageId': lastestMessageId.toString()
      });

      final result = await APIHelper.callAPI(
        HttpMethod.get,
        '${ApiPath.getChatroomMessages}$queryString',
      );

      if (result['status'] != 200) {
        print(result['message']);
        return;
      }

      final db = await DatabaseHelper.db;
      List<dynamic> data = result['data'];

      await db.transaction((txn) async {
        for (var item in data) {
          await txn.execute(
            '''
              REPLACE INTO CHAT_MESSAGE
                (id , chatroomId, message, type, sender, createTime)
              VALUES
                (?, ?, ?, ?, ?, ?)
            ''',
            [
              item['id'],
              item['chatroomId'],
              item['message'],
              item['type'],
              item['sender'],
              item['createTime'],
            ],
          );
        }
      });
    } catch (ex) {
      print('syncChatroomMessages fail, $ex');
    }
  }

  /// 同步聊天室訊息 (收到 FCM 推播時使用)
  static Future syncChatroomMessage(Map<String, dynamic> item) async {
    final db = await DatabaseHelper.db;
    await db.execute(
      '''
        REPLACE INTO CHAT_MESSAGE
          (id , chatroomId, message, type, sender, createTime)
        VALUES
          (?, ?, ?, ?, ?, ?)
      ''',
      [
        item['id'],
        item['chatroomId'],
        item['message'],
        item['type'],
        item['sender'],
        item['createTime'],
      ],
    );
  }

  /// 同步成員群組列表
  static Future syncUserGourps(ChatListType type) async {
    try {
      final apiPath = type == ChatListType.myTeachers
          ? ApiPath.getMemberTeachers
          : ApiPath.getMemberClasses;
      final result = await APIHelper.callAPI(
        HttpMethod.get,
        apiPath,
      );

      if (result['status'] != 200) {
        print(result['message']);
        return;
      }

      final db = await DatabaseHelper.db;
      List<dynamic> data = result['data'];

      await db.transaction((txn) async {
        for (var item in data) {
          await txn.execute(
            '''
              REPLACE INTO USER_GROUP
                (id , groupName, createTime, imageUrl, name, totalPeople, type, groupType)
              VALUES
                (?, ?, ?, ?, ?, ?, ?, ?)
            ''',
            [
              item['id'],
              item['groupName'],
              item['createTime'],
              item['imageUrl'],
              item['name'],
              item['totalPeople'],
              item['type'],
              item['groupType'],
            ],
          );
        }
      });
    } catch (ex) {
      print('syncUserGourps fail, $ex');
    }
  }

  /// 同步聊天貼圖
  static Future syncChatSticker() async {
    try {
      final result = await APIHelper.callAPI(
        HttpMethod.get,
        ApiPath.getChatSticker,
      );

      if (result['status'] != 200) {
        print(result['message']);
        return;
      }

      final db = await DatabaseHelper.db;
      List<dynamic> data = result['data'];

      // 貼圖群組
      await db.transaction((txn) async {
        for (var stickerGroup in data.first['stickerGroups']) {
          await txn.execute(
            '''
              REPLACE INTO CHAT_STICKER_GROUP
                (id, imagePath, [order])
              VALUES
                (?, ?, ?)
            ''',
            [
              stickerGroup['id'],
              stickerGroup['imagePath'],
              stickerGroup['order'],
            ],
          );
        }
      });

      // 貼圖
      await db.transaction((txn) async {
        for (var sticker in data.first['stickers']) {
          await txn.execute(
            '''
              REPLACE INTO CHAT_STICKER
                (id, groupId, imagePath)
              VALUES
                (?, ?, ?)
            ''',
            [
              sticker['id'],
              sticker['groupId'],
              sticker['imagePath'],
            ],
          );
        }
      });
    } catch (ex) {
      print('syncChatSticker fail, $ex');
    }
  }

  /// 同步額外功能
  static Future syncChatExtraFeatures() async {
    try {
      final result = await APIHelper.callAPI(
        HttpMethod.get,
        ApiPath.getExtraFeature,
      );

      if (result['status'] != 200) {
        print(result['message']);
        return;
      }

      final db = await DatabaseHelper.db;
      List<dynamic> data = result['data'];

      await db.transaction((txn) async {
        for (var item in data) {
          await txn.execute(
            '''
              REPLACE INTO CHAT_EXTRA_FEATURE
                (id, type, [order], isDelete)
              VALUES
                (?, ?, ?, ?)
            ''',
            [
              item['id'],
              item['type'],
              item['order'],
              item['isDelete'],
            ],
          );
        }
      });
    } catch (ex) {
      print('syncChatExtraFeatures fail, $ex');
    }
  }

  static Future<Uint8List?> downloadFile(String url) async {
    try {
      http.Client client = http.Client();
      final req = await client.get(Uri.parse(url));
      return req.bodyBytes;
    } catch (ex) {
      // 讀取通用的大頭照
      return null;
    }
  }
}
