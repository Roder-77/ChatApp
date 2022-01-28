import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/generated/l10n.dart';
import 'package:chat/helpers/alert_helper.dart';
import 'package:chat/helpers/chat_helper.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/helpers/image_helper.dart';
import 'package:chat/models/chats/chat_message.dart';
import 'package:chat/src/chats/extraFeatures/red_envelope_history.dart';
import 'package:flutter/material.dart';
import 'package:flutter_link_previewer/flutter_link_previewer.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

/// 自己的訊息
class MyTextBox extends StatelessWidget {
  const MyTextBox({
    Key? key,
    required this.chatroomId,
    required this.chatMessage,
  }) : super(key: key);

  final int chatroomId;
  final ChatMessage chatMessage;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: _messageTime(chatMessage.createTime),
          ),
          Flexible(
            child: MessageBox(
              chatroomId: chatroomId,
              content: chatMessage.message,
              type: chatMessage.type,
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 10),
          ),
        ],
      ),
    );
  }
}

/// 其他成員的訊息
class OtherUserTextBox extends StatelessWidget {
  const OtherUserTextBox({
    Key? key,
    required this.chatroomId,
    required this.chatMessage,
  }) : super(key: key);

  final int chatroomId;
  final ChatMessage chatMessage;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: circleAvatar(
                backgroundImage:
                    CachedNetworkImageProvider(chatMessage.imageUrl),
                radius: 30,
              ),
            ),
          ),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Text(
                    chatMessage.name,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
                MessageBox(
                  chatroomId: chatroomId,
                  content: chatMessage.message,
                  type: chatMessage.type,
                  isSelfMessage: false,
                ),
              ],
            ),
          ),
          _messageTime(chatMessage.createTime, false),
        ],
      ),
    );
  }
}

/// 訊息框
class MessageBox extends StatefulWidget {
  const MessageBox({
    Key? key,
    required this.chatroomId,
    required this.content,
    required this.type,
    this.isSelfMessage = true,
  }) : super(key: key);

  final int chatroomId;
  final String content;
  final int type;
  final bool isSelfMessage;

  @override
  _MessageBoxState createState() => _MessageBoxState();
}

class _MessageBoxState extends State<MessageBox> {
  var chatType = ChatType.text;

  var redEnvelopeId = 0;
  var isRedEnvelopeReceived = false;

  Future init() async {
    chatType = ChatType.values[widget.type];

    if (chatType == ChatType.redEnvelope) {
      redEnvelopeId = int.parse(widget.content);
      isRedEnvelopeReceived =
          await ChatHelper.isRedEnvelopeReceived(redEnvelopeId);
    }

    setState(() {});
  }

