// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_TW locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'zh_TW';

  static String m0(count) => "班級學生: ${count}人";

  static String m1(count) => "目前聊天室成員共${count}人";

  static String m2(type) => "請前往應用程式設定開啟${type}權限";

  static String m3(count) => "目前點數餘額為${count}點";

  static String m4(count) => "手氣紅包總點數至少${count}點";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account_suspended":
            MessageLookupByLibrary.simpleMessage("帳號已被停用，請連絡相關業務"),
        "camera": MessageLookupByLibrary.simpleMessage("相機"),
        "chat_all": MessageLookupByLibrary.simpleMessage("全部"),
        "chat_class": MessageLookupByLibrary.simpleMessage("班級"),
        "chat_create_class": MessageLookupByLibrary.simpleMessage("建立班級"),
        "chat_input_bar_placeholder":
            MessageLookupByLibrary.simpleMessage("輸入訊息"),
        "chat_join_class": MessageLookupByLibrary.simpleMessage("加入班級"),
        "chat_list_empty": MessageLookupByLibrary.simpleMessage("此分類尚無聊天室"),
        "chat_list_empty_solution":
            MessageLookupByLibrary.simpleMessage("請點按下方「成員」按鈕新增聊天室"),
        "chat_message": MessageLookupByLibrary.simpleMessage("訊息"),
        "chat_my_class": MessageLookupByLibrary.simpleMessage("我的班級"),
        "chat_my_class_student": m0,
        "chat_my_teacher": MessageLookupByLibrary.simpleMessage("我的老師"),
        "chat_search_bar_placeholder":
            MessageLookupByLibrary.simpleMessage("搜尋聊天"),
        "chat_sticker_empty_hint":
            MessageLookupByLibrary.simpleMessage("尚未使用過貼圖"),
        "chat_title": MessageLookupByLibrary.simpleMessage("聊天室"),
        "chat_today_message_hint": MessageLookupByLibrary.simpleMessage("今天"),
        "chat_unread_hint": MessageLookupByLibrary.simpleMessage("以下為未讀訊息"),
        "chat_user_list": MessageLookupByLibrary.simpleMessage("成員列表"),
        "chat_users": MessageLookupByLibrary.simpleMessage("成員"),
        "chat_yesterday_message_hint":
            MessageLookupByLibrary.simpleMessage("昨天"),
        "chatroom_total_user": m1,
        "click_red_envelope": MessageLookupByLibrary.simpleMessage("點擊紅包查看"),
        "currency": MessageLookupByLibrary.simpleMessage("元"),
        "error_hint": MessageLookupByLibrary.simpleMessage(
            "網路不穩或發生未知的錯誤，請聯絡客服、相關業務或稍後再試。"),
        "file": MessageLookupByLibrary.simpleMessage("檔案"),
        "file_time_limit_exceeded":
            MessageLookupByLibrary.simpleMessage("檔案已超過時效限制"),
        "insufficient_balance": MessageLookupByLibrary.simpleMessage("餘額不足"),
        "no_signal": MessageLookupByLibrary.simpleMessage("無網路連線或連線不順"),
        "normal_red_envelope": MessageLookupByLibrary.simpleMessage("一般紅包"),
        "picture": MessageLookupByLibrary.simpleMessage("圖片"),
        "please_choose": MessageLookupByLibrary.simpleMessage("請選擇"),
        "please_come_earlier_next_time":
            MessageLookupByLibrary.simpleMessage("下回請早唷！"),
        "please_enter": MessageLookupByLibrary.simpleMessage("請輸入"),
        "please_enter_number": MessageLookupByLibrary.simpleMessage("請輸入數字"),
        "please_open_permission": m2,
        "point": MessageLookupByLibrary.simpleMessage("點"),
        "point_balance": m3,
        "point_of_red_envelope": MessageLookupByLibrary.simpleMessage("每包點數"),
        "radom_red_envelope": MessageLookupByLibrary.simpleMessage("手氣紅包"),
        "radom_red_envelope_min_points": m4,
        "radom_red_envelope_quantity_limit":
            MessageLookupByLibrary.simpleMessage("數量不可大於總點數"),
        "received": MessageLookupByLibrary.simpleMessage("已領取"),
        "received_detail": MessageLookupByLibrary.simpleMessage("領取詳情"),
        "received_red_envelope": MessageLookupByLibrary.simpleMessage("收到红包"),
        "received_sticker": MessageLookupByLibrary.simpleMessage("收到貼圖"),
        "red_envelope": MessageLookupByLibrary.simpleMessage("紅包"),
        "red_envelope_has_been_drawn":
            MessageLookupByLibrary.simpleMessage("紅包已被抽完"),
        "red_envelope_history_empty_hint":
            MessageLookupByLibrary.simpleMessage("紅包尚未被任何人領取"),
        "red_envelope_quantity": MessageLookupByLibrary.simpleMessage("紅包數量"),
        "red_envelope_type": MessageLookupByLibrary.simpleMessage("紅包類型"),
        "send_red_envelope": MessageLookupByLibrary.simpleMessage("發送紅包"),
        "sticker": MessageLookupByLibrary.simpleMessage("貼圖"),
        "total_point": MessageLookupByLibrary.simpleMessage("總點數"),
        "winning_points": MessageLookupByLibrary.simpleMessage("恭喜！抽中點數")
      };
}
