enum ChatListType {
  users,
  classes,
  myTeachers,
  myClasses,
  all,
}

enum BottomNavBarOption {
  chat,
  users,
  setting,
}

// 按鈕資料
class BorderBotton {
  BorderBotton({
    required this.type,
    required this.text,
    required this.option,
    required this.isSelected,
  });

  final ChatListType type;
  final String text;
  final BottomNavBarOption option;
  late bool isSelected;
}
