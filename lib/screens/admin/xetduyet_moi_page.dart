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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Đã xác nhận đặt phòng và gửi email thành công'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      print('Error khi chấp nhận booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Lỗi khi xác nhận: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.cancel, color: Colors.white),
              SizedBox(width: 8),
              Text('Đã hủy đặt phòng và trả phòng thành công'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      print('Error khi từ chối booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Lỗi khi hủy: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
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
            ..from = Address(
              'nguyenhoang26042004@gmail.com',
              'Hotel Booking Admin',
            )
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
            ..from = Address(
              'nguyenhoang26042004@gmail.com',
              'Hotel Booking Admin',
            )
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'paid':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'confirmed':
        return 'Đã xác nhận';
      case 'rejected':
        return 'Đã từ chối';
      case 'paid':
        return 'Đã thanh toán';
      default:
        return status;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmed':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'paid':
        return Icons.payment;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Xét Duyệt Đặt Phòng',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.blue[700],
        elevation: 0,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.refresh, color: Colors.white),
        //     onPressed: _loadBookings,
        //   ),
        // ],
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải dữ liệu...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : _bookings.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inbox, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Không có đặt phòng nào cần xét duyệt',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kéo xuống để làm mới',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _loadBookings,
                child: ListView.builder(
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
                    final status = booking['TrangThai'] as String;
                    final isApproved =
                        status == 'confirmed' || status == 'rejected';

                    print('Booking at index $index: ${_bookings[index]}');

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border:
                            isApproved
                                ? Border.all(
                                  color: _getStatusColor(
                                    status,
                                  ).withOpacity(0.3),
                                  width: 2,
                                )
                                : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.hotel,
                                    color: Colors.blue[700],
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Đặt phòng #${booking['IDDatPhong']}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            _getStatusIcon(status),
                                            size: 16,
                                            color: _getStatusColor(status),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            _getStatusText(status),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: _getStatusColor(status),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Content
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Customer Info
                                _buildInfoRow(
                                  icon: Icons.person,
                                  title: 'Khách hàng',
                                  value: booking['HoTen'] ?? 'N/A',
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.email,
                                  title: 'Email',
                                  value: booking['Email'] ?? 'N/A',
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.phone,
                                  title: 'Số điện thoại',
                                  value: booking['SoDienThoai'] ?? 'N/A',
                                ),

                                const Divider(height: 32),

                                // Room Info
                                _buildInfoRow(
                                  icon: Icons.room_service,
                                  title: 'Loại phòng',
                                  value: booking['TenLoaiPhong'] ?? 'N/A',
                                ),
                                const SizedBox(height: 12),
                                _buildInfoRow(
                                  icon: Icons.door_front_door,
                                  title: 'Số phòng',
                                  value:
                                      booking['SoPhong']?.toString() ?? 'N/A',
                                ),

                                const Divider(height: 32),

                                // Booking Details
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildDateCard(
                                        'Ngày nhận',
                                        ngayNhanPhong,
                                        Icons.login,
                                        Colors.green,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildDateCard(
                                        'Ngày trả',
                                        ngayTraPhong,
                                        Icons.logout,
                                        Colors.orange,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),

                                // Total Amount
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.blue[200]!,
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        color: Colors.blue[700],
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Tổng tiền: ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${(booking['TongTien'] as num).toStringAsFixed(3)} VND',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.blue[700],
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Action Buttons
                          if (status == 'paid')
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          () => _acceptBooking(
                                            booking['IDDatPhong'],
                                            booking['Email'] as String,
                                          ),
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Chấp nhận',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed:
                                          () => _rejectBooking(
                                            booking['IDDatPhong'],
                                            booking['IDPhong'] as int,
                                            booking['Email'] as String,
                                          ),
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                      label: const Text(
                                        'Từ chối',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: Colors.grey[600]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateCard(String title, String date, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
