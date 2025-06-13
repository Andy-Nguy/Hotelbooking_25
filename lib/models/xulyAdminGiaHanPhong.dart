import 'dart:io';
import 'package:flutter_hotelbooking_25/db/xylyadmin.dart' as instance;
import 'package:flutter_hotelbooking_25/db/xylyadmin.dart';
import 'package:flutter_hotelbooking_25/models/datphong.dart';

// Add the table name for DatPhong if not already defined elsewhere
const String tableDatPhong = 'DatPhong';

Future<List<Map<String, dynamic>>> queryDatPhongForGiaHan() async {
  final db = await database;
  return await db.rawQuery('''
    SELECT DatPhong.*, TaiKhoanNguoiDung.HoTen
    FROM DatPhong
    LEFT JOIN TaiKhoanNguoiDung ON DatPhong.IDNguoiDung = TaiKhoanNguoiDung.IDNguoiDung
    WHERE DatPhong.TrangThai = 'confirmed'
  ''');
}

Future<int> updateGiaHanDatPhong(
  int id,
  String newNgayTraPhong,
  double newTongTien,
  int newSoDem,
) async {
  final db = await database;
  return await db.update(
    tableDatPhong,
    {
      'NgayTraPhong': newNgayTraPhong,
      'TongTien': newTongTien,
      'SoDem': newSoDem,
    },
    where: 'IDDatPhong = ?',
    whereArgs: [id],
  );
}
