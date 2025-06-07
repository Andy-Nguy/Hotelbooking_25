import 'dart:io';
import 'package:flutter_hotelbooking_25/models/datphong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Define your user table name here
const String tableTaiKhoanNguoiDung = 'TaiKhoanNguoiDung';

// Add your database getter or instance here
late final Database database;

Future<int> update(
  String table,
  Map<String, dynamic> values, {
  String? where,
  List<dynamic>? whereArgs,
}) async {
  final db = await database;
  return await db.update(table, values, where: where, whereArgs: whereArgs);
}

Future<int> insertUser(Map<String, dynamic> user) async {
  final db = await database;
  return await db.insert(tableTaiKhoanNguoiDung, user);
}

Future<List<Map<String, dynamic>>> query(
  String table, {
  String? where,
  List<dynamic>? whereArgs,
  List<String>? columns,
}) async {
  final db = await database;
  return await db.query(
    table,
    where: where,
    whereArgs: whereArgs,
    columns: columns,
  );
}

Future<List<Map<String, dynamic>>> rawQuery(
  String sql, [
  List<dynamic>? arguments,
]) async {
  final db = await database;
  return await db.rawQuery(sql, arguments);
}
