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

  // Color scheme
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF27AE60);
  static const Color softGray = Color(0xFFF5F7FA);
  static const Color darkGray = Color(0xFF2C3E50);

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
          content: Text('Lỗi khi tải danh sách đặt phòng: $e'),
          backgroundColor: errorRed,
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
      builder: (context) {
        return AlertDialog(
          title: Text('Gia hạn đặt phòng #${booking['IDDatPhong']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Khách hàng: ${booking['HoTen'] ?? 'N/A'}'),
              Text(
                'Phòng: ${booking['IDPhong']}',
              ), // Replace with TenPhong if available
              Text(
                'Ngày nhận phòng: ${booking['NgayNhanPhong'] != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['NgayNhanPhong'])) : 'N/A'}',
              ),
              Text(
                'Ngày trả phòng hiện tại: ${booking['NgayTraPhong'] != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['NgayTraPhong'])) : 'N/A'}',
              ),
              Text('Giá mỗi đêm: ${booking['GiaMoiDemKhiDat'] ?? 'N/A'}'),
              const SizedBox(height: 16),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  labelText: 'Ngày trả phòng mới',
                  prefixIcon: Icon(Icons.calendar_today, color: primaryBlue),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                  );
                  if (pickedDate != null) {
                    _dateController.text = DateFormat(
                      'yyyy-MM-dd',
                    ).format(pickedDate);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: errorRed)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final dbHelper = DatabaseHelper.instance;
                  // Calculate new number of nights
                  final ngayNhanPhong = DateTime.parse(
                    booking['NgayNhanPhong'],
                  );
                  final ngayTraPhongMoi = DateTime.parse(_dateController.text);
                  final newSoDem =
                      ngayTraPhongMoi.difference(ngayNhanPhong).inDays;
                  final giaMoiDem = booking['GiaMoiDemKhiDat'] as double;
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
                      content: Text(
                        'Gia hạn thành công. Tổng tiền mới: $newTongTien',
                      ),
                      backgroundColor: successGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  _fetchBookings();
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi gia hạn: $e'),
                      backgroundColor: errorRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: successGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteBooking(int idDatPhong) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Xóa đặt phòng #$idDatPhong'),
          content: const Text(
            'Bạn có chắc muốn xóa đặt phòng này? Hành động này không thể hoàn tác.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy', style: TextStyle(color: errorRed)),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final dbHelper = DatabaseHelper.instance;
                  await dbHelper.deleteDatPhong(idDatPhong);

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Xóa đặt phòng thành công'),
                      backgroundColor: successGreen,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                  _fetchBookings();
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi xóa đặt phòng: $e'),
                      backgroundColor: errorRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: errorRed,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: softGray,
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _bookings.isEmpty
              ? const Center(child: Text('Không có đặt phòng nào'))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _bookings.length,
                itemBuilder: (context, index) {
                  final booking = _bookings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đặt phòng #${booking['IDDatPhong']}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: darkGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Khách hàng: ${booking['HoTen'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: darkGray,
                            ),
                          ),
                          Text(
                            'Phòng: ${booking['IDPhong']}', // Replace with TenPhong if available
                            style: const TextStyle(
                              fontSize: 16,
                              color: darkGray,
                            ),
                          ),
                          Text(
                            'Ngày nhận phòng: ${booking['NgayNhanPhong'] != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['NgayNhanPhong'])) : 'N/A'}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: darkGray,
                            ),
                          ),
                          Text(
                            'Ngày trả phòng: ${booking['NgayTraPhong'] != null ? DateFormat('yyyy-MM-dd').format(DateTime.parse(booking['NgayTraPhong'])) : 'N/A'}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: darkGray,
                            ),
                          ),
                          Text(
                            'Số đêm: ${booking['SoDem'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: darkGray,
                            ),
                          ),
                          Text(
                            'Tổng tiền: ${booking['TongTien'] != null ? (booking['TongTien'] as num).toStringAsFixed(2) : 'N/A'}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: darkGray,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () => _extendBooking(booking),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Gia hạn'),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed:
                                    () => _deleteBooking(booking['IDDatPhong']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: errorRed,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
