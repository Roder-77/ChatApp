// ignore_for_file: avoid_print
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _database;

  static Future<Database> get db async {
    _database ??= await initializeDatabase();
    return _database!;
  }

  /// 初始化資料庫
  static Future<Database?> initializeDatabase() async {
    try {
      // 取得資料庫路徑
      final databasesPath = join(await getDatabasesPath(), 'db.dat');
      //await deleteDatabase(databasesPath);
      const fileName = 'databaseV';
      // 初始化基本資料庫
      return await openDatabase(
        databasesPath,
        version: 2,
        onCreate: (db, version) async {
          try {
            for (var i = 1; i <= version; i += 1) {
              await _updateDatabase(db, '$fileName$i');
            }
          } catch (ex) {
            print(ex.toString());
          }
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          try {
            if (newVersion > oldVersion) {
              await _updateDatabase(db, '$fileName$newVersion');
            }
          } catch (ex) {
            print(ex.toString());
          }
        },
      );
    } catch (ex) {
      print(ex.toString());
      return null;
    }
  }

  /// 更新資料庫
  static Future _updateDatabase(Database db, String fileName) async {
    var initSql = await rootBundle.loadString('assets/$fileName.dat');

    await db.transaction((txn) async {
      var sqls = initSql.split('\n');
      for (var sql in sqls) {
        if (sql.isNotEmpty) {
          await txn.execute(sql);
        }
      }
    });
  }
}
