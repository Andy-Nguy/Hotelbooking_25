import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';

class ServiceScreen extends StatefulWidget {
  final bool hasBooking;
  const ServiceScreen({super.key, required this.hasBooking});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  List<Map<String, dynamic>> _bookingList = [];
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int? idNguoiDung = prefs.getInt('idNguoiDung');
    if (mounted) {
      setState(() {
        _isLoggedIn = idNguoiDung != null;
      });
      if (_isLoggedIn && widget.hasBooking) {
        _loadBookingData();
      } else {
        setState(() {
          _isLoading = false;
          _bookingList = [];
        });
      }
    }
  }

  Future<void> _loadBookingData() async {
    if (!_isLoggedIn || !widget.hasBooking) return;
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
        print('Danh sách đặt phòng: $bookings'); // Debug dữ liệu
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

  String _generateQRData(Map<String, dynamic> booking) {
    final qrData = '''
Đặt phòng #${booking['IDDatPhong'] ?? 'N/A'}
Khách sạn: ${booking['TenKhachSan'] ?? 'N/A'}
Phòng: ${booking['SoPhong'] ?? 'N/A'}
Nhận phòng: ${booking['NgayNhanPhong'] ?? 'N/A'}
Trả phòng: ${booking['NgayTraPhong'] ?? 'N/A'}
Người đặt: ${booking['TenNguoiDung'] ?? 'N/A'}
Số đêm: ${booking['SoDem'] ?? 'N/A'}
Tổng tiền: ${booking['TongTien'] ?? 'N/A'}
Trạng thái: ${booking['TrangThai'] ?? 'N/A'}
''';
    print('QR Data: $qrData'); // Debug dữ liệu QR
    return qrData;
  }

  @override
  Widget build(BuildContext context) {
    print(
      'Kích thước màn hình: ${MediaQuery.of(context).size}',
    ); // Debug kích thước màn hình
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                                    '${booking['TenKhachSan'] ?? 'N/A'}',
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
                                    '${booking['TrangThai'] ?? 'N/A'}',
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
                                      '${booking['DiaChi'] ?? 'N/A'}, ${booking['ThanhPho'] ?? 'N/A'}',
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
                                      '${booking['TenLoaiPhong'] ?? 'N/A'} - Số phòng: ${booking['SoPhong'] ?? 'N/A'}',
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
                                  'Người đặt: ${booking['TenNguoiDung'] ?? 'N/A'}',
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
                                  '${booking['Email'] ?? 'N/A'}',
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
                                        'Nhận phòng: ${booking['NgayNhanPhong'] ?? 'N/A'}',
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
                                        'Trả phòng: ${booking['NgayTraPhong'] ?? 'N/A'}',
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
                                        'Số đêm: ${booking['SoDem'] ?? 'N/A'}',
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
                                        '${booking['GiaMoiDemKhiDat'] ?? 'N/A'}',
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
                                        '${booking['TongTien'] ?? 'N/A'}',
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

                            // QR Code section
                            Container(
                              margin: const EdgeInsets.only(top: 16),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF3EAEF4),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Mã QR đặt phòng',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF3EAEF4),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: 150.0,
                                    height: 150.0,
                                    child: QrImageView(
                                      data: _generateQRData(booking),
                                      version: QrVersions.auto,
                                      gapless: false,
                                      backgroundColor: Colors.white,
                                      errorStateBuilder: (context, error) {
                                        print(
                                          'Lỗi tạo mã QR: $error',
                                        ); // Debug lỗi
                                        return const Text(
                                          'Lỗi tạo mã QR',
                                          style: TextStyle(color: Colors.red),
                                          textAlign: TextAlign.center,
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Quét mã để xem thông tin đặt phòng',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF6EC2F7),
                                    ),
                                    textAlign: TextAlign.center,
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
