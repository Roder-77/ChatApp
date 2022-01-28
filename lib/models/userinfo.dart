import 'dart:convert';

import 'package:chat/helpers/api_helper.dart';
import 'package:chat/helpers/file_helper.dart';
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/models/school.dart';

class UserInfo {
  static UserInfo? user;
  String memberId = '';
  String name = '';
  String mobile = '';
  String email = '';
  String appaccesstoken = '';
  School schoolData = School();
  bool suspended = false;
  bool isAdministrator = false;
  bool isTeacher = false;
  bool isStudent = false;
  double points = 0;

  /// 讀取使用者資料
  static Future loadUser() async {
    await FileHelper.readStringFromFile('user.data', true).then((jsonstring) {
      var userdata = jsonDecode(jsonstring);
      user ??= UserInfo();
      user!.memberId = userdata['memberId'].toString();
      user!.name = userdata['name'].toString();
      user!.mobile = userdata['mobile'].toString();
      user!.email = userdata['email'].toString();
      user!.schoolData = School();
      user!.schoolData.schoolId = userdata['school']['schoolId'].toString();
      user!.schoolData.schoolName = userdata['school']['schoolName'].toString();
      user!.schoolData.department = userdata['school']['department'].toString();
      user!.appaccesstoken = userdata['appaccesstoken'].toString();
      user!.suspended = userdata['suspended'] as bool;
      user!.isAdministrator = userdata['isAdministrator'] as bool;
      user!.isTeacher = userdata['isTeacher'] as bool;
      user!.isStudent = userdata['isStudent'] as bool;
      user!.points = userdata['points'] as double;
    });
  }

  /// 更新使用者資料
  static Future updateUser() async {
    await FileHelper.readStringFromFile('user.data', true)
        .then((jsonstring) async {
      var userdata = jsonDecode(jsonstring);
      final headers = {'AppAccessToken': userdata['appaccesstoken'].toString()};

      var result = await APIHelper.callAPI(
        HttpMethod.get,
        ApiPath.getMember,
        headers: headers,
      );

      if (result['status'] != 200) {
        // ignore: avoid_print
        print(result['message']);
        return;
      }

      List<dynamic> data = result['data'];

      // 載入並保存使用者基本資料
      await FileHelper.writeStringToFile(
        'user.data',
        data[0],
        true,
      );
    });
  }
}
