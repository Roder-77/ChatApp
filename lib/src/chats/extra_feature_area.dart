import 'dart:io';

import 'package:chat/generated/l10n.dart';
import 'package:chat/helpers/alert_helper.dart';
import 'package:chat/helpers/api_helper.dart';
import 'package:chat/helpers/chat_helper.dart';
import 'package:chat/helpers/file_helper.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/models/chats/chat_extra_feature.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'extraFeatures/red_envelope.dart';

class ExtraFeatureArea extends StatefulWidget {
  const ExtraFeatureArea({
    Key? key,
    required this.bottomAreaHeight,
    required this.chatroomId,
    required this.closeBottomArea,
  }) : super(key: key);

  /// 底部區域高度
  final double bottomAreaHeight;

  /// 聊天室代碼
  final int chatroomId;

  /// 關閉底部區域
  final void Function() closeBottomArea;

  @override
  _ExtraFeatureAreaState createState() => _ExtraFeatureAreaState();
}

class _ExtraFeatureAreaState extends State<ExtraFeatureArea> {
  final rowQuantity = 4;
  final paddingSize = 5.0;
  var extraFeatures = <ChatExtraFeature>[];
  var groupExtraFeatures = [];

  /// 取得額外功能資料
  Future getExtraFeatures() async {
    final result = await ChatHelper.getExtraFeatures();

    extraFeatures = result.map((e) {
      final id = e['id'] as int;
      switch (e['type'] as String) {
        // 紅包
        case 'redEnvelope':
          return ChatExtraFeature(
            id: id,
            name: S.current.red_envelope,
            imagePath: 'assets/images/RedPacket.png',
            action: () {
              widget.closeBottomArea();
              AlertHelper.showFractionallyDialog(
                context,
                child: RedEnvelope(chatroomId: widget.chatroomId),
                heightFactor: 1,
                widthFactor: 1,
              );
            },
          );
        // 上傳圖片
        case 'uploadPicture':
          return ChatExtraFeature(
            id: id,
            name: S.current.picture,
            imagePath: 'assets/images/upload_img.png',
            action: () async {
              // 驗證權限 (相機、照片)
              var permissions = await [
                Permission.camera,
                Permission.photos,
              ].request();

              var statuses = permissions.entries.map((e) => e.value).toList();

              // 任一權限被拒絕、永久拒絕
              if (statuses.any((e) => e.isDenied || e.isPermanentlyDenied)) {
                // 任一權限被永久拒絕
                if (statuses.any((e) => e.isPermanentlyDenied)) {
                  AlertHelper.alert(
                    context: context,
                    message: S.current.please_open_permission(
                        '${S.current.camera}、${S.current.picture}'),
                  );
                }

                return;
              }

              widget.closeBottomArea();
              showUploadPictureBottomSheet();
            },
          );
        default:
          return ChatExtraFeature(
            id: id,
            name: '',
            action: () {},
          );
      }
    }).toList();

    setState(() {
      // 將額外功能依照一行數量上限分組
      groupItemByQuantity(
        groupExtraFeatures,
        extraFeatures,
        rowQuantity,
        ChatExtraFeature(),
      );
    });
  }

  /// 顯示上傳圖片 BottomSheet
  void showUploadPictureBottomSheet() {
    showModalBottomSheet(
        enableDrag: false,
        context: context,
        builder: (context) {
          return SizedBox(
            height: 115,
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_camera),
                  title: Text(S.current.camera),
                  onTap: () async {
                    final files = <File>[];
                    final picker = ImagePicker();
                    final image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxHeight: 1920,
                      maxWidth: 1920,
                      imageQuality: 50,
                    );

                    // 若無圖片資料，直接結束
                    if (image == null) {
                      return;
                    }

                    // close bottom sheet
                    Global.navigatorKey.currentState!.pop();
                    files.add(File(image.path));

                    // 發送失敗，跳提醒
                    if (!await sendFileMessage(
                        widget.chatroomId, files, FileType.image)) {
                      AlertHelper.alert(
                          context: context, message: S.current.error_hint);
                      return;
                    }

                    // 刪除暫存檔
                    FileHelper.deleteTempFiles(files);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text(S.current.picture),
                  onTap: () async {
                    final files = <File>[];
                    final picker = ImagePicker();
                    final images = await picker.pickMultiImage(
                      maxHeight: 1920,
                      maxWidth: 1920,
                      imageQuality: 50,
                    );

                    // 若無圖片資料，直接結束
                    if (images == null || images.isEmpty) {
                      return;
                    }

                    // close bottom sheet
                    Global.navigatorKey.currentState!.pop();

                    for (var image in images) {
                      files.add(File(image.path));
                    }

                    // 發送失敗，跳提醒
                    if (!await sendFileMessage(
                        widget.chatroomId, files, FileType.image)) {
                      AlertHelper.alert(
                          context: context, message: S.current.error_hint);
                    }

                    // 刪除暫存檔
                    FileHelper.deleteTempFiles(files);
                  },
                ),
              ],
            ),
          );
        });
  }

  /// 發送檔案訊息
  Future<bool> sendFileMessage(
    int chatroomId,
    List<File> files,
    FileType fileType,
  ) async {
    AlertHelper.showloading();
    return await ChatHelper.sendFileMessage(chatroomId, files, fileType)
        .then((value) {
      AlertHelper.dismissLoading();
      return value;
    });
  }

  @override
  void initState() {
    super.initState();

    getExtraFeatures();
  }

  @override
  Widget build(BuildContext context) {
    // 寬度 = 手機寬度 / 一行的數量 - 總 padding size
    final width = MediaQuery.of(context).size.width / rowQuantity -
        (rowQuantity + 1) * paddingSize;

    return SizedBox(
      height: widget.bottomAreaHeight,
      child: ListView.builder(
        itemCount: groupExtraFeatures.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                for (ChatExtraFeature feature in groupExtraFeatures[index])
                  feature.isEmpty()
                      ? SizedBox(width: width)
                      : SizedBox(
                          width: width,
                          child: MaterialButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            color: Colors.grey[300],
                            onPressed: feature.action,
                            child: SizedBox(
                              height: 80,
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Image(image: AssetImage(feature.imagePath!)),
                                  Text(
                                    feature.name!,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
              ],
            ),
          );
        },
      ),
    );
  }
}
