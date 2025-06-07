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

  Future<void> _updateRoomStatus(int idDatPhong, int idPhong) async {
    try {
      await DatabaseHelper.instance.updateRoomStatus(idPhong, 1); // 1 = Trống
      await _loadExpiredBookings(); // Làm mới danh sách
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật trạng thái phòng thành trống'),
        ),
      );
    } catch (e) {
      print('Error khi cập nhật trạng thái phòng: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi cập nhật: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
            final formatter = DateFormat('dd/MM/yyyy HH:mm');
            final ngayTraPhong = formatter.format(
              DateTime.parse(booking['NgayTraPhong'] as String),
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('Đặt phòng #${booking['IDDatPhong']}'),
                subtitle: Text(
                  'Phòng: ${booking['IDPhong']}\n'
                  'Ngày trả: $ngayTraPhong\n'
                  'Tổng tiền: ${booking['TongTien'] ?? 'N/A'} VND',
                ),
                trailing: ElevatedButton(
                  onPressed:
                      () => _updateRoomStatus(
                        booking['IDDatPhong'],
                        booking['IDPhong'],
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Cập nhật trạng thái'),
                ),
              ),
            );
          },
        );
  }
}
