// ignore_for_file: avoid_print

import 'dart:io';

import 'package:chat/helpers/api_helper.dart';
import 'package:chat/helpers/database_helper.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/models/botton_model.dart';
import 'package:chat/models/chats/chat_card.dart';
import 'package:chat/models/chats/chat_message.dart';
import 'package:chat/models/chats/chat_red_envelope_history.dart';
import 'package:chat/models/chats/chat_sticker.dart';
import 'package:chat/models/chats/chat_sticker_group.dart';
import 'package:chat/models/chats/chat_user.dart';

class ChatHelper {
  /// 取得聊天室列表
  static Future<List<ChatCard>> getChatrooms(ChatListType type) async {
    try {
      final db = await DatabaseHelper.db;
      var typeSql = '';
      switch (type) {
        case ChatListType.users:
        case ChatListType.classes:
          typeSql = 'AND groupType = ${type.index}';
          break;
        case ChatListType.all:
        default:
          break;
      }

      final chatrooms = await db.rawQuery(
        '''
          SELECT * FROM CHATROOM
          WHERE message IS NOT NULL
          $typeSql
          ORDER BY time DESC
        ''',
      );

      return chatrooms.map((e) => ChatCard.fromJson(e)).toList();
    } catch (ex) {
      print('getChatrooms fail, $ex');
      return [];
    }
  }

  /// 取得聊天室資料
  static Future<ChatCard?> getChatroom(int chatroomId) async {
    try {
      final db = await DatabaseHelper.db;
      final chatrooms = await db.rawQuery(
        '''
          SELECT * FROM CHATROOM
          WHERE id = ?
        ''',
        [chatroomId],
      );

      if (chatrooms.isEmpty) return null;
      return ChatCard.fromJson(chatrooms.first);
    } catch (ex) {
      print('getChatrooms fail, $ex');
      return null;
    }
  }

  /// 取得聊天室新訊息列表 (未讀)
  static Future<List<ChatMessage>> getChatroomNewMessages(
      int chatroomId, int messageId) async {
    try {
      final db = await DatabaseHelper.db;
      final chatroomMessages = await db.rawQuery(
        '''
          SELECT CM.id, CM.chatroomId, CM.message, CM.type, CM.createTime, CU.memberId, CU.name, CU.imageUrl
          FROM CHAT_MESSAGE CM
          LEFT JOIN CHATROOM_USER CU ON CU.memberId = CM.sender AND CU.chatroomId = CM.chatroomId
          WHERE CM.chatroomId = ?
          AND CM.id > ?
          ORDER BY id DESC
        ''',
        [chatroomId, messageId],
      );

      return chatroomMessages.map((e) => ChatMessage.fromJson(e)).toList();
    } catch (ex) {
      print('getChatroomNewMessages fail, $ex');
      return [];
    }
  }

  /// 取得聊天室舊訊息列表 (已讀)
  static Future<List<ChatMessage>> getChatroomOldMessages(
      int chatroomId, int messageId,
      [int page = 1, int take = 50]) async {
    try {
      final skip = (page - 1) * take;
      final db = await DatabaseHelper.db;
      final chatroomMessages = await db.rawQuery(
        '''
          SELECT CM.id, CM.chatroomId, CM.message, CM.type, CM.createTime, CU.memberId, CU.name, CU.imageUrl
          FROM CHAT_MESSAGE CM
          LEFT JOIN CHATROOM_USER CU ON CU.memberId = CM.sender AND CU.chatroomId = CM.chatroomId
          WHERE CM.chatroomId = ?
          AND CM.id <= ?
          ORDER BY CM.id DESC
          LIMIT ? OFFSET ?
        ''',
        [chatroomId, messageId, take, skip],
      );

      return chatroomMessages.map((e) => ChatMessage.fromJson(e)).toList();
    } catch (ex) {
      print('getChatroomOldMessages fail, $ex');
      return [];
    }
  }

  /// 取得聊天室訊息
  static Future<ChatMessage?> getChatroomMessage(
      int chatroomId, int messageId) async {
    try {
      final db = await DatabaseHelper.db;
      final chatroomMessages = await db.rawQuery(
        '''
          SELECT CM.id, CM.chatroomId, CM.message, CM.type, CM.createTime, CU.memberId, CU.name, CU.imageUrl
          FROM CHAT_MESSAGE CM
          LEFT JOIN CHATROOM_USER CU ON CU.memberId = CM.sender AND CU.chatroomId = CM.chatroomId
          WHERE CM.chatroomId = ?
          AND CM.id = ?
        ''',
        [chatroomId, messageId],
      );

      if (chatroomMessages.isEmpty) return null;
      return ChatMessage.fromJson(chatroomMessages.first);
    } catch (ex) {
      print('getChatroomMessage fail, $ex');
      return null;
    }
  }

