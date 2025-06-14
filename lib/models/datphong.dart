import 'package:flutter_hotelbooking_25/db/xylyadmin.dart' as instance;

class DatPhong {
  final int id;
  final int idNguoiDung;
  final int idPhong;
  final String ngayNhanPhong;
  final String ngayTraPhong;
  final int soDem;
  final double giaMoiDem;
  final double tongTien;
  final String ngayDatPhong;
  final String trangThai;
  final String? yeuCauDacBiet;
  final String? maGiaoDich;

  DatPhong({
    required this.id,
    required this.idNguoiDung,
    required this.idPhong,
    required this.ngayNhanPhong,
    required this.ngayTraPhong,
    required this.soDem,
    required this.giaMoiDem,
    required this.tongTien,
    required this.ngayDatPhong,
    required this.trangThai,
    this.yeuCauDacBiet,
    this.maGiaoDich,
  });

  factory DatPhong.fromMap(Map<String, dynamic> map) {
    return DatPhong(
      id: map['IDDatPhong'],
      idNguoiDung: map['IDNguoiDung'],
      idPhong: map['IDPhong'],
      ngayNhanPhong: map['NgayNhanPhong'],
      ngayTraPhong: map['NgayTraPhong'],
      soDem: map['SoDem'],
      giaMoiDem: map['GiaMoiDemKhiDat'],
      tongTien: map['TongTien'],
      ngayDatPhong: map['NgayDatPhong'],
      trangThai: map['TrangThai'],
      yeuCauDacBiet: map['YeuCauDacBiet'],
      maGiaoDich: map['MaGiaoDich'],
    );
  }
}

// Future<List<Map<String, dynamic>>> getBookingsForReminder() async {
//   print('Bắt đầu kiểm tra booking để gửi nhắc nhở');
//   final db = await instance.database;
//   try {
//     // Lấy ngày mai dưới định dạng phù hợp với NgayNhanPhong (giả sử định dạng là 'YYYY-MM-DD')
//     final tomorrow = DateTime.now().add(Duration(days: 1));
//     final tomorrowFormatted = tomorrow.toIso8601String().split('T')[0];
//     print('Ngày mai: $tomorrowFormatted');

//     final result = await db.rawQuery(
//       '''
//       SELECT
//         dp.IDDatPhong,
//         dp.NgayNhanPhong,
//         dp.NgayTraPhong,
//         dp.SoDem,
//         dp.TongTien,
//         dp.TrangThai,
//         nguoidung.HoTen AS TenNguoiDung,
//         nguoidung.Email,
//         khachsan.TenKhachSan,
//         khachsan.DiaChi,
//         khachsan.ThanhPho,
//         phong.SoPhong,
//         loaiphong.TenLoaiPhong
//       FROM DatPhong dp
//       INNER JOIN TaiKhoanNguoiDung nguoidung ON dp.IDNguoiDung = nguoidung.IDNguoiDung
//       INNER JOIN Phong phong ON dp.IDPhong = phong.IDPhong
//       INNER JOIN LoaiPhong loaiphong ON phong.IDLoaiPhong = loaiphong.IDLoaiPhong
//       INNER JOIN KhachSan khachsan ON phong.IDKhachSan = khachsan.IDKhachSan
//       WHERE dp.NgayNhanPhong = ? AND dp.TrangThai = 'Đã xác nhận'
//     ''',
//       [tomorrowFormatted],
//     );
//     print('Booking cần nhắc nhở: $result');
//     print('Số lượng booking: ${result.length}');
//     return result;
//   } catch (e) {
//     print('Lỗi khi lấy booking nhắc nhở: $e');
//     return [];
//   }
// }
