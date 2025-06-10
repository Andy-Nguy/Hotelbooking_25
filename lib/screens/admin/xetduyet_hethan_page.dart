import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:intl/intl.dart';

class XetDuyetHetHanPage extends StatefulWidget {
  const XetDuyetHetHanPage({super.key});

  @override
  State<XetDuyetHetHanPage> createState() => _XetDuyetHetHanPageState();
}

class _XetDuyetHetHanPageState extends State<XetDuyetHetHanPage> {
  List<Map<String, dynamic>> _expiredBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpiredBookings();
  }

  Future<void> _loadExpiredBookings() async {
    setState(() => _isLoading = true);
    try {
      final dbHelper = DatabaseHelper.instance;
      _expiredBookings = await dbHelper.getExpiredBookingsToday();
      print('Số lượng bản ghi phòng hết hạn: ${_expiredBookings.length}');
      print('Dữ liệu phòng hết hạn: $_expiredBookings');
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error khi tải phòng hết hạn: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateRoomStatus(
    int idDatPhong,
    int idPhong,
    String soPhong,
  ) async {
    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.updateRoomStatus(idPhong, 1); // Cập nhật phòng thành trống
      await dbHelper.updateBookingStatus(
        idDatPhong,
        'completed',
        DateTime.now().toIso8601String(),
      ); // Cập nhật trạng thái đặt phòng
      await _loadExpiredBookings(); // Làm mới danh sách
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã cập nhật trạng thái phòng $soPhong thành trống'),
        ),
      );
    } catch (e) {
      print('Error khi cập nhật trạng thái: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật: $e')));
    }
  }

  Color _getUrgencyColor(DateTime checkoutTime) {
    final difference = checkoutTime.difference(DateTime.now());
    if (difference.inHours <= 2) return Colors.red;
    if (difference.inHours <= 6) return Colors.orange;
    return Colors.green;
  }

  String _getTimeRemaining(DateTime checkoutTime) {
    final difference = checkoutTime.difference(DateTime.now());
    if (difference.inHours <= 0) return 'Đã hết hạn';
    return '${difference.inHours} giờ ${difference.inMinutes.remainder(60)} phút còn lại';
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return 'N/A VND';

    double amount;
    if (value is String) {
      amount = double.tryParse(value) ?? 0.0;
    } else if (value is num) {
      amount = value.toDouble();
    } else {
      return 'N/A VND';
    }

    final formatter = NumberFormat('#,##0.00', 'vi_VN');
    return '${formatter.format(amount)} VND';
  }

  Widget _buildInfoRow(IconData icon, String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
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
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = DateFormat('dd/MM/yyyy HH:mm');
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _expiredBookings.isEmpty
        ? const Center(
          child: Text(
            'Không có phòng nào hết hạn trong hôm nay.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        )
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _expiredBookings.length,
          itemBuilder: (context, index) {
            final booking = _expiredBookings[index];
            DateTime checkoutTime;
            try {
              checkoutTime = DateTime.parse(booking['NgayTraPhong'] as String);
            } catch (e) {
              print('Lỗi parse NgayTraPhong: ${booking['NgayTraPhong']} - $e');
              checkoutTime = DateTime.now();
            }
            final ngayTraPhong = formatter.format(checkoutTime);
            final urgencyColor = _getUrgencyColor(checkoutTime);
            final timeRemaining = _getTimeRemaining(checkoutTime);

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(Icons.schedule, color: urgencyColor, size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Đặt phòng #${booking['IDDatPhong']}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: urgencyColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: Text(
                            'Phòng ${booking['SoPhong'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Thông tin cơ bản
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            Icons.hotel,
                            'Khách sạn',
                            booking['TenKhachSan'] ?? 'Không xác định',
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildInfoRow(
                            Icons.person,
                            'Người đặt',
                            booking['TenNguoiDat'] ?? 'Không xác định',
                            Colors.green,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Email - full width
                    _buildInfoRow(
                      Icons.email,
                      'Email',
                      booking['EmailNguoiDat'] ?? 'Không có email',
                      Colors.teal,
                    ),

                    const SizedBox(height: 8),

                    // Tổng tiền với format
                    _buildInfoRow(
                      Icons.attach_money,
                      'Tổng tiền',
                      _formatCurrency(booking['TongTien']),
                      Colors.green,
                    ),

                    const SizedBox(height: 16),

                    // Thời gian trả phòng
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: urgencyColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: urgencyColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.event_available,
                                color: urgencyColor,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Thời gian trả phòng',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            ngayTraPhong,
                            style: TextStyle(
                              fontSize: 16,
                              color: urgencyColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            timeRemaining,
                            style: TextStyle(
                              fontSize: 14,
                              color: urgencyColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Button cập nhật
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            () => _updateRoomStatus(
                              booking['IDDatPhong'],
                              booking['IDPhong'],
                              booking['SoPhong'] ?? 'N/A',
                            ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Cập nhật trạng thái phòng trống',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
  }
}
