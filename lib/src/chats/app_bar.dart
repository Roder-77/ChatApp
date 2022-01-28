import 'package:chat/generated/l10n.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/models/botton_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const appBarHeight = 120.0;
const defaultChatListType = ChatListType.all;

class ChatAppBar extends StatefulWidget with PreferredSizeWidget {
  ChatAppBar({
    Key? key,
    required this.option,
    required this.emitSeletedBtn,
  }) : super(key: key);

  final BottomNavBarOption option;
  final void Function(dynamic) emitSeletedBtn;
  bool get isChatList {
    return option == BottomNavBarOption.chat;
  }

  @override
  ChatAppBarState createState() => ChatAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(isChatList ? 56.0 : appBarHeight);
}

class ChatAppBarState extends State<ChatAppBar> {
  var _allBorderButton = <BorderBotton>[];
  var _borderBottons = <BorderBotton>[];
  var _borderBtnType = defaultChatListType;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      _allBorderButton = _getAllBorderBottons(context);
      getCurrentButtons();
    });
  }

  // 按鈕列表
  List<Widget> borderButton(ChatListType type, String text, bool isSelected) {
    // set border btn style
    final _borderBtnBackgroundColor =
        isSelected ? Colors.white : Colors.transparent;
    final _borderStyle =
        borderButtonStyle(_borderBtnBackgroundColor, Colors.white);

    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 10),
        child: TextButton(
          child: Text(
            text,
            style: TextStyle(color: isSelected ? Colors.blue : Colors.white),
          ),
          style: _borderStyle,
          onPressed: () {
            // 先取消所有按鈕選擇樣式
            for (var botton in _borderBottons) {
              botton.isSelected = false;
            }

            setState(() {
              // 選擇的按鈕套上選擇樣式
              _borderBottons
                  .firstWhere((botton) => botton.type == type)
                  .isSelected = true;
            });

            _borderBtnType = type;
            // 傳出選擇的按鈕
            widget.emitSeletedBtn(type);
          },
        ),
      ),
    ];
  }

  // 取得當前的按鈕列表
  void getCurrentButtons() {
    setState(() {
      _borderBottons =
          _allBorderButton.where((x) => x.option == widget.option).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    getCurrentButtons();

    return PreferredSize(
      preferredSize: const Size.fromHeight(appBarHeight),
      child: AppBar(
        toolbarHeight: 56,
        centerTitle: true,
        title: Text(
          S.of(context).chat_title,
          textAlign: TextAlign.center,
        ),
        leading: IconButton(
          icon: const FaIcon(FontAwesomeIcons.chevronCircleLeft),
          onPressed: () {
            // 返回上一頁
            Global.navigatorKey.currentState!.pop();
          },
        ),
        flexibleSpace: generateGradualSpace(
          beginColor: const Color(0xFF299EC9),
          endColor: const Color(0xFF16CCB5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            // 顯示搜尋框時，隱藏 border btn 區塊
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Padding(padding: EdgeInsets.only(left: 10)),
                    for (var button in _borderBottons)
                      ...borderButton(
                          button.type, button.text, button.isSelected),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 搜尋框
Widget searchBar(
    BuildContext context, BottomNavBarOption option, ChatListType type) {
  const textfieldDimension = 44.0;

  return SizedBox(
    width: MediaQuery.of(context).size.width - 30,
    height: textfieldDimension,
    child: TextField(
      decoration: InputDecoration(
        // 設定內容背景色
        filled: true,
        fillColor: Colors.white,
        // 往右偏移 15
        contentPadding: const EdgeInsets.only(left: 15),
        // 設定圓角
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25.7),
        ),
        hintText: S.of(context).chat_search_bar_placeholder,
        suffix: IconButton(
          // 往左邊偏移 10，設定內容高度為輸入框的一半
          padding: const EdgeInsets.only(
            right: 10.0,
            bottom: textfieldDimension / 2,
          ),
          icon: FaIcon(
            FontAwesomeIcons.search,
            color: Colors.grey[400],
            size: 18,
          ),
          onPressed: null,
        ),
      ),
      onSubmitted: (input) {
        if (option == BottomNavBarOption.chat) {
          // Todo: 搜尋訊息列表
        } else if (option == BottomNavBarOption.users) {
          // Todo: 搜尋成員列表
        }
      },
    ),
  );
}

// 取得所有 border buttons
List<BorderBotton> _getAllBorderBottons(BuildContext context) {
  return [
    BorderBotton(
      type: ChatListType.myTeachers,
      text: S.of(context).chat_my_teacher,
      option: BottomNavBarOption.users,
      isSelected: true,
    ),
    BorderBotton(
      type: ChatListType.myClasses,
      text: S.of(context).chat_my_class,
      option: BottomNavBarOption.users,
      isSelected: false,
    ),
  ];
}
