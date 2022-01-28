// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:chat/helpers/global_helper.dart';
import 'package:chat/models/userinfo.dart';
import 'package:path/path.dart';

enum HttpMethod { get, post, put, delete }

class APIHelper {
  static const String baseUrl = '';

  /// 呼叫 API
  static Future<Map<String, dynamic>> callAPI(
    HttpMethod httpMethod,
    String apiPath, {
    Map<String, dynamic>? content,
    Map<String, String>? headers,
    int timeoutLimit = 5,
  }) async {
    final client = http.Client();

    try {
      http.Response? response;
      final url = Uri.parse('$baseUrl$apiPath');
      final body = json.encode(content);
      final defaultHeader = {
        'Content-Type': 'application/json; charset=UTF-8',
        'AppAccessToken':
            UserInfo.user == null ? '' : UserInfo.user!.appaccesstoken,
      };

      // 加入基礎 header
      if (headers == null) {
        headers = defaultHeader;
      } else {
        headers = {
          ...defaultHeader,
          ...headers,
        };
      }

      switch (httpMethod) {
        case HttpMethod.get:
          response = await client
              .get(url, headers: headers)
              .timeout(Duration(seconds: timeoutLimit));
          break;
        case HttpMethod.post:
          response = await client
              .post(url, headers: headers, body: body)
              .timeout(Duration(seconds: timeoutLimit));
          break;
        case HttpMethod.put:
          response = await client
              .put(url, headers: headers, body: body)
              .timeout(Duration(seconds: timeoutLimit));
          break;
        case HttpMethod.delete:
          response = await client
              .delete(url, headers: headers, body: body)
              .timeout(Duration(seconds: timeoutLimit));
          break;
        default:
      }

      if (response!.statusCode != 200) {
        print(
            'call API fail, path: $apiPath, status code: ${response.statusCode}, body: ${response.body}');
      }

      final result =
          json.decode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      return result;
    } catch (ex) {
      print('call API fail, path: $apiPath, $ex');
      return {};
    } finally {
      client.close();
    }
  }

  /// 上傳檔案
  static Future<Map<String, dynamic>> uploadFiles(
    List<File> files,
    FileType type,
  ) async {
    try {
      final url =
          Uri.parse('$baseUrl${ApiPath.uploadChatroomFiles}?type=${type.name}');
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'AppAccessToken': UserInfo.user!.appaccesstoken,
      });

      for (var file in files) {
        final stream = http.ByteStream(file.openRead())..cast();
        final length = await file.length();
        final multipartFile = http.MultipartFile(
          type.name,
          stream,
          length,
          filename: basename(file.path),
        );

        request.files.add(multipartFile);
      }

      final response = await request.send();
      final body = await response.stream.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        print('status code: ${response.statusCode}, body: $body');
      }

      final result = jsonDecode(body) as Map<String, dynamic>;
      return result;
    } catch (ex) {
      print('uploadFiles fail, $ex');
      return {};
    }
  }

  static Future<bool> isConnectable() async {
    try {
      final result = await InternetAddress.lookup('https://sso.jyic.net');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }
}

enum FileType { file, image }
