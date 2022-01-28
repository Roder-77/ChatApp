import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:chat/generated/l10n.dart';
import 'package:chat/helpers/alert_helper.dart';
import 'package:chat/helpers/chat_helper.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/models/chats/chat_red_envelope_history.dart';
import 'package:chat/models/userinfo.dart';

class RedEnvelopeHistory extends StatefulWidget {
  const RedEnvelopeHistory({
    Key? key,
    required this.id,
  }) : super(key: key);

  final int id;

  @override
  _RedEnvelopeHistoryState createState() => _RedEnvelopeHistoryState();
}

class _RedEnvelopeHistoryState extends State<RedEnvelopeHistory> {
  var histories = <ChatRedEnvelopeHistory>[];

  Future getHistory() async {
    AlertHelper.showloading();
    histories = await ChatHelper.getRedEnvelopeHistories(widget.id);
    AlertHelper.dismissLoading();

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    getHistory();
  }

  /// 歷程列表 widget
  Widget historiesWidget() {
    if (histories.isEmpty) {
      return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: Text(
            S.of(context).red_envelope_history_empty_hint,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: histories.length,
      itemExtent: 75,
      itemBuilder: (context, index) {
        final history = histories[index];
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: history.memberId == UserInfo.user!.memberId
                ? Colors.yellow.withOpacity(0.5)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                child: Text(
                  (index + 1).toString(),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Flexible(
                child: Row(
                  children: <Widget>[
                    circleAvatar(
                      backgroundImage:
                          CachedNetworkImageProvider(history.imageUrl!),
                      radius: 28,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            history.name!,
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          Text(
                            DateFormat('MM/dd a hh:mm').format(
                              DateTime.fromMillisecondsSinceEpoch(
                                history.updateTime,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${history.points} ${S.of(context).point}',
                style: const TextStyle(fontSize: 22),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 55,
          backgroundColor: const Color(0xFFEA5353),
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            S.of(context).received_detail,
            style: const TextStyle(fontSize: 24),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close,
                color: Colors.white,
              ),
            )
          ],
        ),
        body: Container(
          color: const Color(0xFFEA5353),
          child: Column(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 100,
                      width: MediaQuery.of(context).size.width,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEA5353),
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.elliptical(
                              MediaQuery.of(context).size.width,
                              100.0,
                            ),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: 10,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Image(
                      image: AssetImage('assets/images/Point.png'),
                      height: 50,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 9,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: historiesWidget(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
