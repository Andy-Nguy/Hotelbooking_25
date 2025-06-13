import 'dart:io';
import 'package:flutter_hotelbooking_25/db/xylyadmin.dart' as instance;
import 'package:flutter_hotelbooking_25/models/datphong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

Future<List<Map<String, dynamic>>> getAllBookingsDetailed() async {
  final db = await instance.database;
  final result = await db.rawQuery('''
    SELECT 
      dp.IDDatPhong, dp.NgayNhanPhong, dp.NgayTraPhong, dp.SoDem,
      dp.GiaMoiDemKhiDat, dp.TongTien, dp.NgayDatPhong, dp.TrangThai,
      dp.YeuCauDacBiet, dp.MaGiaoDich, nguoidung.HoTen AS TenNguoiDung,
      nguoidung.Email, nguoidung.SoDienThoai AS SoDienThoaiNguoiDung,
      phong.IDPhong, phong.SoPhong, loaiphong.IDLoaiPhong,
      loaiphong.TenLoaiPhong, loaiphong.MoTa AS MoTaLoaiPhong,
      khachsan.IDKhachSan, khachsan.TenKhachSan, khachsan.DiaChi,
      khachsan.ThanhPho, khachsan.SoDienThoaiKhachSan
    FROM DatPhong dp
    INNER JOIN TaiKhoanNguoiDung nguoidung ON dp.IDNguoiDung = nguoidung.IDNguoiDung
    INNER JOIN Phong phong ON dp.IDPhong = phong.IDPhong
    INNER JOIN LoaiPhong loaiphong ON phong.IDLoaiPhong = loaiphong.IDLoaiPhong
    INNER JOIN KhachSan khachsan ON phong.IDKhachSan = khachsan.IDKhachSan
    ORDER BY dp.NgayDatPhong DESC
  ''');
  return result;
}

Future<List<Map<String, dynamic>>> getPaidBookings() async {
  final db = await instance.database;
  try {
    final results = await db.rawQuery('''
      SELECT dp.IDDatPhong, dp.IDNguoiDung, dp.IDPhong, dp.NgayNhanPhong,
             dp.NgayTraPhong, dp.SoDem, dp.GiaMoiDemKhiDat, dp.TongTien,
             dp.NgayDatPhong, dp.TrangThai, dp.YeuCauDacBiet, dp.MaGiaoDich,
             u.HoTen, u.Email, u.SoDienThoai, p.SoPhong, lp.TenLoaiPhong
      FROM DatPhong dp
      LEFT JOIN TaiKhoanNguoiDung u ON dp.IDNguoiDung = u.IDNguoiDung
      LEFT JOIN Phong p ON dp.IDPhong = p.IDPhong
      LEFT JOIN LoaiPhong lp ON p.IDLoaiPhong = lp.IDLoaiPhong
      WHERE dp.TrangThai = 'paid'
    ''');
    print(
      'SQLite: Lấy danh sách đặt phòng đã thanh toán - Tìm thấy ${results.length} bản ghi',
    );
    print('SQLite: Dữ liệu trả về: $results');
    return results;
  } catch (e) {
    print('SQLite: Lỗi khi lấy danh sách đặt phòng đã thanh toán - Lỗi: $e');
    return [];
  }
}

Future<void> updateBookingStatus(
  int idDatPhong,
  String status,
  String? paymentMethod,
) async {
  final db = await instance.database;
  try {
    print(
      'SQLite: Cập nhật trạng thái đặt phòng IDDatPhong: $idDatPhong, trạng thái: $status',
    );
    final result = await db.update(
      'DatPhong',
      {'TrangThai': status},
      where: 'IDDatPhong = ?',
      whereArgs: [idDatPhong],
    );
    print('SQLite: Số hàng bị ảnh hưởng trong updateBookingStatus: $result');
  } catch (e) {
    print('SQLite: Lỗi khi cập nhật trạng thái đặt phòng: $e');
    rethrow;
  }
}
