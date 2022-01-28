import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;

class Global {
  /// navigator key
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  /// firebase device token
  static String token = '';

  /// Platform locale name
  static String locale = '';

  static bool hasNetwork = true;

  /// MOSME API domain
  static String mosmeApiDomain = 'http://api.mosme.net';

  /// Chat sticker base Url
  static String chatStickerBaseUrl = '$mosmeApiDomain/Sticker';

  /// 是否在聊天室內
  static bool isInChatroom = false;

  /// 連結預覽列表 (聊天室用)
  static Map<String, PreviewData> linkPreviews = {};
}

class ApiPath {
  // member
  /// 取得會員資料
  static String getMember = 'api/v1/member';

  /// 新增或更新會員裝置 Token POST
  static String insertOrUpdateDeviceToken = 'api/v1/member/deviceToken';

  // menu
  static String getMenuGroups = 'api/v1/menuGroups';

  // chat
  /// 取得會員聊天列表 GET
  static String getMemberChatrooms = 'api/v1/member/chatrooms';

  /// 取得聊天室成員 GET
  static String getChatroomUsers = 'api/v1/chatroom/users';

  /// 取得聊天室訊息 GET
  static String getChatroomMessages = 'api/v1/chatroom/messages';

  /// 更新已讀訊息 PUT
  static String updateReadMessage = 'api/v1/chatroom/message/read';

  /// 新增聊天室訊息 POST
  static String insertChatroomMessage = 'api/v1/chatroom/message';

  /// 新增聊天室 POST
  static String createChatroom = 'api/v1/chatroom';

  /// 取得聊天貼圖 GET
  static String getChatSticker = 'api/v1/chatroom/sticker';

  /// 取得額外功能 GET
  static String getExtraFeature = 'api/v1/chatroom/extraFeature';

  /// 建立紅包 POST
  static String createRedEnvelope = 'api/v1/chatroom/redEnvelope';

  /// 取得紅包 GET
  static String getRedEnvelope = 'api/v1/chatroom/redEnvelope';

  /// 取得紅包歷程 GET
  static String getRedEnvelopeHistory = 'api/v1/chatroom/redEnvelope/history';

  /// 取得紅包歷程列表 GET
  static String getRedEnvelopeHistories =
      'api/v1/chatroom/redEnvelope/histories';

  /// 抽紅包 PUT
  static String drawRedEnvelope = 'api/v1/chatroom/redEnvelope';
  
  /// update files POST
  static String uploadChatroomFiles = 'api/v1/chatroom/files';

  // user list
  /// 取得會員老師列表
  static String getMemberTeachers = 'api/v1/member/teachers';

  /// 取得會員班級列表
  static String getMemberClasses = 'api/v1/member/classes';
}

/// 產生漸變色區塊
Widget generateGradualSpace({
  required Color beginColor,
  required Color endColor,
  Widget? child,
  AlignmentGeometry begin = Alignment.topLeft,
  AlignmentGeometry end = Alignment.bottomRight,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: begin,
        end: end,
        colors: <Color>[
          beginColor,
          endColor,
        ],
      ),
    ),
    child: child,
  );
}

/// 取消元素聚焦
void unfocus(BuildContext context) {
  final currentFocus = FocusScope.of(context);

  if (currentFocus.hasPrimaryFocus) return;
  currentFocus.unfocus();
}

/// border btn style
ButtonStyle borderButtonStyle(Color? backgroundColor, Color? sideColor) {
  return ButtonStyle(
    backgroundColor: MaterialStateProperty.all<Color>(backgroundColor!),
    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(color: sideColor!),
      ),
    ),
  );
}

/// 取得當前的 route 名稱
String? getCurrentRouteName() {
  String? routeName;

  Global.navigatorKey.currentState!.popUntil((route) {
    routeName = route.settings.name;
    return true;
  });

  return routeName;
}

/// 圓形 Icon
Widget circularIcon({
  required Widget icon,
  void Function()? onPressed,
  Color? color = Colors.transparent,
  double height = 35,
  double width = 35,
}) {
  return SizedBox(
    height: height,
    width: width,
    child: ClipOval(
      child: Material(
        color: color,
        child: IconButton(
          onPressed: onPressed,
          icon: icon,
        ),
      ),
    ),
  );
}

/// 圓形頭像
Widget circleAvatar({
  required ImageProvider<Object> backgroundImage,
  required double radius,
}) {
  return CircleAvatar(
    backgroundColor: Colors.grey[300],
    radius: radius,
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: backgroundImage,
      radius: radius - 1,
    ),
  );
}

/// 依照行或列數量群組項目
void groupItemByQuantity<T>(
    List<dynamic> groupItems, List<T> items, int quantity,
    [T? defaultItem]) {
  // 初始化群組項目列表
  groupItems.clear();
  // 若無任何項目，直接結束
  if (items.isEmpty) return;

  var group = <T>[];
  for (var item in items) {
    group.add(item);

    // 滿一組加入一次群組項目列表
    if (group.length % quantity == 0) {
      groupItems.add(group);
      group = <T>[];
    }
  }

  // 將最後不滿一組的加入群組項目列表
  if (group.isNotEmpty) {
    // 有預設項目
    if (defaultItem != null) {
      // 補上預設項目 (方便排版用)
      final length = group.length;
      for (var i = 0; i < quantity - length; i += 1) {
        group.add(defaultItem);
      }
    }

    groupItems.add(group);
  }
}

/// 生成下拉選單
Widget generateDropdown<T>({
  Mode mode = Mode.MENU,
  double? maxHeight,
  required String labelText,
  required String hintText,
  String? helperText,
  String? errorText,
  required List<T> items,
  T? selectedItem,
  bool showSearchBox = false,
  String searchBoxLabelText = '',
  Color? fillColor,
  Color borderSideColor = Colors.black,
  Future<List<T>> Function(String?)? onFind,
  Future<bool?> Function(T?, T?)? onBeforeChange,
  void Function(T?)? onChanged,
  // 非 String 類型必須設定，切換選項的比較規則
  bool Function(T?, T?)? compareFn,
}) {
  return DropdownSearch<T>(
    mode: mode,
    popupBarrierColor: Colors.black26,
    showSelectedItems: true,
    showAsSuffixIcons: true,
    showSearchBox: showSearchBox,
    maxHeight: maxHeight,
    dropdownSearchDecoration: InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      filled: fillColor != null,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: borderSideColor),
        borderRadius: BorderRadius.circular(10.0),
      ),
    ),
    items: items,
    selectedItem: selectedItem,
    onBeforeChange: onBeforeChange,
    onChanged: onChanged,
    onFind: onFind,
    compareFn: compareFn,
    searchFieldProps: TextFieldProps(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.fromLTRB(12, 12, 8, 0),
        labelText: searchBoxLabelText,
      ),
    ),
  );
}

/// 加入 query parameters
Uri addQueryParameters(Uri uri, Map<String, dynamic> queryParams) {
  var queryParameters = {
    ...uri.queryParameters,
    ...queryParams
  };

  if (uri.scheme.contains(RegExp('s', caseSensitive: false))) {
    return Uri.https(uri.authority, uri.path, queryParameters);
  }

  return Uri.http(uri.authority, uri.path, queryParameters);
}
