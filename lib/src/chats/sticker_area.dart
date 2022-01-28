import 'package:chat/generated/l10n.dart';
import 'package:chat/helpers/chat_helper.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/helpers/image_helper.dart';
import 'package:chat/models/chats/chat_sticker.dart';
import 'package:chat/models/chats/chat_sticker_group.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StickerArea extends StatefulWidget {
  const StickerArea({
    Key? key,
    required this.bottomAreaHeight,
    required this.previewSticker,
  }) : super(key: key);

  final double bottomAreaHeight;
  final void Function(int, String) previewSticker;

  @override
  _StickerAreaState createState() => _StickerAreaState();
}

class _StickerAreaState extends State<StickerArea> {
  final stickerTypeHeight = 40.0;
  final stickerRowQuantity = 4;
  final stickerPaddingSize = 5.0;
  final defaultSelectedColor = Colors.grey[200];
  var isStickerHistorySelected = false;
  var stickerGroups = <ChatStickerGroup>[];
  var groupStickers = [];

  /// 取得貼圖群組資料
  Future getChatStickerGroup() async {
    stickerGroups = await ChatHelper.getChatStickerGroups();
    if (stickerGroups.isEmpty) return;
    // 預設選擇第一組貼圖資料
    final stickers = await ChatHelper.getChatStickers(stickerGroups.first.id);
    // 將貼圖依照一行數量上限分組
    groupItemByQuantity(
      groupStickers,
      stickers,
      stickerRowQuantity,
      ChatSticker(),
    );

    setState(() {
      stickerGroups.first.isSelected = true;
    });
  }

  @override
  void initState() {
    super.initState();

    // 取得貼圖群組資料
    getChatStickerGroup();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        // 貼圖群組區
        SizedBox(
          height: stickerTypeHeight,
          child: Padding(
            padding: const EdgeInsets.only(top: 5, bottom: 5, left: 15),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: <Widget>[
                // 貼圖歷程
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 5, right: 5),
                      child: Align(
                        alignment: Alignment.center,
                        child: InkWell(
                          onTap: () async {
                            // 取得貼圖歷程列表
                            final stickers =
                                await ChatHelper.getChatStickerHistory();
                            // 群組貼圖
                            groupItemByQuantity(
                              groupStickers,
                              stickers,
                              stickerRowQuantity,
                              ChatSticker(),
                            );

                            // 改變貼圖群組選擇狀態
                            setState(() {
                              for (var element in stickerGroups) {
                                element.isSelected = false;
                              }

                              isStickerHistorySelected = true;
                            });
                          },
                          child: FaIcon(FontAwesomeIcons.clock,
                              color: Colors.grey[600]),
                        ),
                      ),
                    ),
                    color: isStickerHistorySelected
                        ? Colors.grey[400]
                        : defaultSelectedColor,
                  ),
                ),
                // 貼圖群組列表
                for (var group in stickerGroups)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Material(
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 5, right: 5),
                        child: Align(
                          alignment: Alignment.center,
                          child: InkWell(
                            onTap: () async {
                              // 取得當前選擇的群組貼圖列表
                              final stickers =
                                  await ChatHelper.getChatStickers(group.id);
                              // 群組貼圖
                              groupItemByQuantity(
                                groupStickers,
                                stickers,
                                stickerRowQuantity,
                                ChatSticker(),
                              );

                              setState(() {
                                // 改變貼圖群組選擇狀態
                                for (var element in stickerGroups) {
                                  element.isSelected = false;
                                }

                                group.isSelected = true;
                                isStickerHistorySelected = false;
                              });
                            },
                            child: cachedNetworkImage(
                              '${Global.chatStickerBaseUrl}${group.imagePath}',
                            ),
                          ),
                        ),
                      ),
                      color: group.isSelected
                          ? Colors.grey[400]
                          : defaultSelectedColor,
                    ),
                  ),
              ],
            ),
          ),
        ),
        // 已選擇的群組對應的貼圖區
        SizedBox(
          height: widget.bottomAreaHeight - stickerTypeHeight,
          child: groupStickers.isEmpty
              ? Center(child: Text(S.of(context).chat_sticker_empty_hint))
              : ListView.builder(
                  itemCount: groupStickers.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(
                        right: stickerPaddingSize,
                      ),
                      child: Row(
                        children: <Widget>[
                          for (ChatSticker sticker in groupStickers[index])
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: stickerPaddingSize,
                                ),
                                child: sticker.id == 0
                                    ? const SizedBox.shrink()
                                    : InkWell(
                                        onTap: () async {
                                          widget.previewSticker(
                                            sticker.id,
                                            sticker.imagePath,
                                          );
                                        },
                                        child: cachedNetworkImage(
                                          '${Global.chatStickerBaseUrl}${sticker.imagePath}',
                                        ),
                                      ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
