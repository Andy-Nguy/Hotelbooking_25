import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:intl/intl.dart';

class GiaHanPhongPage extends StatefulWidget {
  const GiaHanPhongPage({super.key});

  @override
  State<GiaHanPhongPage> createState() => _GiaHanPhongPageState();
}

class _GiaHanPhongPageState extends State<GiaHanPhongPage> {
  List<Map<String, dynamic>> _bookings = [];
  bool _isLoading = true;

  // Enhanced Color scheme
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryBlueDark = Color(0xFF1976D2);
  static const Color errorRed = Color(0xFFE53E3E);
  static const Color successGreen = Color(0xFF38A169);
  static const Color softGray = Color(0xFFF8FAFC);
  static const Color darkGray = Color(0xFF2D3748);
  static const Color lightGray = Color(0xFF718096);
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color accentBlue = Color(0xFFE3F2FD);

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dbHelper = DatabaseHelper.instance;
      final bookings = await dbHelper.queryDatPhongForGiaHan();
      setState(() {
        _bookings = bookings;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Lỗi khi tải danh sách đặt phòng: $e')),
            ],
          ),
          backgroundColor: errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(16),
        ),
      );
    }
  }

  Future<void> _extendBooking(Map<String, dynamic> booking) async {
    final TextEditingController _dateController = TextEditingController(
      text: DateFormat(
        'yyyy-MM-dd',
      ).format(DateTime.parse(booking['NgayTraPhong']).add(Duration(days: 1))),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.schedule, color: primaryBlue, size: 24),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gia hạn đặt phòng #${booking['IDDatPhong']}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: darkGray,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: softGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE2E8F0), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow(
                        Icons.person,
                        'Khách hàng',
                        booking['HoTen'] ?? 'N/A',
                      ),
                      SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.room,
                        'Phòng',
                        booking['IDPhong'].toString(),
                      ),
                      SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.login,
                        'Ngày nhận phòng',
                        booking['NgayNhanPhong'] != null
                            ? DateFormat(
                              'dd/MM/yyyy',
                            ).format(DateTime.parse(booking['NgayNhanPhong']))
                            : 'N/A',
                      ),
                      SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.logout,
                        'Ngày trả phòng hiện tại',
                        booking['NgayTraPhong'] != null
                            ? DateFormat(
                              'dd/MM/yyyy',
                            ).format(DateTime.parse(booking['NgayTraPhong']))
                            : 'N/A',
                      ),
                      SizedBox(height: 12),
                      _buildInfoRow(
                        Icons.attach_money,
                        'Giá mỗi đêm',
                        '${(booking['GiaMoiDemKhiDat'] ?? 0).toStringAsFixed(0)} VND',
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Chọn ngày trả phòng mới',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: darkGray,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: primaryBlue, width: 2),
                  ),
                  child: TextField(
                    controller: _dateController,
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.calendar_today,
                          color: primaryBlue,
                          size: 20,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      hintText: 'Chọn ngày trả phòng mới',
                      hintStyle: TextStyle(color: lightGray),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.parse(
                          booking['NgayTraPhong'],
                        ).add(Duration(days: 1)),
                        firstDate: DateTime.parse(booking['NgayNhanPhong']),
                        lastDate: DateTime(2100),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: primaryBlue,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: darkGray,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        _dateController.text = DateFormat(
                          'yyyy-MM-dd',
                        ).format(pickedDate);
                      }
                    },
                  ),
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: errorRed, width: 2),
                          ),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: errorRed,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final dbHelper = DatabaseHelper.instance;
                            // Calculate new number of nights
                            final ngayNhanPhong = DateTime.parse(
                              booking['NgayNhanPhong'],
                            );
                            final ngayTraPhongMoi = DateTime.parse(
                              _dateController.text,
                            );
                            final newSoDem =
                                ngayTraPhongMoi
                                    .difference(ngayNhanPhong)
                                    .inDays;
                            final giaMoiDem =
                                booking['GiaMoiDemKhiDat'] as double;
                            final newTongTien = newSoDem * giaMoiDem;

                            await dbHelper.updateGiaHanDatPhong(
                              booking['IDDatPhong'],
                              _dateController.text,
                              newTongTien,
                              newSoDem,
                            );

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Gia hạn thành công. Tổng tiền mới: ${newTongTien.toStringAsFixed(0)} VND',
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: successGreen,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.all(16),
                              ),
                            );
                            _fetchBookings();
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text('Lỗi khi gia hạn: $e'),
                                    ),
                                  ],
                                ),
                                backgroundColor: errorRed,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.all(16),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: successGreen,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Xác nhận',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryBlue),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: lightGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: darkGray,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteBooking(int idDatPhong) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: BoxConstraints(maxWidth: 360),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    color: errorRed,
                    size: 32,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Xóa đặt phòng #$idDatPhong',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkGray,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12),
                Text(
                  'Bạn có chắc muốn xóa đặt phòng này? Hành động này không thể hoàn tác.',
                  style: TextStyle(fontSize: 16, color: lightGray, height: 1.4),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: lightGray, width: 1),
                          ),
                        ),
                        child: Text(
                          'Hủy',
                          style: TextStyle(
                            color: lightGray,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            final dbHelper = DatabaseHelper.instance;
                            await dbHelper.deleteDatPhong(idDatPhong);

                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Xóa đặt phòng thành công'),
                                  ],
                                ),
                                backgroundColor: successGreen,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.all(16),
                              ),
                            );
                            _fetchBookings();
                          } catch (e) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text('Lỗi khi xóa đặt phòng: $e'),
                                    ),
                                  ],
                                ),
                                backgroundColor: errorRed,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: EdgeInsets.all(16),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: errorRed,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Xóa',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softGray,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Gia hạn đặt phòng',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryBlue,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải danh sách đặt phòng...',
                      style: TextStyle(color: lightGray, fontSize: 16),
                    ),
                  ],
                ),
              )
              : _bookings.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: accentBlue,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: Icon(
                        Icons.event_busy,
                        size: 60,
                        color: primaryBlue,
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Không có đặt phòng nào',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: darkGray,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Hiện tại chưa có đặt phòng nào cần gia hạn',
                      style: TextStyle(fontSize: 16, color: lightGray),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
              : RefreshIndicator(
                onRefresh: _fetchBookings,
                color: primaryBlue,
                child: ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: _bookings.length,
                  itemBuilder: (context, index) {
                    final booking = _bookings[index];
                    final isExpiringSoon =
                        booking['NgayTraPhong'] != null &&
                        DateTime.parse(
                          booking['NgayTraPhong'],
                        ).isBefore(DateTime.now().add(Duration(days: 3)));

                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: cardBackground,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF000000).withOpacity(0.08),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                        border:
                            isExpiringSoon
                                ? Border.all(
                                  color: errorRed.withOpacity(0.3),
                                  width: 2,
                                )
                                : null,
                      ),
                      child: Column(
                        children: [
                          if (isExpiringSoon)
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 16,
                              ),
                              decoration: BoxDecoration(
                                color: errorRed.withOpacity(0.1),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(16),
                                  topRight: Radius.circular(16),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber,
                                    color: errorRed,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Sắp hết hạn',
                                    style: TextStyle(
                                      color: errorRed,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Padding(
                            padding: EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: accentBlue,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        Icons.hotel,
                                        color: primaryBlue,
                                        size: 20,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Đặt phòng #${booking['IDDatPhong']}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: darkGray,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: successGreen.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        'Đang thuê',
                                        style: TextStyle(
                                          color: successGreen,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: softGray,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    children: [
                                      _buildBookingInfoRow(
                                        Icons.person_outline,
                                        'Khách hàng',
                                        booking['HoTen'] ?? 'N/A',
                                      ),
                                      SizedBox(height: 12),
                                      _buildBookingInfoRow(
                                        Icons.room_outlined,
                                        'Phòng',
                                        booking['IDPhong'].toString(),
                                      ),
                                      SizedBox(height: 12),
                                      _buildBookingInfoRow(
                                        Icons.login_outlined,
                                        'Ngày nhận phòng',
                                        booking['NgayNhanPhong'] != null
                                            ? DateFormat('dd/MM/yyyy').format(
                                              DateTime.parse(
                                                booking['NgayNhanPhong'],
                                              ),
                                            )
                                            : 'N/A',
                                      ),
                                      SizedBox(height: 12),
                                      _buildBookingInfoRow(
                                        Icons.logout_outlined,
                                        'Ngày trả phòng',
                                        booking['NgayTraPhong'] != null
                                            ? DateFormat('dd/MM/yyyy').format(
                                              DateTime.parse(
                                                booking['NgayTraPhong'],
                                              ),
                                            )
                                            : 'N/A',
                                      ),
                                      SizedBox(height: 12),
                                      _buildBookingInfoRow(
                                        Icons.nights_stay_outlined,
                                        'Số đêm',
                                        '${booking['SoDem'] ?? 'N/A'} đêm',
                                      ),
                                      SizedBox(height: 12),
                                      _buildBookingInfoRow(
                                        Icons.attach_money_outlined,
                                        'Tổng tiền',
                                        booking['TongTien'] != null
                                            ? '${(booking['TongTien'] as num).toStringAsFixed(0)} VND'
                                            : 'N/A',
                                        isAmount: true,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            () => _extendBooking(booking),
                                        icon: Icon(Icons.schedule, size: 18),
                                        label: Text('Gia hạn'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryBlue,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            () => _deleteBooking(
                                              booking['IDDatPhong'],
                                            ),
                                        icon: Icon(
                                          Icons.delete_outline,
                                          size: 18,
                                        ),
                                        label: Text('Xóa'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: errorRed,
                                          foregroundColor: Colors.white,
                                          padding: EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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

  Widget _buildBookingInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isAmount = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: primaryBlue),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: lightGray,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: isAmount ? successGreen : darkGray,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
