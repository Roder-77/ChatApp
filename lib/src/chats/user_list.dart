import "package:collection/collection.dart";
import 'package:chat/extensions/navigator_extension.dart';
import 'package:chat/generated/l10n.dart';
import 'package:chat/helpers/alert_helper.dart';
import 'package:chat/helpers/chat_helper.dart';
import 'package:chat/helpers/chat_user_helper.dart';
import 'package:chat/helpers/database_sync_helper.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/models/botton_model.dart';
import 'package:chat/models/users/users_card.dart';
import 'package:chat/src/chats/chatroom.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';

class UserList extends StatefulWidget {
  const UserList({
    Key? key,
    required this.type,
  }) : super(key: key);

  final ChatListType type;

  @override
  UserListState createState() => UserListState();
}

class UserListState extends State<UserList> {
  /// 成員列表
  var _usersCards = <UsersCard>[];
  var isLoading = true;

  @override
  void initState() {
    super.initState();

    // 等 instance 起完，確保能使用 context (避免調用 loading 時出錯)
    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      await getUsersCards(widget.type);
    });
  }

  /// 取得成員列表資料 (依照按鈕切換)
  Future getUsersCards(ChatListType type) async {
    isLoading = true;
    AlertHelper.showloading();
    // 同步成員群組列表
    await DatabaseSyncHelper.syncUserGourps(type);
    // 取得成員群組列表
    await ChatUserHelper.getUserGroups(type).then((users) {
      setState(() {
        _usersCards = _groupUsers(users);
        isLoading = false;
        AlertHelper.dismissLoading();
      });
    });
  }

  List<UsersCard> _groupUsers(List<UsersCard> users) {
    var result = <UsersCard>[];
    // Group by year
    Map<String, List<UsersCard>> userGroups = groupBy(users, (user) {
      return DateFormat.y(Global.locale).format(user.createTime);
    });

    // 整合列表資料
    userGroups.forEach((yearRange, userGroup) {
      if (userGroup.isNotEmpty) {
        userGroup.sort((a, b) => a.groupType.compareTo(b.groupType));
        userGroup.first.yearRange = yearRange;
      }
      result.addAll(userGroup);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    /// 是否為我的老師
    final bool isMyTeacher = widget.type == ChatListType.myTeachers;

    return ListView.builder(
      itemCount: _usersCards.length,
      itemBuilder: (context, index) {
        final card = _usersCards[index];

        return Column(
          children: [
            card.yearRange.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.yearRange,
                          style: const TextStyle(fontSize: 20),
                        ),
                        const Divider(color: Colors.grey),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            ListTile(
              contentPadding: const EdgeInsets.only(left: 10, right: 10),
              leading: circleAvatar(
                backgroundImage: CachedNetworkImageProvider(card.imageUrl),
                radius: 30,
              ),
              title: Text(
                isMyTeacher ? card.name : card.groupName,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              subtitle: Text(
                isMyTeacher
                    ? card.groupName
                    : S.of(context).chat_my_class_student(card.totalPeople),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () async {
                AlertHelper.showloading();
                // 建立聊天室
                await ChatHelper.createChatroom(card.groupType, card.id);
                // 同步聊天室資料
                await DatabaseSyncHelper.syncChatrooms();
                // 取得聊天室資料
                var chatroom = await ChatHelper.getGroupChatroom(card.id);
                AlertHelper.dismissLoading();

                // 若無聊天室資料 (可能原因，無網路資料同步失敗 || 呼叫API失敗)
                if (chatroom == null) {
                  AlertHelper.alert(
                      context: context, message: S.of(context).error_hint);
                  return;
                }

                // 前往聊天室
                Global.navigatorKey.currentState!.customPushNamed(
                  Chatroom.routeName,
                  arguments: ChatroomArguments(
                    chatroom.name,
                    chatroom.id,
                    chatroom.lastestMessageId,
                  ),
                );
              },
            )
          ],
        );
      },
    );
  }
}

// /// 新增或建立班級 (可能暫時用不到)
// Widget addClass(BuildContext context, bool isMyTeacher) {
//   return InkWell(
//     onTap: () {
//       if (isMyTeacher) {
//         // Todo: 加入班級
//       } else {
//         // Todo: 建立班級
//       }
//     },
//     child: SizedBox(
//       height: 80,
//       child: Row(
//         children: <Widget>[
//           const Padding(
//             padding: EdgeInsets.only(left: 15),
//             child: ClipOval(
//               child: Material(
//                 color: Color(0xFF16CCB5),
//                 child: IconButton(
//                   onPressed: null,
//                   icon: FaIcon(
//                     FontAwesomeIcons.userPlus,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           const Padding(padding: EdgeInsets.only(left: 15)),
//           Flexible(
//             child: Text(
//               isMyTeacher
//                   ? S.of(context).chat_join_class
//                   : S.of(context).chat_create_class,
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
