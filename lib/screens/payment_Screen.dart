import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/models/xylynen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:flutter_hotelbooking_25/db/xulylogicdatphong.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isLoading = false;
  String? _selectedPaymentMethod;
  final List<String> _paymentMethods = [
    'Thẻ tín dụng',
    'Momo',
    'Chuyển khoản ngân hàng',
  ];

  Future<void> _processPayment(int idDatPhong, double totalAmount) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper.instance;

      // Lấy thông tin đặt phòng
      final booking = await dbHelper.getBookingById(idDatPhong);
      if (booking == null) {
        throw Exception('Không tìm thấy thông tin đặt phòng');
      }
      print('SQLite: Dữ liệu booking: $booking'); // Log để debug

      // Kiểm tra và xử lý NgayTraPhong
      final ngayTraPhongRaw = booking['NgayTraPhong'];
      if (ngayTraPhongRaw == null) {
        throw Exception(
          'Trường NgayTraPhong không tồn tại hoặc là null trong booking',
        );
      }
      final checkOutTime =
          ngayTraPhongRaw is DateTime
              ? ngayTraPhongRaw
              : DateFormat(
                'yyyy-MM-ddTHH:mm:ss',
              ).parse(ngayTraPhongRaw as String);

      // Cập nhật trạng thái đặt phòng thành 'paid'
      await dbHelper.updateBookingStatus(
        idDatPhong,
        'paid',
        _selectedPaymentMethod,
      );

      // Cập nhật trạng thái phòng thành 'không trống' (DangTrong = 0)
      final idPhong = booking['IDPhong'] as int;
      await dbHelper.updateRoomStatus(idPhong, 0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thanh toán thành công! Phòng đã được đặt.'),
          ),
        );

        // Quay về màn hình chính
        Navigator.pushReplacementNamed(context, '/home');

        // Lên lịch trả phòng bằng workmanager
        final autoReleaseTime = checkOutTime.add(const Duration(hours: 1));
        final timeUntilRelease = autoReleaseTime.difference(DateTime.now());
        print(
          "Scheduling release for room $idPhong at $autoReleaseTime with delay: $timeUntilRelease",
        );

        if (timeUntilRelease.isNegative) {
          // Nếu thời gian đã qua, cập nhật ngay lập tức
          await dbHelper.updateRoomStatus(idPhong, 1);
          print("Room $idPhong updated to vacant immediately");
        } else {
          scheduleRoomRelease(idPhong, checkOutTime);
        }
      }
    } catch (e) {
      print('Lỗi khi thanh toán: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi thanh toán: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (arguments == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Lỗi')),
        body: const Center(child: Text('Không tìm thấy thông tin đặt phòng')),
      );
    }

    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Thanh toán'),
        centerTitle: true,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(arguments, formatter, textTheme),
                    const SizedBox(height: 24),
                    _buildPaymentMethodSection(textTheme),
                    const SizedBox(height: 24),
                    _buildPaymentDetailsSection(textTheme),
                  ],
                ),
              ),
      bottomSheet:
          _isLoading
              ? null
              : _buildPayButton(arguments, formatter, textTheme, colorScheme),
    );
  }

  Widget _buildSummaryCard(
    Map<String, dynamic> arguments,
    NumberFormat formatter,
    TextTheme textTheme,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              arguments['TenKhachSan'] ?? 'N/A',
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Loại phòng: ${arguments['TenLoaiPhong'] ?? 'N/A'}',
              style: textTheme.titleLarge,
            ),
            Text(
              'Ngày nhận phòng: ${DateFormat('dd/MM/yyyy').format(arguments['checkIn'] as DateTime)}',
              style: textTheme.bodyMedium,
            ),
            Text(
              'Ngày trả phòng: ${DateFormat('dd/MM/yyyy').format(arguments['checkOut'] as DateTime)}',
              style: textTheme.bodyMedium,
            ),
            Text(
              'Tổng tiền: ${formatter.format(arguments['tongTien'] ?? 0)}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSection(TextTheme textTheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phương thức thanh toán',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._paymentMethods.map(
              (method) => RadioListTile<String>(
                title: Text(method, style: textTheme.bodyMedium),
                value: method,
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsSection(TextTheme textTheme) {
    if (_selectedPaymentMethod == null) {
      return const SizedBox.shrink();
    }

    if (_selectedPaymentMethod == 'Thẻ tín dụng') {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Thông tin thẻ tín dụng',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Số thẻ',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Ngày hết hạn (MM/YY)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      obscureText: true,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } else if (_selectedPaymentMethod == 'Momo' ||
        _selectedPaymentMethod == 'Chuyển khoản ngân hàng') {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hướng dẫn thanh toán $_selectedPaymentMethod',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _selectedPaymentMethod == 'Momo'
                    ? 'Vui lòng quét mã QR hoặc sử dụng ứng dụng Momo để thanh toán.'
                    : 'Vui lòng quét mã QR hoặc sử dụng ứng dụng ngân hàng để chuyển khoản.',
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              // Giả lập hiển thị mã QR
              Container(
                height: 150,
                color: Colors.grey[300],
                child: const Center(child: Text('Mã QR sẽ hiển thị ở đây')),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPayButton(
    Map<String, dynamic> arguments,
    NumberFormat formatter,
    TextTheme textTheme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed:
            _selectedPaymentMethod == null
                ? null
                : () => _processPayment(
                  arguments['idDatPhong'] as int,
                  arguments['tongTien'] as double,
                ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        child: Text(
          'Thanh toán ${formatter.format(arguments['tongTien'] ?? 0)}',
        ),
      ),
    );
  }
}
