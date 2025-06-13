import 'dart:io';
import 'package:flutter_hotelbooking_25/db/xylyadmin.dart' as instance;
import 'package:flutter_hotelbooking_25/db/xylyadmin.dart';
import 'package:flutter_hotelbooking_25/models/datphong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

const String tablePhong =
    'Phong'; // Add this line if tablePhong is not imported
const String tableTienNghiLoaiPhong =
    'TienNghiLoaiPhong'; // Add this line to define the table name
const String tableTienNghi =
    'TienNghi'; // Add this line to define the table name for TienNghi

Future<List<Map<String, dynamic>>> getPhongByLoaiPhong(int idLoaiPhong) async {
  Database db = await database;
  final result = await db.query(
    tablePhong,
    where: 'IDLoaiPhong = ?',
    whereArgs: [idLoaiPhong],
  );
  print("SQLite: Phòng cho IDLoaiPhong $idLoaiPhong: $result");
  return result;
}

Future<Map<String, dynamic>?> getRoomById(int idPhong) async {
  final db = await database;
  try {
    final result = await db.query(
      'Phong',
      where: 'IDPhong = ?',
      whereArgs: [idPhong],
    );
    print(
      'SQLite: Lấy phòng IDPhong: $idPhong - Tìm thấy ${result.length} bản ghi',
    );
    print('SQLite: Dữ liệu trả về: $result');
    return result.isNotEmpty ? result.first : null;
  } catch (e) {
    print('SQLite: Lỗi khi lấy phòng IDPhong: $idPhong - Lỗi: $e');
    return null;
  }
}

Future<List<Map<String, dynamic>>> getTienNghiLoaiPhong(int idLoaiPhong) async {
  Database db = await database;
  final result = await db.rawQuery(
    '''
    SELECT T.IDTienNghi, T.TenTienNghi, T.TenIcon
    FROM $tableTienNghiLoaiPhong RT_A
    JOIN $tableTienNghi T ON RT_A.IDTienNghi = T.IDTienNghi
    WHERE RT_A.IDLoaiPhong = ?
    ''',
    [idLoaiPhong],
  );
  print("SQLite: Tiện nghi loại phòng cho IDLoaiPhong $idLoaiPhong: $result");
  return result;
}
