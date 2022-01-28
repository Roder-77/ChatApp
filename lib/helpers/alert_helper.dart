import 'package:chat/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AlertHelper {
  /// 提醒框
  static Future alert({
    required BuildContext context,
    String? title,
    required String message,
    List<Widget>? actions,
  }) {
    title ??= S.current.chat_message;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title!),
          content: Text(message),
          actions: actions,
        );
      },
    );
  }

  /// 顯示指定寬高比例對話框
  static void showFractionallyDialog(BuildContext context,
      {required Widget child, double? heightFactor, double? widthFactor}) {
    showDialog(
      context: context,
      builder: (context) {
        if (heightFactor == null || widthFactor == null) {
          return child;
        }

        return FractionallySizedBox(
          heightFactor: heightFactor,
          widthFactor: widthFactor,
          child: child,
        );
      },
    );
  }

  /// loading 配置
  static void configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..indicatorSize = 45.0
      ..loadingStyle = EasyLoadingStyle.dark
      ..radius = 10.0
      ..userInteractions = true
      ..dismissOnTap = false;
  }

  /// 顯示 Loading
  static Future<void> showloading([status = 'loading...']) async {
    await EasyLoading.show(status: status);
  }

  /// 關閉 loading
  static Future<void> dismissLoading() async {
    await EasyLoading.dismiss();
  }
}
