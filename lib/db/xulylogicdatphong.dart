import 'package:sqflite/sqflite.dart';
import 'database_helper.dart';

class BookingLogicHandler {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Hàm đặt phòng tạm thời
  Future<int> bookRoomTemp({
    required int idLoaiPhong,
    required int idNguoiDung,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int numberOfGuests,
    required double giaMoiDemKhiDat,
    required double totalCost,
    required Map<String, dynamic> userInfo,
    String? specialRequest,
  }) async {
    final db = await _dbHelper.database;

    // Truy vấn lấy 1 phòng trống theo loại phòng
    final availableRooms = await db.query(
      'Phong',
      where: 'IDLoaiPhong = ? AND DangTrong = 1',
      whereArgs: [idLoaiPhong],
    );

    if (availableRooms.isEmpty) {
      throw Exception('Không có phòng nào còn trống thuộc loại phòng này');
    }

    final idPhong = availableRooms.first['IDPhong'] as int;

    final booking = {
      'IDNguoiDung': idNguoiDung,
      'IDPhong': idPhong,
      'NgayNhanPhong': checkInDate.toIso8601String(),
      'NgayTraPhong': checkOutDate.toIso8601String(),
      'SoDem': checkOutDate.difference(checkInDate).inDays,
      'GiaMoiDemKhiDat': giaMoiDemKhiDat,
      'TongTien': totalCost,
      'YeuCauDacBiet':
          specialRequest?.isNotEmpty == true ? specialRequest : null,
      'TrangThai': 'pending',
    };

    return await db.insert('DatPhong', booking);
  }

  // Hàm lấy thông tin đặt phòng theo ID
  Future<Map<String, dynamic>?> getBookingById(int idDatPhong) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'DatPhong',
      where: 'IDDatPhong = ?',
      whereArgs: [idDatPhong],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Hàm cập nhật trạng thái đặt phòng
  Future<void> updateBookingStatus(
    int idDatPhong,
    String status,
    String? paymentMethod,
  ) async {
    final db = await _dbHelper.database;
    await db.update(
      'DatPhong',
      {
        'TrangThai': status,
        if (paymentMethod != null) 'paymentMethod': paymentMethod,
      },
      where: 'IDDatPhong = ?',
      whereArgs: [idDatPhong],
    );
  }

  // Hàm cập nhật trạng thái phòng
  Future<void> updateRoomStatus(int idPhong, int dangTrong) async {
    final db = await _dbHelper.database;
    await db.update(
      'Phong',
      {'DangTrong': dangTrong},
      where: 'IDPhong = ?',
      whereArgs: [idPhong],
    );
  }

  // Hàm kiểm tra và cập nhật trạng thái phòng hết hạn
  Future<void> updateExpiredBookings() async {
    final db = await _dbHelper.database;
    final now = DateTime.now();

    // Lấy các đặt phòng có trạng thái 'paid'
    final bookings = await db.query(
      'DatPhong',
      where: 'TrangThai = ?',
      whereArgs: ['paid'],
    );

    for (var booking in bookings) {
      final checkOut = DateTime.parse(booking['NgayTraPhong'] as String);
      if (now.isAfter(checkOut)) {
        final idPhong = booking['IDPhong'] as int;

        // Kiểm tra xem phòng có đặt phòng nào khác đang hoạt động không
        final activeBookings = await db.query(
          'DatPhong',
          where: 'IDPhong = ? AND TrangThai = ? AND NgayTraPhong > ?',
          whereArgs: [idPhong, 'paid', now.toIso8601String()],
        );

        if (activeBookings.isEmpty) {
          // Không có đặt phòng nào khác, cập nhật trạng thái phòng thành 'trống'
          await updateRoomStatus(idPhong, 1);
        }

        // Cập nhật trạng thái đặt phòng thành 'completed'
        await updateBookingStatus(
          booking['IDDatPhong'] as int,
          'completed',
          null,
        );
      }
    }
  }
}
