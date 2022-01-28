// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a zh_CN locale. All the
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
  String get localeName => 'zh_CN';

  static String m0(count) => "班级学生: ${count}人";

  static String m1(count) => "目前聊天室成员共${count}人";

  static String m2(type) => "请前往应用程式设定开启${type}权限";

  static String m3(count) => "目前点数余额为${count}点";

  static String m4(count) => "手气红包总点数至少${count}点";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "account_suspended":
            MessageLookupByLibrary.simpleMessage("帐号已被停用，请连络相关业务"),
        "camera": MessageLookupByLibrary.simpleMessage("相机"),
        "chat_all": MessageLookupByLibrary.simpleMessage("全部"),
        "chat_class": MessageLookupByLibrary.simpleMessage("班级"),
        "chat_create_class": MessageLookupByLibrary.simpleMessage("建立班级"),
        "chat_input_bar_placeholder":
            MessageLookupByLibrary.simpleMessage("输入讯息"),
        "chat_join_class": MessageLookupByLibrary.simpleMessage("加入班级"),
        "chat_list_empty": MessageLookupByLibrary.simpleMessage("此分类尚无聊天室"),
        "chat_list_empty_solution":
            MessageLookupByLibrary.simpleMessage("请点按下方「成员」按钮新增聊天室"),
        "chat_message": MessageLookupByLibrary.simpleMessage("讯息"),
        "chat_my_class": MessageLookupByLibrary.simpleMessage("我的班级"),
        "chat_my_class_student": m0,
        "chat_my_teacher": MessageLookupByLibrary.simpleMessage("我的老师"),
        "chat_search_bar_placeholder":
            MessageLookupByLibrary.simpleMessage("搜寻聊天"),
        "chat_sticker_empty_hint":
            MessageLookupByLibrary.simpleMessage("尚未使用过贴图"),
        "chat_title": MessageLookupByLibrary.simpleMessage("聊天室"),
        "chat_today_message_hint": MessageLookupByLibrary.simpleMessage("今天"),
        "chat_unread_hint": MessageLookupByLibrary.simpleMessage("以下为未读消息"),
        "chat_user_list": MessageLookupByLibrary.simpleMessage("成员列表"),
        "chat_users": MessageLookupByLibrary.simpleMessage("成员"),
        "chat_yesterday_message_hint":
            MessageLookupByLibrary.simpleMessage("昨天"),
        "chatroom_total_user": m1,
        "click_red_envelope": MessageLookupByLibrary.simpleMessage("点击红包查看"),
        "currency": MessageLookupByLibrary.simpleMessage("元"),
        "error_hint": MessageLookupByLibrary.simpleMessage(
            "网路不稳或发生未知的错误，请联络客服、相关业务或稍后再试。"),
        "file": MessageLookupByLibrary.simpleMessage("档案"),
        "file_time_limit_exceeded":
            MessageLookupByLibrary.simpleMessage("档案已超过时效限制"),
        "insufficient_balance": MessageLookupByLibrary.simpleMessage("余额不足"),
        "no_signal": MessageLookupByLibrary.simpleMessage("无网路连线或连线不顺"),
        "normal_red_envelope": MessageLookupByLibrary.simpleMessage("一般紅包"),
        "picture": MessageLookupByLibrary.simpleMessage("图片"),
        "please_choose": MessageLookupByLibrary.simpleMessage("请选择"),
        "please_come_earlier_next_time":
            MessageLookupByLibrary.simpleMessage("下回请早唷！"),
        "please_enter": MessageLookupByLibrary.simpleMessage("请输入"),
        "please_enter_number": MessageLookupByLibrary.simpleMessage("请输入数字"),
        "please_open_permission": m2,
        "point": MessageLookupByLibrary.simpleMessage("点"),
        "point_balance": m3,
        "point_of_red_envelope": MessageLookupByLibrary.simpleMessage("每包点数"),
        "radom_red_envelope": MessageLookupByLibrary.simpleMessage("手气红包"),
        "radom_red_envelope_min_points": m4,
        "radom_red_envelope_quantity_limit":
            MessageLookupByLibrary.simpleMessage("数量不可大于总点数"),
        "received": MessageLookupByLibrary.simpleMessage("已领取"),
        "received_detail": MessageLookupByLibrary.simpleMessage("领取详情"),
        "received_red_envelope": MessageLookupByLibrary.simpleMessage("收到红包"),
        "received_sticker": MessageLookupByLibrary.simpleMessage("收到贴图"),
        "red_envelope": MessageLookupByLibrary.simpleMessage("紅包"),
        "red_envelope_has_been_drawn":
            MessageLookupByLibrary.simpleMessage("红包已被抽完"),
        "red_envelope_history_empty_hint":
            MessageLookupByLibrary.simpleMessage("红包尚未被任何人领取"),
        "red_envelope_quantity": MessageLookupByLibrary.simpleMessage("紅包数量"),
        "red_envelope_type": MessageLookupByLibrary.simpleMessage("红包类型"),
        "send_red_envelope": MessageLookupByLibrary.simpleMessage("发送红包"),
        "sticker": MessageLookupByLibrary.simpleMessage("贴图"),
        "total_point": MessageLookupByLibrary.simpleMessage("总点数"),
        "winning_points": MessageLookupByLibrary.simpleMessage("恭喜！抽中点数")
      };
}
