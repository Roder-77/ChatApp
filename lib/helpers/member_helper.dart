// ignore_for_file: avoid_print

import 'package:chat/helpers/api_helper.dart';
import 'package:chat/helpers/global_helper.dart';

class MemberHelper {
  /// 新增或更新 device token
  static Future insertOrUpdateDeviceToken() async {
    try {
      final body = {
        'token': Global.token,
      };

      await APIHelper.callAPI(
        HttpMethod.post,
        ApiPath.insertOrUpdateDeviceToken,
        content: body,
      );
    } catch (ex) {
      print('insertOrUpdateDeviceToken fail, $ex');
      return;
    }
  }
}
