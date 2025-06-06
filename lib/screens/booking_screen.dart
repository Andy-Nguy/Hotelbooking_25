import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookingScreen extends StatefulWidget {
  final int idLoaiPhong;
  final Map<String, dynamic> roomType;

  const BookingScreen({
    super.key,
    required this.idLoaiPhong,
    required this.roomType,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _checkInDate;
  DateTime? _checkOutDate;
  int? _numberOfGuests;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _specialRequestController = TextEditingController();
  double? _totalCost;
  int? _numberOfNights;
  bool _isLoading = false;
  bool _isLoadingUserInfo = true;
  int? _idNguoiDung;
  Map<String, dynamic>? _hotelDetails;

  static const double _vat = 0.08;
  static const double _serviceFee = 0.05;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadHotelDetails();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idNguoiDung = prefs.getInt('idNguoiDung');
      if (idNguoiDung != null) {
        setState(() {
          _idNguoiDung = idNguoiDung;
        });
        final dbHelper = DatabaseHelper.instance;
        final user = await dbHelper.getUserById(idNguoiDung);
        if (user != null && mounted) {
          setState(() {
            _nameController.text = user['HoTen'] ?? '';
            _emailController.text = user['Email'] ?? '';
            _phoneController.text = user['SoDienThoai'] ?? '';
          });
        }
      }
    } catch (e) {
      print('Lỗi khi tải thông tin người dùng: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingUserInfo = false;
        });
      }
    }
  }

  Future<void> _loadHotelDetails() async {
    final dbHelper = DatabaseHelper.instance;
    final hotelId = widget.roomType['IDKhachSan'] as int?;
    if (hotelId != null) {
      try {
        final details = await dbHelper.getFullHotelDetails(hotelId);
        if (mounted) {
          setState(() {
            _hotelDetails = details;
          });
        }
      } catch (e) {
        print('Lỗi khi tải thông tin khách sạn: $e');
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _specialRequestController.dispose();
    super.dispose();
  }

  Future<void> _selectCheckInDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        if (_checkOutDate != null &&
            (_checkOutDate!.isBefore(picked) ||
                _checkOutDate!.isAtSameMomentAs(picked))) {
          _checkOutDate = null;
        }
        _updateTotalCost();
      });
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    if (_checkInDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày nhận phòng trước!')),
      );
      return;
    }
    final DateTime initialDate =
        _checkOutDate ?? _checkInDate!.add(const Duration(days: 1));
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: _checkInDate!.add(const Duration(days: 1)),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != _checkOutDate) {
      setState(() {
        _checkOutDate = picked;
        _updateTotalCost();
      });
    }
  }

  void _updateTotalCost() {
    if (_checkInDate != null && _checkOutDate != null) {
      final days = _checkOutDate!.difference(_checkInDate!).inDays;
      if (days <= 0) {
        setState(() {
          _numberOfNights = null;
          _totalCost = null;
        });
        return;
      }
      final giaCoBanMoiDem =
          widget.roomType['GiaCoBanMoiDem'] as double? ?? 0.0;
      final giaMoiDemSauThue = giaCoBanMoiDem * (1 + _vat + _serviceFee);
      setState(() {
        _numberOfNights = days;
        _totalCost = giaMoiDemSauThue * days;
      });
    } else {
      setState(() {
        _numberOfNights = null;
        _totalCost = null;
      });
    }
  }

  Future<void> _bookRoom() async {
    if (_checkInDate == null || _checkOutDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ngày nhận và trả phòng!')),
      );
      return;
    }

    if (_formKey.currentState!.validate() && _idNguoiDung != null) {
      bool? confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text('Xác nhận đặt phòng'),
              content: Text(
                'Bạn có chắc chắn muốn đặt phòng "${widget.roomType['TenLoaiPhong']}" từ ngày ${DateFormat('dd/MM/yyyy').format(_checkInDate!)} đến ${DateFormat('dd/MM/yyyy').format(_checkOutDate!)} với tổng chi phí ${_totalCost!.toStringAsFixed(0)} VND không?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    print('Nút Hủy được nhấn');
                    Navigator.pop(context, false);
                  },
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () {
                    print('Nút Xác nhận được nhấn');
                    Navigator.pop(context, true);
                  },
                  child: const Text('Xác nhận'),
                ),
              ],
            ),
      );

      if (confirmed != true) {
        print('Hủy đặt phòng');
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final dbHelper = DatabaseHelper.instance;

      // Lưu tạm đặt phòng
      final idDatPhong = await dbHelper.bookRoomTemp(
        idLoaiPhong: widget.idLoaiPhong,
        idNguoiDung: _idNguoiDung!,
        checkInDate: _checkInDate!,
        checkOutDate: _checkOutDate!,
        numberOfGuests: _numberOfGuests!,
        giaMoiDemKhiDat: widget.roomType['GiaCoBanMoiDem'] as double,
        totalCost: _totalCost!,
        userInfo: {
          'HoTen': _nameController.text,
          'Email': _emailController.text,
          'SoDienThoai': _phoneController.text,
        },
        specialRequest: _specialRequestController.text,
      );

      setState(() {
        _isLoading = false;
      });

      // Chuyển hướng sang BookingDetailScreen
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/booking_detail',
          arguments: {
            'idDatPhong': idDatPhong,
            'TenKhachSan': _hotelDetails?['TenKhachSan'],
            'DiaChi':
                '${_hotelDetails?['DiaChi'] ?? ''}, ${_hotelDetails?['ThanhPho'] ?? ''}',
            'TenLoaiPhong': widget.roomType['TenLoaiPhong'],
            'GiaCoBanMoiDem':
                widget.roomType['GiaCoBanMoiDem'] * (1 + 0.08 + 0.05),
            'checkIn': _checkInDate,
            'checkOut': _checkOutDate,
            'soDem': _checkOutDate!.difference(_checkInDate!).inDays,
            'soKhach': _numberOfGuests,
            'HoTen': _nameController.text,
            'Email': _emailController.text,
            'SoDienThoai': _phoneController.text,
            'YeuCauDacBiet': _specialRequestController.text,
            'tongTien': _totalCost,
            'TrangThai': 'Chờ xác nhận',
            'amenities': widget.roomType['amenities'],
          },
        );
      }
    } else if (_idNguoiDung == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đăng nhập để đặt phòng!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Xác nhận & Đặt phòng'),
        centerTitle: true,
      ),
      body:
          _isLoading || _isLoadingUserInfo
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 80.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildRoomDetailsCard(),
                      const SizedBox(height: 24),
                      _buildBookingInfoSection(),
                      const SizedBox(height: 24),
                      _buildUserInfoSection(),
                    ],
                  ),
                ),
              ),
      bottomSheet:
          _isLoading || _isLoadingUserInfo
              ? null
              : _buildBookingSummaryAndButton(),
    );
  }

  Widget _buildRoomDetailsCard() {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hotelDetails != null) ...[
              Text(
                _hotelDetails!['TenKhachSan'] ?? 'N/A',
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
                      '${_hotelDetails!['DiaChi'] ?? 'N/A'}, ${_hotelDetails!['ThanhPho'] ?? 'N/A'}',
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
            ],
            Text(
              widget.roomType['TenLoaiPhong'] ?? 'N/A',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${formatter.format(widget.roomType['GiaCoBanMoiDem'] ?? 0)} / đêm',
              style: textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tối đa: ${widget.roomType['SoKhachToiDa'] ?? 'N/A'} khách',
              style: textTheme.bodyMedium,
            ),
            if (widget.roomType['amenities'] != null &&
                (widget.roomType['amenities'] as List).isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Tiện nghi phòng:',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              _buildAmenitiesList(
                widget.roomType['amenities'] as List<dynamic>?,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBookingInfoSection() {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Chi tiết đặt phòng của bạn', style: textTheme.titleLarge),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDatePickerField(
                label: 'Nhận phòng',
                date: _checkInDate,
                onTap: () => _selectCheckInDate(context),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDatePickerField(
                label: 'Trả phòng',
                date: _checkOutDate,
                onTap: () => _selectCheckOutDate(context),
              ),
            ),
          ],
        ),
        if (_numberOfNights != null && _numberOfNights! > 0) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Tổng số đêm: $_numberOfNights',
              style: textTheme.bodyMedium,
            ),
          ),
        ],
        const SizedBox(height: 16),
        DropdownButtonFormField<int>(
          decoration: const InputDecoration(
            labelText: 'Số lượng khách',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          value: _numberOfGuests,
          items:
              List.generate(
                (widget.roomType['SoKhachToiDa'] as int? ?? 1),
                (index) => DropdownMenuItem(
                  value: index + 1,
                  child: Text('${index + 1} khách'),
                ),
              ).toList(),
          onChanged: (value) {
            setState(() {
              _numberOfGuests = value;
            });
          },
          validator: (value) {
            if (value == null) return 'Vui lòng chọn số lượng khách';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDatePickerField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today_outlined),
        ),
        child: Text(
          date == null ? 'Chọn ngày' : DateFormat('dd/MM/yyyy').format(date),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Thông tin người đặt', style: textTheme.titleLarge),
        const SizedBox(height: 16),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Họ tên',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? 'Vui lòng nhập họ tên'
                      : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Vui lòng nhập email';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          decoration: const InputDecoration(
            labelText: 'Số điện thoại',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? 'Vui lòng nhập số điện thoại'
                      : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _specialRequestController,
          decoration: const InputDecoration(
            labelText: 'Yêu cầu đặc biệt (tùy chọn)',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.notes_outlined),
          ),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildBookingSummaryAndButton() {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VND');
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _totalCost == null
                      ? 'Chọn ngày để xem giá'
                      : 'Tổng cộng sau 10% VAT và 5% phí dịch vụ:',
                  style: textTheme.bodyMedium,
                ),
                if (_totalCost != null)
                  Text(
                    formatter.format(_totalCost!),
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _bookRoom,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              textStyle: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            child: const Text('Xác nhận'),
          ),
        ],
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
