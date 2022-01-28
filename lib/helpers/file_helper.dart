// ignore_for_file: avoid_print
import "dart:io";

import 'package:path_provider/path_provider.dart';

class FileHelper {
  /// APP 文件路徑
  static Future<String> get _appDocumentPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  /// 暫存路徑
  static Future<String> get _tempPath async {
    final tempDirectory = await getTemporaryDirectory();

    return tempDirectory.path;
  }

  /// 文件是否存在
  static Future<bool> isExists(String fileName, [bool isTemporary = false]) async {
    final path = !isTemporary ? await _appDocumentPath : await _tempPath;
    var file = File('$path/$fileName');
    return file.exists();
  }

  /// 取得文件
  static Future<File> get(String fileName, [bool isTemporary = false]) async {
    final path = !isTemporary ? await _appDocumentPath : await _tempPath;
    return File('$path/$fileName');
  }

  /// 刪除文件
  static Future delete(String fileName, [bool isTemporary = false]) async {
    final path = !isTemporary ? await _appDocumentPath : await _tempPath;
    File('$path/$fileName').delete();
  }

  /// 將字串寫入文件
  static Future writeStringToFile(String fileName, String content, [bool isTemporary = false]) async {
    try {
      final file = await get(fileName, isTemporary);
      await file.writeAsString(content);
    } catch (ex) {
      print('writeStringToFile fail, error: $ex');
    }
  }

  /// 將 Bytes 寫入文件
  static Future writeBytesToFile(String fileName, List<int> content, [bool isTemporary = false]) async {
    try {
      final file = await get(fileName, isTemporary);
      await file.writeAsBytes(content);
    } catch (ex) {
      print('writeBytesToFile fail, error: $ex');
    }
  }

  /// 從文件中讀取字串
  static Future<String> readStringFromFile(String fileName, [bool isTemporary = false]) async {
    try {
      final file = await get(fileName, isTemporary);

      return await file.readAsString();
    } catch (ex) {
      print('readStringFromFile fail, error: $ex');
      // If encountering an error, return 0.
      return "";
    }
  }

  /// 刪除暫存檔案
  static Future deleteTempFile(File file) async {
    final path = await _tempPath;

    if(!file.path.contains(path)) return;
    file.delete();
  }

  /// 刪除多個暫存檔案
  static Future deleteTempFiles(List<File> files) async {
    for (var file in files) {
      await deleteTempFile(file);
    }
  }
}
