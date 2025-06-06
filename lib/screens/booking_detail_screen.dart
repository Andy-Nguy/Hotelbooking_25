import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';

class BookingDetailScreen extends StatefulWidget {
  const BookingDetailScreen({super.key});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isLoading = false;

  Future<void> _confirmBooking(int idDatPhong) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.updateBookingStatus(idDatPhong, 'confirmed', null);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xác nhận đặt phòng thành công!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print('Lỗi khi xác nhận đặt phòng: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi xác nhận: $e')));
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
    print('Building BookingDetailScreen, _isLoading: $_isLoading');
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
        title: const Text('Chi tiết đặt phòng'),
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
                    _buildBookingInfoCard(arguments, formatter, textTheme),
                    const SizedBox(height: 24),
                    _buildGuestInfoCard(arguments, textTheme),
                    const SizedBox(height: 24),
                    _buildHotelRulesSection(textTheme),
                  ],
                ),
              ),
      bottomSheet:
          _isLoading
              ? null
              : _buildConfirmButton(
                arguments,
                formatter,
                textTheme,
                colorScheme,
              ),
    );
  }

  Widget _buildBookingInfoCard(
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
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    arguments['DiaChi'] ?? 'N/A',
                    style: textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Loại phòng: ${arguments['TenLoaiPhong'] ?? 'N/A'}',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Giá phòng: ${formatter.format(arguments['GiaCoBanMoiDem'] ?? 0)} / đêm',
              style: textTheme.bodyMedium,
            ),
            Text(
              'Ngày nhận phòng: ${DateFormat('dd/MM/yyyy').format(arguments['checkIn'] as DateTime)}',
              style: textTheme.bodyMedium,
            ),
            Text(
              'Ngày trả phòng: ${DateFormat('dd/MM/yyyy').format(arguments['checkOut'] as DateTime)}',
              style: textTheme.bodyMedium,
            ),
            Text('Số đêm: ${arguments['soDem']}', style: textTheme.bodyMedium),
            Text(
              'Số khách: ${arguments['soKhach']}',
              style: textTheme.bodyMedium,
            ),
            Text(
              'Tổng tiền: ${formatter.format(arguments['tongTien'] ?? 0)}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            if (arguments['amenities'] != null &&
                (arguments['amenities'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Tiện nghi phòng:',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildAmenitiesList(arguments['amenities'] as List<dynamic>?),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGuestInfoCard(
    Map<String, dynamic> arguments,
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
              'Thông tin người đặt',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Họ tên: ${arguments['HoTen'] ?? 'N/A'}',
              style: textTheme.bodyMedium,
            ),
            Text(
              'Email: ${arguments['Email'] ?? 'N/A'}',
              style: textTheme.bodyMedium,
            ),
            Text(
              'Số điện thoại: ${arguments['SoDienThoai'] ?? 'N/A'}',
              style: textTheme.bodyMedium,
            ),
            if (arguments['YeuCauDacBiet']?.isNotEmpty ?? false)
              Text(
                'Yêu cầu đặc biệt: ${arguments['YeuCauDacBiet']}',
                style: textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHotelRulesSection(TextTheme textTheme) {
    const rules = [
      'Không hút thuốc trong phòng.',
      'Thời gian nhận phòng: 14:00, trả phòng: 12:00.',
      'Không mang thú cưng vào khu vực khách sạn.',
      'Hủy phòng trước 48 giờ để được hoàn tiền 100%.',
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nội quy khách sạn',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...rules.map(
              (rule) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rule, style: textTheme.bodyMedium)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton(
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
        onPressed: () {
          Navigator.pushNamed(
            context,
            '/payment',
            arguments: arguments, // Truyền dữ liệu đặt phòng
          ).then((result) {
            if (result == true) {
              // Xử lý khi thanh toán thành công
              _confirmBooking(arguments['idDatPhong'] as int);
            }
          });
        },
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        child: const Text('Thanh toán và xác nhận đặt phòng'),
      ),
    );
  }

  Widget _buildAmenitiesList(List<dynamic>? amenities) {
    if (amenities == null || amenities.isEmpty) {
      return const Text('Không có thông tin tiện nghi.');
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children:
          amenities.map<Widget>((amenity) {
            final amenityMap = amenity as Map<String, dynamic>;
            return Chip(
              avatar:
                  amenityMap['TenIcon'] != null
                      ? Icon(
                        _getIconData(amenityMap['TenIcon'] as String),
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      )
                      : null,
              label: Text(amenityMap['TenTienNghi'] as String? ?? 'N/A'),
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primaryContainer.withOpacity(0.4),
              side: BorderSide.none,
            );
          }).toList(),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'pool':
        return Icons.pool;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_parking':
        return Icons.local_parking;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'spa':
        return Icons.spa;
      case 'kitchen':
        return Icons.kitchen;
      case 'ac_unit':
        return Icons.ac_unit;
      case 'tv':
        return Icons.tv;
      default:
        return Icons.help_outline;
    }
  }
}
