import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class XetDuyetMoiScreen extends StatefulWidget {
  const XetDuyetMoiScreen({super.key});

  @override
  State<XetDuyetMoiScreen> createState() => _XetDuyetMoiScreenState();
}

class _XetDuyetMoiScreenState extends State<XetDuyetMoiScreen> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final dbHelper = DatabaseHelper.instance;
      _bookings = await dbHelper.getPaidBookings();
      print('Số lượng bản ghi bookings: ${_bookings.length}');
      print('Dữ liệu bookings: $_bookings');
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error khi tải bookings: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptBooking(int idDatPhong, String email) async {
    try {
      await DatabaseHelper.instance.updateBookingStatus(
        idDatPhong,
        'confirmed',
        null,
      );
      await _sendConfirmationEmail(email, idDatPhong);
      await _loadBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã xác nhận đặt phòng đã thanh toán và gửi email'),
        ),
      );
    } catch (e) {
      print('Error khi chấp nhận booking: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi xác nhận: $e')));
    }
  }

  Future<void> _rejectBooking(int idDatPhong, int idPhong, String email) async {
    try {
      await DatabaseHelper.instance.updateBookingStatus(
        idDatPhong,
        'rejected',
        null,
      );
      await DatabaseHelper.instance.updateRoomStatus(
        idPhong,
        1,
      ); // Trả phòng về trạng thái trống
      await _sendRejectionEmail(email, idDatPhong);
      // Thêm logic hoàn tiền nếu cần (ví dụ: thông báo hoặc API gọi)
      await _loadBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã hủy đặt phòng và trả phòng')),
      );
    } catch (e) {
      print('Error khi từ chối booking: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi hủy: $e')));
    }
  }

  Future<void> _sendConfirmationEmail(String email, int idDatPhong) async {
    try {
      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 587,
        username: 'nguyenhoang26042004@gmail.com', // Thay bằng email của bạn
        password: 'ioqr uhpq jgmu luok ', // Thay bằng App Password 16 ký tự
        ssl: false,
        allowInsecure: false,
      );
      final message =
          Message()
            ..from = Address('your_email@gmail.com', 'Hotel Booking Admin')
            ..recipients.add(email)
            ..subject =
                'Xác nhận đặt phòng đã thanh toán - Mã đặt phòng #$idDatPhong'
            ..text =
                'Chào bạn,\n\nĐặt phòng của bạn với mã #$idDatPhong đã được xác nhận. Chi tiết:\n- Ngày nhận: ${DateTime.now().toIso8601String()}\n- Ngày trả: ${DateTime.now().add(const Duration(days: 1)).toIso8601String()}\nCảm ơn bạn!\n\nTrân trọng,\nĐội ngũ Hotel Booking';

      final sendReport = await send(message, smtpServer);
      print('Email gửi thành công đến $email: $sendReport');
    } catch (e) {
      print('Lỗi khi gửi email: $e');
    }
  }

  Future<void> _sendRejectionEmail(String email, int idDatPhong) async {
    try {
      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 587,
        username: 'nguyenhoang26042004@gmail.com', // Email của bạn
        password: 'ioqr uhpq jgmu luok ', // App password
        ssl: false,
        allowInsecure: false,
      );
      final message =
          Message()
            ..from = Address('your_email@gmail.com', 'Hotel Booking Admin')
            ..recipients.add(email)
            ..subject = 'Thông báo hủy đặt phòng - Mã đặt phòng #$idDatPhong'
            ..text =
                'Chào bạn,\n\n'
                'Đặt phòng của bạn với mã #$idDatPhong đã bị hủy. '
                'Nếu bạn có thắc mắc hoặc cần hỗ trợ thêm, vui lòng liên hệ với chúng tôi.\n\n'
                'Trân trọng,\nĐội ngũ Hotel Booking';

      final sendReport = await send(message, smtpServer);
      print('Email từ chối gửi thành công đến $email: $sendReport');
    } catch (e) {
      print('Lỗi khi gửi email từ chối: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _bookings.isEmpty
        ? const Center(child: Text('Không có đặt phòng đã thanh toán.'))
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _bookings.length,
          itemBuilder: (context, index) {
            final booking = _bookings[index];
            final formatter = DateFormat('dd/MM/yyyy');
            final ngayNhanPhong = formatter.format(
              DateTime.parse(booking['NgayNhanPhong'] as String),
            );
            final ngayTraPhong = formatter.format(
              DateTime.parse(booking['NgayTraPhong'] as String),
            );
            final isApproved =
                booking['TrangThai'] == 'confirmed' ||
                booking['TrangThai'] == 'rejected';
            print('Booking at index $index: ${_bookings[index]}');

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: isApproved ? Colors.yellow[100] : null,
              child: ListTile(
                title: Text('Đặt phòng #${booking['IDDatPhong']}'),
                subtitle: Text(
                  'Khách hàng: ${booking['HoTen'] ?? 'N/A'}\n'
                  'Email: ${booking['Email'] ?? 'N/A'}\n'
                  'Số điện thoại: ${booking['SoDienThoai'] ?? 'N/A'}\n'
                  'Phòng: ${booking['TenLoaiPhong'] ?? 'N/A'}\n'
                  'Số phòng: ${booking['SoPhong'] ?? 'N/A'}\n'
                  'Từ: $ngayNhanPhong đến $ngayTraPhong\n'
                  'Tổng tiền: ${booking['TongTien'] ?? 'N/A'} VND\n'
                  'Trạng thái: ${booking['TrangThai'] ?? 'N/A'}',
                ),
                trailing:
                    booking['TrangThai'] == 'paid'
                        ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check),
                              color: Colors.green,
                              onPressed:
                                  () => _acceptBooking(
                                    booking['IDDatPhong'],
                                    booking['Email'] as String,
                                  ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.cancel),
                              color: Colors.red,
                              onPressed:
                                  () => _rejectBooking(
                                    booking['IDDatPhong'],
                                    booking['IDPhong'] as int,
                                    booking['Email'] as String,
                                  ),
                            ),
                          ],
                        )
                        : null,
              ),
            );
          },
        );
  }
}
