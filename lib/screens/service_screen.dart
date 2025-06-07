import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceScreen extends StatefulWidget {
  final bool hasBooking; // Tham số hasBooking từ MainScreen
  const ServiceScreen({super.key, required this.hasBooking});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  List<Map<String, dynamic>> _bookingList = [];
  bool _isLoading = true;
  bool _isLoggedIn = false; // Thêm trạng thái đăng nhập

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Kiểm tra trạng thái đăng nhập trước
  }

  // Kiểm tra trạng thái đăng nhập
  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int? idNguoiDung = prefs.getInt('idNguoiDung');
    if (mounted) {
      setState(() {
        _isLoggedIn = idNguoiDung != null;
      });
      if (_isLoggedIn && widget.hasBooking) {
        _loadBookingData(); // Chỉ tải dữ liệu nếu đã đăng nhập và có đặt phòng
      } else {
        setState(() {
          _isLoading = false;
          _bookingList = [];
        });
      }
    }
  }

  // Tải dữ liệu đặt phòng
  Future<void> _loadBookingData() async {
    if (!_isLoggedIn || !widget.hasBooking) return; // Ngăn tải nếu không hợp lệ
    setState(() {
      _isLoading = true;
    });
    try {
      final dbHelper = DatabaseHelper.instance;
      final bookings = await dbHelper.getAllBookingsDetailed();
      if (mounted) {
        setState(() {
          _bookingList = bookings;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Lỗi khi lấy dữ liệu đặt phòng: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _bookingList = [];
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'đã xác nhận':
      case 'confirmed':
        return const Color(0xFF27A72F);
      case 'đang chờ':
      case 'pending':
        return const Color(0xFF9FD779);
      case 'đã hủy':
      case 'cancelled':
        return const Color(0xFFE68B85);
      default:
        return const Color(0xFF6EC2F7);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Danh sách đặt phòng',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF3EAEF4),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF3EAEF4),
                        ),
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Đang tải dữ liệu...',
                      style: TextStyle(
                        color: Color(0xFF6EC2F7),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
              : _bookingList.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.hotel_outlined,
                            size: 64,
                            color: const Color(0xFF91A8ED),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Chưa có đặt phòng nào',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF91A8ED),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Hãy đặt phòng đầu tiên của bạn!',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFFCFEBFC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                color: const Color(0xFF3EAEF4),
                onRefresh: _loadBookingData,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _bookingList.length,
                  itemBuilder: (context, index) {
                    final booking = _bookingList[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.white, const Color(0xFFFAFBFC)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3EAEF4).withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header with hotel name and status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${booking['TenKhachSan']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color(0xFF27A72F),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(
                                      booking['TrangThai'],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${booking['TrangThai']}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Location
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F8FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFCFEBFC),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF6EC2F7),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${booking['DiaChi']}, ${booking['ThanhPho']}',
                                      style: const TextStyle(
                                        color: Color(0xFF3EAEF4),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Room info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFE0E6FF),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.hotel,
                                    color: Color(0xFF91A8ED),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      '${booking['TenLoaiPhong']} - Số phòng: ${booking['SoPhong']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF91A8ED),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Guest info
                            Row(
                              children: [
                                const Icon(
                                  Icons.person,
                                  color: Color(0xFF9FD779),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Người đặt: ${booking['TenNguoiDung']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF27A72F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.email,
                                  color: Color(0xFF6EC2F7),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${booking['Email']}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF3EAEF4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Date info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFF0F8FF),
                                    const Color(0xFFF8F9FF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.calendar_today,
                                        color: Color(0xFF6EC2F7),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Nhận phòng: ${booking['NgayNhanPhong']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF3EAEF4),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.event,
                                        color: Color(0xFF91A8ED),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Trả phòng: ${booking['NgayTraPhong']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF91A8ED),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.nights_stay,
                                        color: Color(0xFFBDCBF4),
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Số đêm: ${booking['SoDem']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFFBDCBF4),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Price info
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF27A72F).withOpacity(0.1),
                                    const Color(0xFF9FD779).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Giá mỗi đêm:',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF27A72F),
                                        ),
                                      ),
                                      Text(
                                        '${booking['GiaMoiDemKhiDat']}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF27A72F),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Tổng tiền:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF27A72F),
                                        ),
                                      ),
                                      Text(
                                        '${booking['TongTien']}',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF27A72F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Special requests
                            if (booking['YeuCauDacBiet'] != null &&
                                booking['YeuCauDacBiet'].toString().isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF8F0),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFE68B85),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.priority_high,
                                      color: Color(0xFFE68B85),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Yêu cầu đặc biệt: ${booking['YeuCauDacBiet']}',
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          color: Color(0xFFE68B85),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
