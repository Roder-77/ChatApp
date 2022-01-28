import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/extensions/navigator_extension.dart';
import 'package:chat/helpers/alert_helper.dart';
import 'package:chat/helpers/image_helper.dart';
import 'package:chat/models/chats/chat_message.dart';
import 'package:chat/models/chats/chat_more_option.dart';
import 'package:chat/src/chats/chatroom_text_box.dart';
import 'package:chat/src/chats/extra_feature_area.dart';
import 'package:chat/src/chats/sticker_area.dart';
import 'package:chat/generated/l10n.dart';
import 'package:chat/helpers/chat_helper.dart';
import 'package:chat/helpers/database_sync_helper.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/models/userinfo.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/subjects.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ChatroomArguments {
  ChatroomArguments(this.chatroomName, this.chatroomId, this.lastestMessageId);

  /// 聊天室名稱
  final String chatroomName;

  /// 聊天室代碼
  final int chatroomId;

  /// 最新的已讀訊息代碼
  late int lastestMessageId;
}

class Chatroom extends StatefulWidget {
  const Chatroom({Key? key}) : super(key: key);

  static const routeName = '/chatroom';

  @override
  ChatroomState createState() => ChatroomState();
}

class ChatroomState extends State<Chatroom> with WidgetsBindingObserver {
  final _itemScrollController = ItemScrollController();
  final _itemPositionsListener = ItemPositionsListener.create();
  final _textController = TextEditingController();
  final _appBarHeight = 56.0;
  final _bottomAreaHeight = 250.0;
  static late BehaviorSubject<ChatMessage> newMessageSubject;

  /// 頁面參數
  static var _args = ChatroomArguments('', 0, 0);

  /// 訊息是否載入中
  var _isLoading = true;

  /// 訊息是否已至底
  var _isEnd = false;

  /// 當前訊息 page
  var _page = 1;

  /// 一頁數量
  final _pageQuantity = 50;

  /// 初始錨點 index
  var _initialScrollIndex = 0;

  /// 訊息列表
  static var _chatMessages = <ChatMessage>[];

  /// 目前聊天室代碼
  static int get chatroomId {
    return _args.chatroomId;
  }

  /// 新增訊息 (FCM)
  static void insertMessage(ChatMessage message) {
    newMessageSubject.add(message);
  }

  /// 輸入框最大行數
  final _textMaxLines = 5;

  /// 當前輸入框行數
  var _currentTextLine = 1;

  /// 按鈕類型
  var _buttonType = _BottomBtnType.none;

  /// 貼圖預覽區塊高度
  final _stickerPreviewAreaHeight = 100.0;

  /// 是否顯示貼圖預覽區塊
  var _isStickerPreviewAreaVisible = false;

  /// 當前貼圖資料
  final Map<String, dynamic> _currentSticker = {'id': 0, 'imagePath': ''};

  /// 是否顯示滾動至底按鈕
  var _isScrollToEndBtnVisible = false;

  /// 是否顯示更多選項區
  var _isMoreOptionVisible = false;

  var _moreOptions = <MoreOption>[];