  /// 更新已讀訊息
  static Future<bool> updateReadMessage(int chatroomId, int messageId) async {
    try {
      final body = {
        'chatroomId': chatroomId,
        'messageId': messageId,
      };

      final result = await APIHelper.callAPI(
        HttpMethod.put,
        ApiPath.updateReadMessage,
        content: body,
      );

      if (result['status'] != 200) {
        print(result['message']);
        return true;
      }

      return false;
    } catch (ex) {
      print('updateReadMessage fail $ex');
      return false;
    }
  }

  /// 新增聊天室訊息
  static Future<bool> insertChatroomMessage(int chatroomId, String message,
      [ChatType type = ChatType.text]) async {
    try {
      final body = {
        'chatroomId': chatroomId,
        'message': message,
        'type': type.index
      };

      final result = await APIHelper.callAPI(
        HttpMethod.post,
        ApiPath.insertChatroomMessage,
        content: body,
      );

      if (result['status'] != 200) {
        print(result['message']);
        return false;
      }

      return true;
    } catch (ex) {
      print('InsertChatroomMessage fail $ex');
      return false;
    }
  }

  /// 建立聊天室
  static Future createChatroom(int type, String groupId) async {
    try {
      final body = {
        'type': type,
        'groupId': groupId,
      };

      await APIHelper.callAPI(
        HttpMethod.post,
        ApiPath.createChatroom,
        content: body,
      );
    } catch (ex) {
      print('createChatroom fail $ex');
    }
  }

  /// 取得群組聊天室
  static Future<ChatCard?> getGroupChatroom(String groupId) async {
    try {
      final db = await DatabaseHelper.db;
      final chatrooms = await db.rawQuery(
        '''
          SELECT * FROM CHATROOM
          WHERE groupType <> 0
          AND groupId = ?
        ''',
        [groupId],
      );

      if (chatrooms.isEmpty) return null;

      return ChatCard.fromJson(chatrooms.first);
    } catch (ex) {
      print('getGroupChatroom fail, $ex');
      return null;
    }
  }

  /// 取得聊天貼圖群組列表
  static Future<List<ChatStickerGroup>> getChatStickerGroups() async {
    try {
      final db = await DatabaseHelper.db;
      // 只取得有貼圖的貼圖群組
      final strickerGroups = await db.rawQuery(
        '''
          SELECT *
          FROM CHAT_STICKER_GROUP
          WHERE (SELECT COUNT(*) FROM CHAT_STICKER WHERE id = groupId) > 0
          ORDER BY [order]
        ''',
      );

      return strickerGroups.map((e) => ChatStickerGroup.fromJson(e)).toList();
    } catch (ex) {
      print('getChatStickerGroups fail, $ex');
      return [];
    }
  }

  /// 取得聊天貼圖列表
  static Future<List<ChatSticker>> getChatStickers(int groupId) async {
    try {
      final db = await DatabaseHelper.db;
      final stickers = await db.rawQuery(
        '''
          SELECT *
          FROM CHAT_STICKER
          WHERE groupId = ?
        ''',
        [groupId],
      );

      return stickers.map((e) => ChatSticker.fromJson(e)).toList();
    } catch (ex) {
      print('getChatSticker fail, $ex');
      return [];
    }
  }

  /// 取得聊天貼圖歷程
  static Future<List<ChatSticker>> getChatStickerHistory() async {
    try {
      final db = await DatabaseHelper.db;
      final stickers = await db.rawQuery(
        '''
          SELECT *
          FROM CHAT_STICKER_HISTORY CSH
          INNER JOIN CHAT_STICKER CS ON CS.id = CSH.stickerId
          ORDER BY CSH.updateTime DESC
        ''',
      );

      return stickers.map((e) => ChatSticker.fromJson(e)).toList();
    } catch (ex) {
      print('getChatSticker fail, $ex');
      return [];
    }
  }

  /// 更新聊天貼圖歷程
  static Future updateChatStickerHistory(int stickerId) async {
    try {
      final db = await DatabaseHelper.db;

      await db.execute(
        '''
          REPLACE INTO CHAT_STICKER_HISTORY
            (stickerId , updateTime)
          VALUES
            (?, ?)
        ''',
        [stickerId, DateTime.now().millisecondsSinceEpoch],
      );
    } catch (ex) {
      print('updateChatStickerHistory fail, $ex');
    }
  }

  /// 取得聊天室額外功能
  static Future<List<Map<String, dynamic>>> getExtraFeatures() async {
    try {
      final db = await DatabaseHelper.db;

      final extraFeatures = await db.rawQuery(
        '''
          SELECT *
          FROM CHAT_EXTRA_FEATURE
          WHERE isDelete = 0
          ORDER BY [order]
        ''',
      );

      return extraFeatures;
    } catch (ex) {
      print('getExtraFeatures fail, $ex');
      return [];
    }
  }

