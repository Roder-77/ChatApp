import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chat/generated/l10n.dart';
import 'package:chat/helpers/alert_helper.dart';
import 'package:chat/helpers/chat_helper.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/models/chats/chat_user.dart';
import 'package:chat/models/userinfo.dart';

class RedEnvelope extends StatefulWidget {
  const RedEnvelope({
    Key? key,
    required this.chatroomId,
  }) : super(key: key);

  final int chatroomId;

  @override
  _RedEnvelopeState createState() => _RedEnvelopeState();
}

class _RedEnvelopeState extends State<RedEnvelope> {
  final textController = TextEditingController();
  final dropdownRowHeight = 60.0;
  final randomRedEnvelopeMinPoints = 100;
  final types = [S.current.normal_red_envelope, S.current.radom_red_envelope];
  var selectedType = S.current.normal_red_envelope;
  var selectedQuantity = 1;
  var selectedPoints = 0;
  var totalPoints = 0;
  var users = <ChatUser>[];

  /// 成員數量 (不包含自己)
  int get userQuantity {
    return users.length - 1;
  }

  /// 是否為手氣紅包
  bool get isRandomRedEnvelope {
    return selectedType == S.current.radom_red_envelope;
  }

  /// 數量、點數是否有效
  bool get isQuantityValid {
    return !isRandomRedEnvelope || selectedQuantity <= selectedPoints;
  }

  /// 是否超過最小點數
  bool get isOverMinPoints {
    return !isRandomRedEnvelope || selectedPoints >= randomRedEnvelopeMinPoints;
  }

  /// 是否有餘額
  bool get isInsufficientBalance {
    return UserInfo.user!.points < totalPoints;
  }

  /// 是否啟用發送鈕
  bool get isSendBtnEnable {
    return totalPoints != 0 &&
        isQuantityValid &&
        isOverMinPoints &&
        !isInsufficientBalance;
  }

  /// 計算總點數
  int calculateTotalPoint() {
    if (isRandomRedEnvelope) return selectedPoints;
    return selectedQuantity * selectedPoints;
  }

  /// 設定總點數
  void setTotalPoints(int points) {
    final min = selectedQuantity > randomRedEnvelopeMinPoints
        ? selectedQuantity
        : randomRedEnvelopeMinPoints;

    // 總點數不能低於最小值
    if (points < min) {
      textController.text = min.toString();
      selectedPoints = min;
      return;
    }

    selectedPoints = points;
  }

  @override
  void initState() {
    super.initState();

    // 更新使用者資料、取得聊天室成員列表
    Future.wait([
      UserInfo.updateUser(),
      ChatHelper.getChatroomUsers(widget.chatroomId)
    ]).then((data) async {
      // 取得使用者資料
      await UserInfo.loadUser();

      setState(() {
        users = data[1];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          toolbarHeight: 80,
          backgroundColor: Colors.grey[200],
          shadowColor: Colors.transparent,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            S.of(context).red_envelope,
            style: const TextStyle(color: Colors.black),
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.close,
                color: Colors.black,
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(15),
                child: generateDropdown<String>(
                  labelText: S.of(context).red_envelope_type,
                  hintText: S.of(context).please_choose,
                  fillColor: Colors.grey[100],
                  items: types,
                  selectedItem: selectedType,
                  maxHeight: dropdownRowHeight * types.length,
                  onChanged: (type) {
                    setState(() {
                      selectedType = type!;
                      // 切換類型時重置其他兩欄
                      selectedQuantity = 1;

                      if (isRandomRedEnvelope) {
                        selectedPoints = randomRedEnvelopeMinPoints;
                        textController.text =
                            randomRedEnvelopeMinPoints.toString();
                      } else {
                        selectedPoints = 0;
                        textController.text = '';
                      }

                      totalPoints = calculateTotalPoint();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: generateDropdown<int>(
                  labelText: S.of(context).red_envelope_quantity,
                  hintText: S.of(context).please_choose,
                  helperText: S.of(context).chatroom_total_user(users.length),
                  errorText: !isQuantityValid
                      ? S.of(context).radom_red_envelope_quantity_limit
                      : null,
                  fillColor: Colors.grey[100],
                  items: [for (var i = 1; i <= userQuantity; i += 1) i],
                  selectedItem: selectedQuantity,
                  maxHeight: userQuantity <= 3
                      ? dropdownRowHeight * (userQuantity + 1)
                      : null,
                  showSearchBox: true,
                  searchBoxLabelText: S.of(context).please_enter_number,
                  compareFn: (a, b) => a == b,
                  onChanged: (quantity) {
                    setState(() {
                      selectedQuantity = quantity!;
                      totalPoints = calculateTotalPoint();
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: TextField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter(RegExp("[0-9]"), allow: true),
                  ],
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: isRandomRedEnvelope
                        ? S.of(context).total_point
                        : S.of(context).point_of_red_envelope,
                    hintText: S.of(context).please_enter,
                    errorText: !isOverMinPoints
                        ? S.of(context).radom_red_envelope_min_points(
                            randomRedEnvelopeMinPoints)
                        : null,
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedPoints = value.isEmpty ? 0 : int.parse(value);
                      totalPoints = calculateTotalPoint();
                    });
                  },
                  onEditingComplete: () {
                    unfocus(context);
                    // 非手氣紅包，直接結束
                    if (!isRandomRedEnvelope) return;
                    // 選擇的點數 >= 手氣紅包最小點數，直接結束
                    if (selectedPoints >= randomRedEnvelopeMinPoints) return;

                    // 設定為手氣紅包最小點數
                    selectedPoints = randomRedEnvelopeMinPoints;
                    textController.text = randomRedEnvelopeMinPoints.toString();
                    totalPoints = calculateTotalPoint();
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(right: 10),
                      height: 60,
                      child: const Image(
                        image: AssetImage('assets/images/Point.png'),
                      ),
                    ),
                    Text(
                      totalPoints.toString(),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      S
                          .of(context)
                          .point_balance(UserInfo.user!.points.toInt()),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    isInsufficientBalance
                        ? Text(
                            ' (${S.of(context).insufficient_balance})',
                            style: const TextStyle(color: Colors.red),
                          )
                        : const SizedBox.shrink()
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 20),
                child: MaterialButton(
                  height: 50,
                  minWidth: 150,
                  color: const Color(0xFF2CB9B0),
                  textColor: Colors.white,
                  disabledElevation: 1,
                  disabledColor: Colors.black45,
                  disabledTextColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    S.of(context).send_red_envelope,
                    style: const TextStyle(fontSize: 20),
                  ),
                  onPressed: !isSendBtnEnable
                      ? null
                      : () async {
                          final type = isRandomRedEnvelope ? 1 : 0;
                          final isSuccess = await ChatHelper.createRedEnvelope(
                            widget.chatroomId,
                            type,
                            selectedQuantity,
                            totalPoints,
                          );

                          // 建立紅包成功，回到聊天室
                          if (isSuccess) {
                            Navigator.pop(context);
                            return;
                          }

                          // 建立紅包失敗，跳出錯誤提示
                          AlertHelper.alert(
                            context: context,
                            message: S.of(context).error_hint,
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