  @override
  void initState() {
    super.initState();

    // 觀察 widget
    WidgetsBinding.instance!.addObserver(this);

    newMessageSubject = BehaviorSubject<ChatMessage>();
    // 監聽新訊息
    newMessageSubject.stream.listen((message) async {
      // 若訊息已存在，直接結束
      if (_chatMessages.any((e) => e.id == message.id)) return;

      // 新增到訊息列表
      _chatMessages.insert(0, message);
      ChatHelper.updateReadMessage(_args.chatroomId, message.id);
      setState(() {
        // 已讀更新到最新
        _args.lastestMessageId = message.id;
      });
    });

    // 監聽列表 item 位置
    _itemPositionsListener.itemPositions.addListener(() async {
      // 取得目前滾動範圍內的 index 列表
      final indexes = _itemPositionsListener.itemPositions.value
          .map((e) => e.index)
          .toList();
      // 是否包含最頂 index
      final hasTopIndex = indexes.contains(0);

      // 是否顯示至底按鈕 (避免一直重新繪製，當狀態有變化時才變更顯示)
      if (_isScrollToEndBtnVisible != !hasTopIndex) {
        setState(() {
          _isScrollToEndBtnVisible = !hasTopIndex;
        });
      }

      // 若還有訊息 & 非 loading 中 & 滾動到頂部，向上加載舊訊息
      if (!_isEnd && !_isLoading && indexes.last == _chatMessages.length - 1) {
        _isLoading = true;
        _page += 1;
        // 取得聊天室訊息
        await ChatHelper.getChatroomOldMessages(
          _args.chatroomId,
          _args.lastestMessageId,
          _page,
          _pageQuantity,
        ).then((messages) {
          _isLoading = false;
          // 若已無訊息，設定已經讀到底
          if (messages.isEmpty) {
            _isEnd = true;
            return;
          }

          setState(() => _chatMessages.addAll(_groupMessages(messages)));
        });
      }
    });

    // 監聽輸入框
    _textController.addListener(() {
      final textLine = _textController.text.split('\n').length;

      if (textLine > _textMaxLines) return;

      setState(() {
        _currentTextLine = textLine;
      });
    });

    SchedulerBinding.instance!.addPostFrameCallback((_) async {
      // 取得傳入參數
      _args = ModalRoute.of(context)!.settings.arguments as ChatroomArguments;
      await initChatroom();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      // 從背景返回前台時
      case AppLifecycleState.resumed:
        updateChatroom();
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
    // 重置聊天室連結預覽列表
    Global.linkPreviews.clear();
    // 重置頁面參數
    _args = ChatroomArguments('', 0, 0);
    _textController.dispose();
    _chatMessages.clear();
    newMessageSubject.close();
    super.dispose();
  }

  /// 同步聊天室資料
  Future syncChatroom() async {
    await Future.wait([
      DatabaseSyncHelper.syncChatroomUsers(_args.chatroomId),
      DatabaseSyncHelper.syncChatroomMessages(
        _args.chatroomId,
        _args.lastestMessageId,
      ),
    ]);
  }

  /// 初始化聊天室
  Future initChatroom() async {
    AlertHelper.showloading();
    _isLoading = true;
    // 同步聊天室資料
    await syncChatroom();

    // 取得聊天室訊息
    await Future.wait([
      ChatHelper.getChatroomNewMessages(
          _args.chatroomId, _args.lastestMessageId),
      ChatHelper.getChatroomOldMessages(
          _args.chatroomId, _args.lastestMessageId, _page, _pageQuantity),
    ]).then((data) {
      final messages = <ChatMessage>[];
      // 新訊息 (未讀)
      messages.addAll(data[0]);
      // 舊訊息 (已讀)
      messages.addAll(data[1]);

      // 取得目前已讀訊息 index
      _initialScrollIndex = data[0].isEmpty ? 0 : data[0].length - 1;

      // 訊息列表有資料才更新已讀到最新訊息
      if (messages.isNotEmpty) {
        ChatHelper.updateReadMessage(_args.chatroomId, messages.first.id);
      }

      setState(() {
        _chatMessages = _groupMessages(messages);
        _isLoading = false;

        AlertHelper.dismissLoading();
      });
    });
  }

  /// 更新聊天室
  Future updateChatroom() async {
    // 同步聊天室資料
    await syncChatroom();

    ChatHelper.getChatroomNewMessages(_args.chatroomId, _args.lastestMessageId)
        .then((messages) {
      if (messages.isEmpty) return;

      // 加入訊息
      _chatMessages.insertAll(0, messages);

      // 更新已讀訊息
      final lastestMessageId = messages.first.id;
      ChatHelper.updateReadMessage(_args.chatroomId, lastestMessageId)
          .then((value) {
        if (!value) return;
        _args.lastestMessageId = lastestMessageId;
      });
      setState(() {});
    });
  }

  /// 訊息列表分群
  List<ChatMessage> _groupMessages(List<ChatMessage> messages) {
    var result = <ChatMessage>[];
    // Group by Date
    Map<String, List<ChatMessage>> messageGroups = groupBy(messages, (message) {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(message.createTime);
      final now = DateTime.now();
      return _getDateRange(context, dateTime, now);
    });

    // 整合列表資料
    messageGroups.forEach((dateRange, messageGroup) {
      if (messageGroup.isNotEmpty) {
        messageGroup.last.dateRange = dateRange;
      }
      result.addAll(messageGroup);
    });

    return result;
  }

  @override
  Widget build(BuildContext context) {
    /// 滾動列表 padding size
    const scrollableListPaddingSize = 15.0;
    const bottomIconEdgeInsets = EdgeInsets.only(bottom: 5, right: 15);
    final newMessage =
        _chatMessages.where((e) => e.id > _args.lastestMessageId);
    final double bottomNavBarAdditionalHeight =
        _buttonType == _BottomBtnType.none
            ? MediaQuery.of(context).viewInsets.bottom
            : _bottomAreaHeight;

    return GestureDetector(
      onTap: () => unfocus(context),
      child: Container(
        color: Colors.black,
        child: SafeArea(
          child: Scaffold(
            appBar: AppBar(
              title: Text(_args.chatroomName),
              toolbarHeight: _appBarHeight,
              leading: IconButton(
                icon: const FaIcon(FontAwesomeIcons.chevronCircleLeft),
                onPressed: () {
                  // 返回上一頁
                  Global.navigatorKey.currentState!.customPop();
                },
              ),
              actions: !UserInfo.user!.isTeacher
                  ? null
                  : <Widget>[
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 30),
                        onPressed: () {
                          setState(() {
                            _moreOptions =
                                _getMoreOptions(context, _args.chatroomId);
                            _isMoreOptionVisible = !_isMoreOptionVisible;
                          });
                        },
                      ),
                    ],
              flexibleSpace: generateGradualSpace(
                beginColor: const Color(0xFF299EC9),
                endColor: const Color(0xFF16CCB5),
              ),
            ),
            body: Stack(
              alignment: AlignmentDirectional.bottomStart,
              children: [
                // 訊息列表
                GestureDetector(
                  onTap: () {
                    unfocus(context);

                    setState(() {
                      _isMoreOptionVisible = false;
                      _isStickerPreviewAreaVisible = false;
                      _buttonType = _BottomBtnType.none;
                    });
                  },
                  child: _chatMessages.isEmpty
                      ? const SizedBox.expand()
                      : ScrollablePositionedList.builder(
                          reverse: true,
                          padding: const EdgeInsets.only(
                            top: scrollableListPaddingSize,
                          ),
                          initialScrollIndex: _initialScrollIndex,
                          itemScrollController: _itemScrollController,
                          itemPositionsListener: _itemPositionsListener,
                          itemCount: _chatMessages.length,
                          itemBuilder: (context, index) {
                            // 當前訊息
                            var currentMessage = _chatMessages[index];

                            return Column(
                              children: <Widget>[
                                // 日期間隔
                                currentMessage.dateRange.isEmpty
                                    ? const SizedBox.shrink()
                                    : Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: scrollableListPaddingSize,
                                        ),
                                        child: SizedBox(
                                          height: 35,
                                          child: TextButton(
                                            onPressed: null,
                                            child: Text(
                                              currentMessage.dateRange,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                              ),
                                            ),
                                            style: borderButtonStyle(
                                              Colors.black26,
                                              Colors.transparent,
                                            ),
                                          ),
                                        ),
                                      ),
                                /*
                                 * 從最尾端顯示提醒
                                 * 1. 從未已讀過
                                 * 2. 當前訊息為最舊訊息
                                 */
                                _unreadHint(
                                  context,
                                  _args.lastestMessageId == 0 &&
                                      currentMessage.id ==
                                          _chatMessages.last.id,
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: scrollableListPaddingSize,
                                  ),
                                  child: currentMessage.memberId ==
                                          UserInfo.user!.memberId
                                      ? MyTextBox(
                                          key:
                                              Key(currentMessage.id.toString()),
                                          chatroomId: _args.chatroomId,
                                          chatMessage: currentMessage,
                                        )
                                      : OtherUserTextBox(
                                          key:
                                              Key(currentMessage.id.toString()),
                                          chatroomId: _args.chatroomId,
                                          chatMessage: currentMessage,
                                        ),
                                ),
                                /*
                                 * 從上次已讀的下一則顯示提醒
                                 * 1. 曾經已讀過
                                 * 2. 當前訊息為上次已讀訊息
                                 * 3. 最新訊息非上次已讀訊息
                                 * 4. 最新訊息中不包括自己的訊息
                                 */
                                _unreadHint(
                                  context,
                                  _args.lastestMessageId != 0 &&
                                      currentMessage.id ==
                                          _args.lastestMessageId &&
                                      _chatMessages.first.id !=
                                          _args.lastestMessageId &&
                                      !newMessage
                                          .map((e) => e.memberId)
                                          .contains(UserInfo.user!.memberId),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                // 更多選項區
                !_isMoreOptionVisible
                    ? const SizedBox.shrink()
                    : Align(
                        alignment: Alignment.topRight,
                        child: SizedBox(
                          height: 50,
                          child: DecoratedBox(
                            decoration:
                                const BoxDecoration(color: Colors.black38),
                            child: Column(
                              children: <Widget>[
                                for (var moreOption in _moreOptions)
                                  TextButton(
                                    onPressed: () async {
                                      moreOption.action();

                                      setState(() {
                                        _isMoreOptionVisible = false;
                                      });
                                    },
                                    child: Text(
                                      moreOption.name,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ),
                // 貼圖預覽區
                !_isStickerPreviewAreaVisible
                    ? const SizedBox.shrink()
                    : Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          Stack(
                            children: [
                              Container(
                                color: Colors.black38,
                                height: _stickerPreviewAreaHeight,
                                width: double.infinity,
                              ),
                              Container(
                                height: _stickerPreviewAreaHeight,
                                alignment: const Alignment(1, -1),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() =>
                                        _isStickerPreviewAreaVisible = false);
                                  },
                                  icon: const Icon(Icons.close),
                                ),
                              )
                            ],
                          ),
                          InkWell(
                            onTap: () async {
                              final id = _currentSticker['id'] as int;
                              final imagePath =
                                  _currentSticker['imagePath'].toString();

                              // 重置當前貼圖
                              setState(
                                  () => _isStickerPreviewAreaVisible = false);

                              // 發送貼圖訊息
                              var isSuccess =
                                  await ChatHelper.insertChatroomMessage(
                                _args.chatroomId,
                                imagePath,
                                ChatType.sticker,
                              );

                              // 發送成功後，更新貼圖歷程
                              if (isSuccess) {
                                ChatHelper.updateChatStickerHistory(
                                  id,
                                );
                              }
                              // Todo: 發送失敗處理
                            },
                            child: cachedNetworkImage(
                              '${Global.chatStickerBaseUrl}${_currentSticker['imagePath']}',
                              height: _stickerPreviewAreaHeight,
                            ),
                          ),
                        ],
                      ),
              ],
            ),
            // 訊息至底按鈕
            floatingActionButton:
                // 顯示至底按鈕 & 不顯示貼圖預覽區 (避免與貼圖預覽區重疊)
                _isScrollToEndBtnVisible && !_isStickerPreviewAreaVisible
                    ? ClipOval(
                        child: SizedBox(
                          height: 50,
                          width: 50,
                          child: Material(
                            color: Colors.black26,
                            child: InkWell(
                              onTap: () {
                                _itemScrollController.scrollTo(
                                  index: 0,
                                  duration: const Duration(seconds: 1),
                                );
                              },
                              child: const Icon(
                                Icons.arrow_downward_rounded,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      )
                    : null,
            bottomNavigationBar: Container(
              /*
             * 設定高度
             * 1. 基礎高度 80
             * 2. 鍵盤彈出時的高度 (未彈出為 0)
             * 3. 輸入框內行數高度
             */
              height: 80 +
                  bottomNavBarAdditionalHeight +
                  (_currentTextLine - 1) * 15,
              color: Colors.grey[200],
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        // 底部功能鈕區塊
                        !UserInfo.user!.isTeacher
                            ? const Padding(padding: EdgeInsets.only(left: 15))
                            : Padding(
                                padding: bottomIconEdgeInsets
                                    .add(const EdgeInsets.only(left: 15)),
                                child: circularIcon(
                                  icon: const FaIcon(
                                    FontAwesomeIcons.plus,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  color: const Color(0xFF2CB9B0),
                                  onPressed: () {
                                    unfocus(context);
                                    setState(() {
                                      _buttonType = _BottomBtnType.other;
                                    });
                                  },
                                ),
                              ),
                        Padding(
                          padding: bottomIconEdgeInsets,
                          child: circularIcon(
                            icon: const FaIcon(
                              FontAwesomeIcons.smile,
                              color: Colors.white,
                              size: 20,
                            ),
                            color: const Color(0xFF2CB9B0),
                            onPressed: () {
                              unfocus(context);
                              setState(() {
                                _buttonType = _BottomBtnType.sticker;
                              });
                            },
                          ),
                        ),
                        // 輸入框區塊
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10, top: 15),
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              minLines: 1,
                              maxLines: _textMaxLines,
                              controller: _textController,
                              onTap: () {
                                setState(() {
                                  _isStickerPreviewAreaVisible = false;
                                  _buttonType = _BottomBtnType.none;
                                });
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.white,
                                // 往右偏移 15
                                contentPadding:
                                    const EdgeInsets.only(left: 15, bottom: 15),
                                // 設定圓角
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25.7),
                                ),
                                hintText:
                                    S.of(context).chat_input_bar_placeholder,
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(top: 10),
                                  child: InkWell(
                                    onTap: () async {
                                      final textInput =
                                          _textController.text.trim();
                                      // 若未輸入內容，直接 return
                                      if (textInput.isEmpty) return;
                                      // 清除輸入框內容
                                      _textController.clear();
                                      // 新增聊天室訊息
                                      var isSuccess = await ChatHelper
                                          .insertChatroomMessage(
                                              _args.chatroomId, textInput);

                                      // 傳送失敗，跳出錯誤提示
                                      if (!isSuccess) {
                                        AlertHelper.alert(
                                          context: context,
                                          message: S.of(context).error_hint,
                                        );
                                      }

                                      _itemScrollController.jumpTo(index: 0);
                                    },
                                    child: const FaIcon(
                                      FontAwesomeIcons.solidPaperPlane,
                                      color: Color(0xFF2CB9B0),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // 貼圖區塊
                  _buttonType != _BottomBtnType.sticker
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: StickerArea(
                            bottomAreaHeight: _bottomAreaHeight,
                            previewSticker: (id, imagePath) {
                              setState(() {
                                _isStickerPreviewAreaVisible = true;
                                _currentSticker['id'] = id;
                                _currentSticker['imagePath'] = imagePath;
                              });
                            },
                          ),
                        ),
                  // 額外功能區塊
                  _buttonType != _BottomBtnType.other
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: ExtraFeatureArea(
                            bottomAreaHeight: _bottomAreaHeight,
                            chatroomId: _args.chatroomId,
                            closeBottomArea: () {
                              setState(() {
                                _buttonType = _BottomBtnType.none;
                              });
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 未讀提醒
Widget _unreadHint(BuildContext context, isVisible) {
  return isVisible
      ? Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Text(
            S.of(context).chat_unread_hint,
            style: const TextStyle(color: Colors.grey),
          ),
        )
      : const SizedBox.shrink();
}

/// 取得日期區間
String _getDateRange(BuildContext context, DateTime dateTime, [DateTime? now]) {
  var hintMessage = '';
  now ??= DateTime.now();

  // 一年以上 (年月日)
  if (now.year > dateTime.year) {
    hintMessage = DateFormat.yMMMd(Global.locale).format(dateTime);
    // 不到一年 ~ 超過一天 (月日)
  } else if (now.month > dateTime.month || now.day > dateTime.day + 1) {
    hintMessage = DateFormat.MMMd(Global.locale).format(dateTime);
    // 昨天
  } else if (now.day == dateTime.day + 1) {
    hintMessage = S.of(context).chat_yesterday_message_hint;
    // 今天
  } else if (now.day == dateTime.day) {
    hintMessage = S.of(context).chat_today_message_hint;
  }

  return hintMessage;
}

enum _BottomBtnType { none, other, sticker }

/// 取得更多選項
List<MoreOption> _getMoreOptions(BuildContext context, int chatroomId) {
  return <MoreOption>[
    MoreOption(
      name: S.of(context).chat_user_list,
      action: () async {
        final users = await ChatHelper.getChatroomUsers(chatroomId);

        AlertHelper.showFractionallyDialog(
          context,
          heightFactor: 0.7,
          widthFactor: 0.7,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: <Widget>[
                        Material(
                          child: Text(
                            S.of(context).chat_user_list,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Divider(color: Colors.black54),
                      ],
                    ),
                  ),
                  for (var user in users)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                      child: Row(
                        children: <Widget>[
                          circleAvatar(
                            backgroundImage:
                                CachedNetworkImageProvider(user.imageUrl),
                            radius: 25,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Material(
                              child: Text(
                                user.name,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  ];
}
