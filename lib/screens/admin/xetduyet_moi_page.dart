import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:intl/intl.dart';

class XetDuyetMoiScreen extends StatefulWidget {
  const XetDuyetMoiScreen({super.key});

  @override
  State<XetDuyetMoiScreen> createState() => _XetDuyetMoiScreenState();
}

class _XetDuyetMoiScreenState extends State<XetDuyetMoiScreen> {
  List<Map<String, dynamic>> _pendingBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingBookings();
  }

  Future<void> _loadPendingBookings() async {
    setState(() => _isLoading = true);
    try {
      final dbHelper = DatabaseHelper.instance;
      _pendingBookings = await dbHelper.getPendingBookings();
      print('Số lượng bản ghi pending bookings: ${_pendingBookings.length}');
      print('Dữ liệu pending bookings: $_pendingBookings');
      setState(() => _isLoading = false);
    } catch (e) {
      print('Error khi tải pending bookings: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _acceptBooking(int idDatPhong) async {
    try {
      await DatabaseHelper.instance.updateBookingStatus(
        idDatPhong,
        'confirmed',
        null,
      );
      await _loadPendingBookings();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã chấp nhận yêu cầu đặt phòng')),
      );
    } catch (e) {
      print('Error khi chấp nhận booking: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi chấp nhận: $e')));
    }
  }

  Future<void> _rejectBooking(int idDatPhong, int idPhong) async {
    try {
      await DatabaseHelper.instance.updateBookingStatus(
        idDatPhong,
        'rejected',
        null,
      );
      await DatabaseHelper.instance.updateRoomStatus(idPhong, 1); // 1 = Trống
      await _loadPendingBookings();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã từ chối và trả phòng')));
    } catch (e) {
      print('Error khi từ chối booking: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi từ chối: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _pendingBookings.isEmpty
        ? const Center(child: Text('Không có yêu cầu mới.'))
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _pendingBookings.length,
          itemBuilder: (context, index) {
            final booking = _pendingBookings[index];
            final formatter = DateFormat('dd/MM/yyyy HH:mm');
            final ngayNhanPhong = formatter.format(
              DateTime.parse(booking['NgayNhanPhong'] as String),
            );
            final ngayTraPhong = formatter.format(
              DateTime.parse(booking['NgayTraPhong'] as String),
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text('Đặt phòng #${booking['IDDatPhong']}'),
                subtitle: Text(
                  'Phòng: ${booking['IDPhong']}\n'
                  'Từ: $ngayNhanPhong đến $ngayTraPhong\n'
                  'Tổng tiền: ${booking['TongTien'] ?? 'N/A'} VND',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check),
                      color: Colors.green,
                      onPressed: () => _acceptBooking(booking['IDDatPhong']),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cancel),
                      color: Colors.red,
                      onPressed:
                          () => _rejectBooking(
                            booking['IDDatPhong'],
                            booking['IDPhong'],
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
