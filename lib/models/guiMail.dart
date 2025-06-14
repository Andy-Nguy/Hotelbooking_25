import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

Future<void> sendReminderEmail(Map<String, dynamic> booking) async {
  print('Bắt đầu gửi email nhắc nhở cho booking ID: ${booking['IDDatPhong']}');
  final smtpServer = gmail(
    'nguyenhoang26042004@gmail.com',
    'ioqr uhpq jgmu luok ',
  );
  // Thay bằng thông tin SMTP của bạn (ví dụ: Gmail, SendGrid)

  final message =
      Message()
        ..from = Address(
          'booking@hotelmanagement.com',
          'Khách sạn JW MARRIOT - Bộ phận Đặt phòng',
        )
        ..recipients.add(booking['Email'])
        ..subject = 'Nhắc nhở: Đặt phòng tại ${booking['TenKhachSan']} ngày mai'
        ..text = '''
Kính gửi ${booking['TenNguoiDung']},

Chúng tôi xin nhắc nhở về đặt phòng của bạn tại ${booking['TenKhachSan']}:
- Mã đặt phòng: ${booking['IDDatPhong']}
- Khách sạn: ${booking['TenKhachSan']}
- Địa chỉ: ${booking['DiaChi']}, ${booking['ThanhPho']}
- Phòng: ${booking['SoPhong']} (${booking['TenLoaiPhong']})
- Ngày nhận phòng: ${booking['NgayNhanPhong']}
- Ngày trả phòng: ${booking['NgayTraPhong']}
- Số đêm: ${booking['SoDem']}
- Tổng tiền: ${booking['TongTien']}

Vui lòng đến đúng giờ để nhận phòng. Nếu có thắc mắc, liên hệ chúng tôi qua email này.

Trân trọng,
Hotel Booking App
    ''';

  try {
    final sendReport = await send(message, smtpServer);
    print('Email nhắc nhở đã gửi đến ${booking['Email']}: $sendReport');
  } catch (e) {
    print('Lỗi khi gửi email nhắc nhở: $e');
  }
}
