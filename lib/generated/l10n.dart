// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `帳號已被停用，請連絡相關業務`
  String get account_suspended {
    return Intl.message(
      '帳號已被停用，請連絡相關業務',
      name: 'account_suspended',
      desc: '',
      args: [],
    );
  }

  /// `全部`
  String get chat_all {
    return Intl.message(
      '全部',
      name: 'chat_all',
      desc: '',
      args: [],
    );
  }

  /// `班級`
  String get chat_class {
    return Intl.message(
      '班級',
      name: 'chat_class',
      desc: '',
      args: [],
    );
  }

  /// `建立班級`
  String get chat_create_class {
    return Intl.message(
      '建立班級',
      name: 'chat_create_class',
      desc: '',
      args: [],
    );
  }

  /// `輸入訊息`
  String get chat_input_bar_placeholder {
    return Intl.message(
      '輸入訊息',
      name: 'chat_input_bar_placeholder',
      desc: '',
      args: [],
    );
  }

  /// `加入班級`
  String get chat_join_class {
    return Intl.message(
      '加入班級',
      name: 'chat_join_class',
      desc: '',
      args: [],
    );
  }

  /// `訊息`
  String get chat_message {
    return Intl.message(
      '訊息',
      name: 'chat_message',
      desc: '',
      args: [],
    );
  }

  /// `我的班級`
  String get chat_my_class {
    return Intl.message(
      '我的班級',
      name: 'chat_my_class',
      desc: '',
      args: [],
    );
  }

  /// `班級學生: {count}人`
  String chat_my_class_student(Object count) {
    return Intl.message(
      '班級學生: $count人',
      name: 'chat_my_class_student',
      desc: '',
      args: [count],
    );
  }

  /// `我的老師`
  String get chat_my_teacher {
    return Intl.message(
      '我的老師',
      name: 'chat_my_teacher',
      desc: '',
      args: [],
    );
  }

  /// `此分類尚無聊天室`
  String get chat_list_empty {
    return Intl.message(
      '此分類尚無聊天室',
      name: 'chat_list_empty',
      desc: '',
      args: [],
    );
  }

  /// `請點按下方「成員」按鈕新增聊天室`
  String get chat_list_empty_solution {
    return Intl.message(
      '請點按下方「成員」按鈕新增聊天室',
      name: 'chat_list_empty_solution',
      desc: '',
      args: [],
    );
  }

  /// `搜尋聊天`
  String get chat_search_bar_placeholder {
    return Intl.message(
      '搜尋聊天',
      name: 'chat_search_bar_placeholder',
      desc: '',
      args: [],
    );
  }

  /// `尚未使用過貼圖`
  String get chat_sticker_empty_hint {
    return Intl.message(
      '尚未使用過貼圖',
      name: 'chat_sticker_empty_hint',
      desc: '',
      args: [],
    );
  }

  /// `聊天室`
  String get chat_title {
    return Intl.message(
      '聊天室',
      name: 'chat_title',
      desc: '',
      args: [],
    );
  }

  /// `今天`
  String get chat_today_message_hint {
    return Intl.message(
      '今天',
      name: 'chat_today_message_hint',
      desc: '',
      args: [],
    );
  }

  /// `以下為未讀訊息`
  String get chat_unread_hint {
    return Intl.message(
      '以下為未讀訊息',
      name: 'chat_unread_hint',
      desc: '',
      args: [],
    );
  }

  /// `成員`
  String get chat_users {
    return Intl.message(
      '成員',
      name: 'chat_users',
      desc: '',
      args: [],
    );
  }

  /// `成員列表`
  String get chat_user_list {
    return Intl.message(
      '成員列表',
      name: 'chat_user_list',
      desc: '',
      args: [],
    );
  }

  /// `昨天`
  String get chat_yesterday_message_hint {
    return Intl.message(
      '昨天',
      name: 'chat_yesterday_message_hint',
      desc: '',
      args: [],
    );
  }

  /// `目前聊天室成員共{count}人`
  String chatroom_total_user(Object count) {
    return Intl.message(
      '目前聊天室成員共$count人',
      name: 'chatroom_total_user',
      desc: '',
      args: [count],
    );
  }

  /// `相機`
  String get camera {
    return Intl.message(
      '相機',
      name: 'camera',
      desc: '',
      args: [],
    );
  }

  /// `點擊紅包查看`
  String get click_red_envelope {
    return Intl.message(
      '點擊紅包查看',
      name: 'click_red_envelope',
      desc: '',
      args: [],
    );
  }

  /// `元`
  String get currency {
    return Intl.message(
      '元',
      name: 'currency',
      desc: '',
      args: [],
    );
  }

  /// `網路不穩或發生未知的錯誤，請聯絡客服、相關業務或稍後再試。`
  String get error_hint {
    return Intl.message(
      '網路不穩或發生未知的錯誤，請聯絡客服、相關業務或稍後再試。',
      name: 'error_hint',
      desc: '',
      args: [],
    );
  }

  /// `檔案`
  String get file {
    return Intl.message(
      '檔案',
      name: 'file',
      desc: '',
      args: [],
    );
  }

  /// `檔案已超過時效限制`
  String get file_time_limit_exceeded {
    return Intl.message(
      '檔案已超過時效限制',
      name: 'file_time_limit_exceeded',
      desc: '',
      args: [],
    );
  }

  /// `餘額不足`
  String get insufficient_balance {
    return Intl.message(
      '餘額不足',
      name: 'insufficient_balance',
      desc: '',
      args: [],
    );
  }

  /// `無網路連線或連線不順`
  String get no_signal {
    return Intl.message(
      '無網路連線或連線不順',
      name: 'no_signal',
      desc: '',
      args: [],
    );
  }

  /// `一般紅包`
  String get normal_red_envelope {
    return Intl.message(
      '一般紅包',
      name: 'normal_red_envelope',
      desc: '',
      args: [],
    );
  }

  /// `圖片`
  String get picture {
    return Intl.message(
      '圖片',
      name: 'picture',
      desc: '',
      args: [],
    );
  }

  /// `請選擇`
  String get please_choose {
    return Intl.message(
      '請選擇',
      name: 'please_choose',
      desc: '',
      args: [],
    );
  }

  /// `下回請早唷！`
  String get please_come_earlier_next_time {
    return Intl.message(
      '下回請早唷！',
      name: 'please_come_earlier_next_time',
      desc: '',
      args: [],
    );
  }

  /// `請輸入`
  String get please_enter {
    return Intl.message(
      '請輸入',
      name: 'please_enter',
      desc: '',
      args: [],
    );
  }

  /// `請輸入數字`
  String get please_enter_number {
    return Intl.message(
      '請輸入數字',
      name: 'please_enter_number',
      desc: '',
      args: [],
    );
  }

  /// `請前往應用程式設定開啟{type}權限`
  String please_open_permission(Object type) {
    return Intl.message(
      '請前往應用程式設定開啟$type權限',
      name: 'please_open_permission',
      desc: '',
      args: [type],
    );
  }

  /// `點`
  String get point {
    return Intl.message(
      '點',
      name: 'point',
      desc: '',
      args: [],
    );
  }

  /// `目前點數餘額為{count}點`
  String point_balance(Object count) {
    return Intl.message(
      '目前點數餘額為$count點',
      name: 'point_balance',
      desc: '',
      args: [count],
    );
  }

  /// `每包點數`
  String get point_of_red_envelope {
    return Intl.message(
      '每包點數',
      name: 'point_of_red_envelope',
      desc: '',
      args: [],
    );
  }

  /// `手氣紅包`
  String get radom_red_envelope {
    return Intl.message(
      '手氣紅包',
      name: 'radom_red_envelope',
      desc: '',
      args: [],
    );
  }

  /// `手氣紅包總點數至少{count}點`
  String radom_red_envelope_min_points(Object count) {
    return Intl.message(
      '手氣紅包總點數至少$count點',
      name: 'radom_red_envelope_min_points',
      desc: '',
      args: [count],
    );
  }

  /// `數量不可大於總點數`
  String get radom_red_envelope_quantity_limit {
    return Intl.message(
      '數量不可大於總點數',
      name: 'radom_red_envelope_quantity_limit',
      desc: '',
      args: [],
    );
  }

  /// `已領取`
  String get received {
    return Intl.message(
      '已領取',
      name: 'received',
      desc: '',
      args: [],
    );
  }

  /// `紅包`
  String get red_envelope {
    return Intl.message(
      '紅包',
      name: 'red_envelope',
      desc: '',
      args: [],
    );
  }

  /// `紅包已被抽完`
  String get red_envelope_has_been_drawn {
    return Intl.message(
      '紅包已被抽完',
      name: 'red_envelope_has_been_drawn',
      desc: '',
      args: [],
    );
  }

  /// `紅包尚未被任何人領取`
  String get red_envelope_history_empty_hint {
    return Intl.message(
      '紅包尚未被任何人領取',
      name: 'red_envelope_history_empty_hint',
      desc: '',
      args: [],
    );
  }

  /// `紅包類型`
  String get red_envelope_type {
    return Intl.message(
      '紅包類型',
      name: 'red_envelope_type',
      desc: '',
      args: [],
    );
  }

  /// `紅包數量`
  String get red_envelope_quantity {
    return Intl.message(
      '紅包數量',
      name: 'red_envelope_quantity',
      desc: '',
      args: [],
    );
  }

  /// `領取詳情`
  String get received_detail {
    return Intl.message(
      '領取詳情',
      name: 'received_detail',
      desc: '',
      args: [],
    );
  }

  /// `收到红包`
  String get received_red_envelope {
    return Intl.message(
      '收到红包',
      name: 'received_red_envelope',
      desc: '',
      args: [],
    );
  }

  /// `收到貼圖`
  String get received_sticker {
    return Intl.message(
      '收到貼圖',
      name: 'received_sticker',
      desc: '',
      args: [],
    );
  }

  /// `發送紅包`
  String get send_red_envelope {
    return Intl.message(
      '發送紅包',
      name: 'send_red_envelope',
      desc: '',
      args: [],
    );
  }

  /// `貼圖`
  String get sticker {
    return Intl.message(
      '貼圖',
      name: 'sticker',
      desc: '',
      args: [],
    );
  }

  /// `總點數`
  String get total_point {
    return Intl.message(
      '總點數',
      name: 'total_point',
      desc: '',
      args: [],
    );
  }

  /// `恭喜！抽中點數`
  String get winning_points {
    return Intl.message(
      '恭喜！抽中點數',
      name: 'winning_points',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'CN'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
      Locale.fromSubtags(
          languageCode: 'zh', scriptCode: 'Hans', countryCode: 'ZN'),
      Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
      Locale.fromSubtags(
          languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
