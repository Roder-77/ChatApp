import 'package:chat/generated/l10n.dart';
import 'package:chat/helpers/database_sync_helper.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/models/botton_model.dart';
import 'package:chat/src/chats/chat_list.dart';
import 'package:chat/src/chats/user_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'app_bar.dart';

class Chat extends StatefulWidget {
  const Chat({Key? key}) : super(key: key);

  static const routeName = '/chats';

  @override
  ChatState createState() => ChatState();
}

class ChatState extends State<Chat> {
  final _iconSize = 20.0;
  // 聊天列表 key
  static final GlobalKey<ChatListState> _chatListkey = GlobalKey();
  // 成員列表 key
  final GlobalKey<UserListState> _userListkey = GlobalKey();
  static late ChatListType _chatListType;
  var _userListType = ChatListType.myTeachers;
  static late BottomNavBarOption _navBarCurrentOption;
  var _navBarSelectedIndex = 0;

  /// 頁面是否載入中
  bool get _isPageLoading {
    final isChatListLoading = _chatListkey.currentState != null &&
        _chatListkey.currentState!.isLoading;
    final isUserListLoading = _userListkey.currentState != null &&
        _userListkey.currentState!.isLoading;

    return isChatListLoading || isUserListLoading;
  }

  /// 取得當前的 Body
  Widget? getCurrentBody() {
    switch (_navBarCurrentOption) {
      case BottomNavBarOption.chat:
        return ChatList(key: _chatListkey, type: _chatListType);
      case BottomNavBarOption.users:
        return UserList(key: _userListkey, type: _userListType);
      case BottomNavBarOption.setting:
        return null;
    }
  }

  /// 刷新聊天室列表
  static void refreshChatList() {
    if (_navBarCurrentOption != BottomNavBarOption.chat) return;

    _chatListkey.currentState!.getMemberChatrooms(_chatListType);
  }

  @override
  void initState() {
    super.initState();
    _chatListType = defaultChatListType;
    _navBarCurrentOption = BottomNavBarOption.values[0];

    // 同步聊天貼圖
    DatabaseSyncHelper.syncChatSticker();
    // 同步額外功能
    DatabaseSyncHelper.syncChatExtraFeatures();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // 點擊時，unfocus 其他元素
      onTap: () => unfocus(context),
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: Scaffold(
            appBar: ChatAppBar(
              option: _navBarCurrentOption,
              emitSeletedBtn: (type) {
                setState(() {
                  if (_navBarCurrentOption == BottomNavBarOption.chat) {
                    _chatListType = type;
                    // 依照 type 變化取得列表資料
                    _chatListkey.currentState!.getMemberChatrooms(type);
                  } else if (_navBarCurrentOption == BottomNavBarOption.users) {
                    _userListType = type;
                    // 依照 type 變化取得列表資料
                    _userListkey.currentState!.getUsersCards(type);
                  }
                });
              },
            ),
            body: getCurrentBody(),
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: Colors.grey[100],
              selectedItemColor: const Color(0xFF299EC9),
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: FaIcon(
                    FontAwesomeIcons.solidCommentAlt,
                    size: _iconSize,
                  ),
                  label: S.of(context).chat_message,
                ),
                BottomNavigationBarItem(
                  icon: FaIcon(
                    FontAwesomeIcons.users,
                    size: _iconSize,
                  ),
                  label: S.of(context).chat_users,
                ),
                // 設定 (未來可能會加入)
                // BottomNavigationBarItem(
                //   icon: FaIcon(
                //     FontAwesomeIcons.cog,
                //     size: _iconSize,
                //   ),
                //   label: S.of(context).chat_setting,
                // ),
              ],
              currentIndex: _navBarSelectedIndex,
              onTap: (index) {
                // 若當前頁面 loading、已在當前頁面，直接結束
                if (_isPageLoading || _navBarSelectedIndex == index) {
                  return;
                }

                setState(() {
                  _navBarSelectedIndex = index;
                  _navBarCurrentOption = BottomNavBarOption.values[index];
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