  /// 文字訊息
  Widget textMessage() {
    final urlReg = RegExp(
      r'(https?|ftp):\/\/(-\.)?([^\s/?\.#-]+\.?)+(\/[^\s]*)?',
      caseSensitive: true,
      multiLine: true,
    );
    final urls =
        urlReg.allMatches(widget.content).map((m) => m.group(0)!).toList();
    const radiusCircular = Radius.circular(30.0);

    return Column(
      crossAxisAlignment: widget.isSelfMessage
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: widget.isSelfMessage
                ? const Color(0xFFF2F2F2)
                : const Color(0xFFECF7FC),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.only(
              topLeft: widget.isSelfMessage ? radiusCircular : Radius.zero,
              topRight: widget.isSelfMessage ? Radius.zero : radiusCircular,
              bottomLeft: radiusCircular,
              bottomRight: radiusCircular,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Linkify(
              text: widget.content,
              style: const TextStyle(
                color: Colors.black,
              ),
              options: const LinkifyOptions(humanize: false),
              onOpen: (link) async {
                if (!await canLaunch(link.url)) {
                  throw 'Could not launch $link';
                }

                await launch(link.url);
              },
            ),
          ),
        ),
        StatefulBuilder(
          builder: (context, setState) {
            return Column(
              children: [
                for (var url in urls)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                        color: Color(0xFFF7F7F8),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(20),
                        ),
                        child: LinkPreview(
                          width: MediaQuery.of(context).size.width,
                          enableAnimation: false,
                          previewData: Global.linkPreviews[url],
                          text: url,
                          onPreviewDataFetched: (data) async {
                            if (!await canLaunch(url)) return;

                            setState(() {
                              Global.linkPreviews = {
                                ...Global.linkPreviews,
                                url: data,
                              };
                            });
                          },
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  /// 紅包訊息
  Widget redEnvelopeMessage() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 120,
          child: InkWell(
            child: const Image(
              image: AssetImage('assets/images/OpenPocket.png'),
            ),
            onTap: () async {
              // 沒網路的話，直接結束
              if (!Global.hasNetwork) return;
              AlertHelper.showloading();
              // 若為自己發送的紅包，直接前往領取詳情
              if (widget.isSelfMessage) {
                AlertHelper.dismissLoading();
                AlertHelper.showFractionallyDialog(
                  context,
                  child: RedEnvelopeHistory(
                    id: redEnvelopeId,
                  ),
                );
                return;
              }

              // 更新已領取的紅包
              ChatHelper.updateRedEnvelopeReceived(redEnvelopeId).then((value) {
                setState(() {
                  isRedEnvelopeReceived = true;
                });
              });

              // 取得紅包歷程
              final history =
                  await ChatHelper.getRedEnvelopeHistory(redEnvelopeId);

              // 有中過獎，直接顯示紅包中獎資訊 Popup
              if (history != null) {
                AlertHelper.dismissLoading();
                AlertHelper.showFractionallyDialog(
                  context,
                  child: RedEnvelopeResultPopup(
                    redEnvelopeId: redEnvelopeId,
                    points: history.points,
                  ),
                );
                return;
              }

              // 未中過獎，抽紅包
              final points = await ChatHelper.drawRedEnvelope(
                  redEnvelopeId, widget.chatroomId);

              // 未能正確取得點數資料，跳出錯誤提示
              if (points == null) {
                AlertHelper.dismissLoading();
                AlertHelper.alert(
                  context: context,
                  message: S.of(context).error_hint,
                );
                return;
              }

              AlertHelper.dismissLoading();
              // 顯示紅包中獎資訊 Popup
              AlertHelper.showFractionallyDialog(
                context,
                child: RedEnvelopeResultPopup(
                  redEnvelopeId: redEnvelopeId,
                  points: points,
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            !widget.isSelfMessage && isRedEnvelopeReceived
                ? S.of(context).received
                : S.current.click_red_envelope,
            style: const TextStyle(color: Colors.black54),
          ),
        )
      ],
    );
  }

  /// 圖片訊息
  Widget imageMessage() {
    final imagePaths = widget.content.split(',');
    final firstImagePath = imagePaths[0];
    // 預覽數量
    const previewQty = 2;
    // 預覽圖片路徑列表
    final previewImagePaths = imagePaths.take(previewQty).toList();

    return InkWell(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: <Widget>[
          imagePaths.length == 1
              ? Padding(
                  padding: const EdgeInsets.all(2),
                  child: cachedNetworkImage(
                    '${ImageHelper.baseUrl}$firstImagePath',
                    errorWidget: imageErrorWidget(),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    for (var index = 0; index < previewQty; index += 1)
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Container(
                                height: 200,
                                color: Colors.grey[300],
                                child: cachedNetworkImage(
                                  '${ImageHelper.baseUrl}${previewImagePaths[index]}',
                                  fit: BoxFit.cover,
                                  errorWidget: imageErrorWidget(false),
                                ),
                              ),
                              previewImagePaths.last != previewImagePaths[index]
                                  ? const SizedBox.shrink()
                                  : DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.5),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '+${imagePaths.length - 1}',
                                          style: const TextStyle(
                                              fontSize: 30,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
        ],
      ),
      onTap: () async {
        final response =
            await http.head(Uri.parse('${ImageHelper.baseUrl}$firstImagePath'));

        // 若圖片已超過時限，跳提醒
        if (response.statusCode != 200) {
          return AlertHelper.alert(
            context: context,
            message: S.current.file_time_limit_exceeded,
          );
        }

        // 目前圖片路徑 (預設第一張)
        var currentPath = firstImagePath;

        AlertHelper.showFractionallyDialog(
          context,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Stack(
                children: <Widget>[
                  Container(
                    color: Colors.black,
                    height: double.infinity,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex: 4,
                          child: SizedBox(
                            height: double.infinity,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: cachedNetworkImage(
                                '${ImageHelper.baseUrl}$currentPath',
                              ),
                            ),
                          ),
                        ),
                        Flexible(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: <Widget>[
                                for (var imagePath in imagePaths)
                                  Container(
                                    height: 120,
                                    width: 120,
                                    decoration: BoxDecoration(
                                      border: currentPath == imagePath
                                          ? Border.all(color: Colors.white)
                                          : null,
                                    ),
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                      child: InkWell(
                                        child: cachedNetworkImage(
                                          '${ImageHelper.baseUrl}$imagePath',
                                        ),
                                        onTap: () {
                                          setState(() {
                                            currentPath = imagePath;
                                          });
                                        },
                                      ),
                                    ),
                                  )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    alignment: const Alignment(1, -1),
                    child: Material(
                      color: Colors.transparent,
                      child: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Global.navigatorKey.currentState!.pop();
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    init();
  }

  @override
  Widget build(BuildContext context) {
    Widget widgetContent = const SizedBox.shrink();

    switch (chatType) {
      case ChatType.text:
        widgetContent = textMessage();
        break;
      case ChatType.sticker:
        widgetContent = cachedNetworkImage(
          '${Global.chatStickerBaseUrl}${widget.content}',
          height: 170,
          width: 170,
        );
        break;
      case ChatType.redEnvelope:
        widgetContent = redEnvelopeMessage();
        break;
      case ChatType.image:
        widgetContent = imageMessage();
        break;
      default:
        break;
    }

    return widgetContent;
  }
}

/// 訊息時間
Widget _messageTime(int time, [bool isSelfMessage = true]) {
  final dateTime = DateTime.fromMillisecondsSinceEpoch(time);

  return Align(
    alignment: isSelfMessage ? Alignment.bottomRight : Alignment.bottomLeft,
    child: Padding(
      padding: const EdgeInsets.all(10),
      child: Text(DateFormat.jm().format(dateTime)),
    ),
  );
}

/// 紅包中獎資訊 Popup
class RedEnvelopeResultPopup extends StatelessWidget {
  const RedEnvelopeResultPopup({
    Key? key,
    required this.redEnvelopeId,
    required this.points,
  }) : super(key: key);

  final int redEnvelopeId;
  final int points;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: <Widget>[
        const Image(
          image: AssetImage('assets/images/Lottery.png'),
          height: 250,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 100),
          child: Text(
            points > 0
                ? points.toString()
                : S.current.red_envelope_has_been_drawn,
            style: TextStyle(
              color: const Color(0xffBB3B34),
              fontSize: points > 0 ? 48 : 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Text(
            points > 0
                ? S.current.winning_points
                : S.current.please_come_earlier_next_time,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 170),
          child: TextButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                const Color(0xfff3D246),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
              child: Text(
                S.current.received_detail,
                style: const TextStyle(
                  color: Color(0xffBB3B34),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () {
              AlertHelper.showFractionallyDialog(
                context,
                child: RedEnvelopeHistory(
                  id: redEnvelopeId,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 圖片失效顯示用 widget
Widget imageErrorWidget([showWording = true]) {
  return SizedBox(
    height: 300,
    width: 300,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: FaIcon(FontAwesomeIcons.exclamationCircle),
          ),
          showWording
              ? Text(S.current.file_time_limit_exceeded)
              : const SizedBox.shrink(),
        ],
      ),
    ),
  );
}
