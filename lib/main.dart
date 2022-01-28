import 'dart:async';
import 'dart:io';

import 'package:another_flushbar/flushbar.dart';
import 'package:connectivity/connectivity.dart';
import 'package:chat/extensions/navigator_extension.dart';
import 'package:chat/generated/l10n.dart';
import 'package:chat/helpers/alert_helper.dart';
import 'package:chat/helpers/chat_helper.dart';
import 'package:chat/helpers/database_sync_helper.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/helpers/member_helper.dart';
import 'package:chat/models/notification_model.dart';
import 'package:chat/src/chats/chats.dart';
import 'package:chat/src/chats/chatroom.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rxdart/subjects.dart';

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String?> selectNotificationSubject =
    BehaviorSubject<String?>();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 設置 loading
  AlertHelper.configLoading();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  }

  await Firebase.initializeApp();

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const initializationSettingsAndroid =
      AndroidInitializationSettings('@ic_launcher');
  final initializationSettingsIOS = IOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
    onDidReceiveLocalNotification: (
      int id,
      String? title,
      String? body,
      String? payload,
    ) async {
      didReceiveLocalNotificationSubject.add(
        ReceivedNotification(
          id: id,
          title: title,
          body: body,
          payload: payload,
        ),
      );
    },
  );

  final initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (String? payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }

      selectNotificationSubject.add(payload);
    },
  );

  if (!kIsWeb) {
    // 設定安卓通知頻道
    channel = _setAndroidNotificationChannel();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: Global.navigatorKey,
      // 多語系初始化
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'Chat APP',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ChatApp(),
      routes: <String, WidgetBuilder>{
        Chat.routeName: (context) => const Chat(),
        Chatroom.routeName: (context) => const Chatroom(),
      },
      builder: EasyLoading.init(),
    );
  }
}

class ChatApp extends StatefulWidget {
  const ChatApp({Key? key}) : super(key: key);

  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> {
  var status = StartupStatus.login;
  late StreamSubscription<ConnectivityResult> connectivitySubscription;
  final flush = Flushbar(
    flushbarPosition: FlushbarPosition.TOP,
    icon: const Padding(
      padding: EdgeInsets.only(left: 10),
      child: FaIcon(FontAwesomeIcons.exclamationCircle, color: Colors.white),
    ),
    message: S.current.no_signal,
    messageSize: 18,
    backgroundColor: Colors.black54,
  );

  /// IOS 端接收到通知
  void _configureDidReceiveLocalNotificationSubject() {
    didReceiveLocalNotificationSubject.stream
        .listen((receivedNotification) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: receivedNotification.title != null
              ? Text(receivedNotification.title!)
              : null,
          content: receivedNotification.body != null
              ? Text(receivedNotification.body!)
              : null,
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                // 前往聊天室
                await _goChatroom(receivedNotification.payload);
              },
              child: const Text('Ok'),
            )
          ],
        ),
      );
    });
  }

  /// 監聽通知被點擊的事件
  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String? payload) async {
      await _goChatroom(payload);
    });
  }

  @override
  void initState() {
    super.initState();

    // 取得系統語系
    Global.locale = Platform.localeName;
    // 初始化日期時區
    initializeDateFormatting(Global.locale, null);

    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      Global.hasNetwork = result != ConnectivityResult.none;
      // 無網路服務時，顯示提醒列
      if (result == ConnectivityResult.none) {
        flush.show(context);
        return;
      }

      flush.dismiss(true);
    });

    // 請求 FCM 權限
    FirebaseMessaging.instance.requestPermission().then((value) async {
      // 取得 Firebase token
      FirebaseMessaging.instance.getToken().then((token) {
        Global.token = token!;
      });

      // Firebase Token Refresh 時，更新 Device token
      FirebaseMessaging.instance.onTokenRefresh.listen((_) async {
        MemberHelper.insertOrUpdateDeviceToken();
      });
    });

    // 初始化 Firebase 訊息事件
    _initFirebaseMessagingEvent(context);
    _configureSelectNotificationSubject();
    if (Platform.isIOS) {
      _configureDidReceiveLocalNotificationSubject();
    }
  }

  @override
  void dispose() {
    didReceiveLocalNotificationSubject.close();
    selectNotificationSubject.close();
    connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Chat();
  }
}

enum StartupStatus { login, loggedIn, suspended }

/// 設定安卓通知頻道
AndroidNotificationChannel _setAndroidNotificationChannel() {
  return const AndroidNotificationChannel(
    'chat_channel',
    'notifications',
    description: 'This channel is used for chat notifications.',
    importance: Importance.max,
  );
}

/// Firebase 背景訊息事件
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
  // 設定安卓通知頻道
  channel = _setAndroidNotificationChannel();
  // 顯示本地通知
  showLocalNotification(message);
}

/// 初始化 Firebase 訊息事件
void _initFirebaseMessagingEvent(BuildContext context) {
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    if (message.data.isEmpty) return;

    final routeName = getCurrentRouteName();

    // 當前位置在一群通 (聊天室列表)
    if (routeName == Chat.routeName) {
      // 同步聊天室訊息
      DatabaseSyncHelper.syncChatroomMessage(message.data).then((_) async {
        // 刷新聊天室列表
        ChatState.refreshChatList();
      });
    }
    // 當前位置在聊天室
    else if (routeName == Chatroom.routeName || Global.isInChatroom) {
      // 與推播訊息非同個聊天室，直接結束
      if (int.parse(message.data['chatroomId']) != ChatroomState.chatroomId) {
        return;
      }

      // 同步聊天室訊息
      DatabaseSyncHelper.syncChatroomMessage(message.data).then((_) async {
        // 取得聊天室訊息
        final chatMessage = await ChatHelper.getChatroomMessage(
            int.parse(message.data['chatroomId']),
            int.parse(message.data['id']));
        // 找不到對應訊息，直接結束
        if (chatMessage == null) return;
        // 聊天室新增訊息
        ChatroomState.insertMessage(chatMessage);
      });

      // 不觸發後續動作 (本地通知)，直接結束
      return;
    }

    // 顯示本地通知
    showLocalNotification(message);
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    // 前往聊天室
    await _goChatroom(message.data['chatroomId']);
  });
}

/// 前往聊天室
Future _goChatroom(String? payload) async {
  final routeName = getCurrentRouteName();
  // 若 payload 為空或當前位置在聊天室，直接結束
  if (payload == null || payload.isEmpty || routeName == Chatroom.routeName) {
    return;
  }

  // 同步聊天室列表
  await DatabaseSyncHelper.syncChatrooms();
  // 取得聊天室資料
  final chatroom = await ChatHelper.getChatroom(int.parse(payload));
  // 前往對應的聊天室
  await Global.navigatorKey.currentState!.customPushNamed(
    Chatroom.routeName,
    arguments: ChatroomArguments(
      chatroom!.name,
      chatroom.id,
      chatroom.lastestMessageId,
    ),
  );
}

/// 顯示本地通知
void showLocalNotification(RemoteMessage message) {
  RemoteNotification? notification = message.notification;
  AndroidNotification? android = notification?.android;

  // 無通知或非安卓，直接結束
  if (notification == null || android == null) return;

  // If `onMessage` is triggered with a notification, construct our own
  // local notification to show to users using the created channel.
  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    notification.title,
    notification.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        icon: android.smallIcon,
      ),
    ),
    payload: message.data['chatroomId'],
  );
}
