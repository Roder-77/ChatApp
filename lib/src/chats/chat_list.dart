import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/extensions/navigator_extension.dart';
import 'package:chat/generated/l10n.dart';
import 'package:chat/helpers/alert_helper.dart';
import 'package:chat/helpers/chat_helper.dart';
import 'package:chat/helpers/database_sync_helper.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/models/botton_model.dart';
import 'package:chat/models/chats/chat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

import 'chatroom.dart';

class ChatList extends StatefulWidget {
  const ChatList({
    Key? key,
    required this.type,
  }) : super(key: key);

  final ChatListType type;

  @override
  ChatListState createState() => ChatListState();
}

class ChatListState extends State<ChatList> with WidgetsBindingObserver {
  /// 聊天室列表
  var chatCards = <ChatCard>[];
  var isLoading = true;

  @override
  void initState() {
    super.initState();

    // 觀察 widget
    WidgetsBinding.instance!.addObserver(this);

    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      AlertHelper.showloading();
      await getMemberChatrooms(widget.type);
      AlertHelper.dismissLoading();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      // 從背景返回前台時
      case AppLifecycleState.resumed:
        getMemberChatrooms(widget.type);
        break;
      // 前台非活動狀態，應用程序在進入時轉換到此狀態時
      case AppLifecycleState.inactive:
      // 切換到背景時
      case AppLifecycleState.paused:
      // App 結束時
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    // 取消觀察 widget
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  /// 取得會員聊天室列表
  Future getMemberChatrooms(ChatListType type) async {
    isLoading = true;
    // 同步聊天室列表
    await DatabaseSyncHelper.syncChatrooms();
    // 取得聊天室列表
    await ChatHelper.getChatrooms(type).then((value) {
      setState(() {
        chatCards = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (chatCards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              S.of(context).chat_list_empty,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(S.of(context).chat_list_empty_solution,
                style: const TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      // 設定 item 固定高度，提高效能
      itemExtent: 80,
      itemCount: chatCards.length,
      itemBuilder: (context, index) {
        final card = chatCards[index];

        return ListTile(
          contentPadding: const EdgeInsets.all(10),
          leading: circleAvatar(
            backgroundImage: CachedNetworkImageProvider(card.imageUrl),
            radius: 30,
          ),
          title: Text(
            card.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            card.displayMessage,
            maxLines: 2,
            // 溢出設定: 文字過多自動省略
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Column(
              children: <Widget>[
                Text(
                  DateFormat.jm().format(
                    DateTime.fromMillisecondsSinceEpoch(
                      card.time!,
                    ),
                  ),
                ),
                Badge(
                  // 無已讀訊息不顯示 badge
                  showBadge: card.unread != 0,
                  padding: const EdgeInsets.all(8.0),
                  toAnimate: false,
                  badgeContent: Text(
                    card.unread.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            // 前往聊天室 (返回時刷新列表)
            Global.navigatorKey.currentState!
                .customPushNamed(
                  Chatroom.routeName,
                  arguments: ChatroomArguments(
                    card.name,
                    card.id,
                    card.lastestMessageId,
                  ),
                )
                .then((_) => getMemberChatrooms(widget.type));
          },
        );
      },
    );
  }
}