  /// 取得聊天室成員列表
  static Future<List<ChatUser>> getChatroomUsers(int chatroomId,
      [bool isContainsdeleted = false]) async {
    try {
      final db = await DatabaseHelper.db;
      final filterSql = isContainsdeleted ? '' : 'AND isDelete = 0';
      final users = await db.rawQuery(
        '''
          SELECT *
          FROM CHATROOM_USER
          WHERE chatroomId = ?
          $filterSql
        ''',
        [chatroomId],
      );

      return users.map((e) => ChatUser.fromJson(e)).toList();
    } catch (ex) {
      print('getChatroomUsers fail, $ex');
      return [];
    }
  }

  /// 建立紅包
  static Future<bool> createRedEnvelope(
    int chatroomId,
    int type,
    int quantity,
    int totalPoints,
  ) async {
    try {
      final body = {
        'chatroomId': chatroomId,
        'type': type,
        'quantity': quantity,
        'totalPoints': totalPoints
      };

      final result = await APIHelper.callAPI(
        HttpMethod.post,
        ApiPath.createRedEnvelope,
        content: body,
      );

      if (result['status'] != 200) {
        print(result['message']);
        return false;
      }

      return true;
    } catch (ex) {
      print('createRedEnvelope fail, $ex');
      return false;
    }
  }

  /// 取得紅包歷程
  static Future<ChatRedEnvelopeHistory?> getRedEnvelopeHistory(int id) async {
    try {
      final result = await APIHelper.callAPI(
        HttpMethod.get,
        '${ApiPath.getRedEnvelopeHistory}?id=$id',
      );

      if (result['status'] != 200) return null;

      List<dynamic> data = result['data'];
      if (data.isEmpty) return null;

      return ChatRedEnvelopeHistory.fromJson(data[0]);
    } catch (ex) {
      print('getRedEnvelopeHistory fail, $ex');
      return null;
    }
  }

  /// 取得紅包歷程列表
  static Future<List<ChatRedEnvelopeHistory>> getRedEnvelopeHistories(
      int id) async {
    try {
      final result = await APIHelper.callAPI(
        HttpMethod.get,
        '${ApiPath.getRedEnvelopeHistories}?id=$id',
      );

      if (result['status'] != 200) return [];
      List<dynamic> data = result['data'];

      return data.map((e) => ChatRedEnvelopeHistory.fromJson(e)).toList();
    } catch (ex) {
      print('getRedEnvelopeHistories fail, $ex');
      return [];
    }
  }

  /// 抽紅包
  static Future<int?> drawRedEnvelope(int id, int chatroomId) async {
    try {
      final body = {
        'id': id,
        'chatroomId': chatroomId,
      };

      final result = await APIHelper.callAPI(
        HttpMethod.put,
        ApiPath.drawRedEnvelope,
        content: body,
        timeoutLimit: 10,
      );

      if (result['status'] != 200) return null;

      List<dynamic> data = result['data'];

      return data[0];
    } catch (ex) {
      print('getRedEnvelopeHistory fail, $ex');
      return null;
    }
  }

  /// 更新已領取的紅包
  static Future updateRedEnvelopeReceived(int id) async {
    try {
      final db = await DatabaseHelper.db;
      await db.execute(
        '''
          REPLACE INTO CHAT_RED_ENVELOPE_RECEIVED
            (id)
          VALUES
            (?)
        ''',
        [id],
      );
    } catch (ex) {
      print('updateRedEnvelopeReceived fail, $ex');
    }
  }

  /// 紅包是否已領取
  static Future<bool> isRedEnvelopeReceived(int id) async {
    try {
      final db = await DatabaseHelper.db;
      final result = await db.rawQuery(
        '''
          SELECT *
          FROM CHAT_RED_ENVELOPE_RECEIVED
          WHERE id = ?
        ''',
        [id],
      );

      return result.isNotEmpty;
    } catch (ex) {
      print('isRedEnvelopeReceived fail, $ex');
      return false;
    }
  }

  /// 發送檔案訊息
  static Future<bool> sendFileMessage(
    int chatroomId,
    List<File> files,
    FileType fileType,
  ) async {
    try {
      final uploadResult = await APIHelper.uploadFiles(files, fileType);

      if (uploadResult['status'] != 200) return false;

      List<dynamic> data = uploadResult['data'];
      final message = data.join(",");
      final chatType =
          ChatType.values.firstWhere((e) => e.name == fileType.name);
      final result = await insertChatroomMessage(chatroomId, message, chatType);

      return result;
    } catch (ex) {
      print('sendFileMessage fail, $ex');
      return false;
    }
  }
}
