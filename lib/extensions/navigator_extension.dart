import 'package:flutter/material.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/src/chats/chatroom.dart';

extension NavigatorExtension on NavigatorState {
  Future<T?> customPushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    if (routeName == Chatroom.routeName) {
      Global.isInChatroom = true;
    }

    await Global.navigatorKey.currentState!.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  Future<T?> customPushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    if (routeName == Chatroom.routeName) {
      Global.isInChatroom = true;
    }

    await Global.navigatorKey.currentState!.pushReplacementNamed(
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  void customPop<T extends Object?>([T? result]) {
    Global.isInChatroom = false;
    Global.navigatorKey.currentState!.pop(result);
  }
}
