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
  bool _isLoading = false;
  int? _idNguoiDung;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final idNguoiDung = prefs.getInt('idNguoiDung');
    if (idNguoiDung != null) {
      setState(() {
        _idNguoiDung = idNguoiDung;
      });
      final dbHelper = DatabaseHelper.instance;
      final user = await dbHelper.getUserById(idNguoiDung);
      if (user != null) {
        _nameController.text = user['HoTen'] ?? '';
        _emailController.text = user['Email'] ?? '';
        _phoneController.text = user['SoDienThoai'] ?? '';
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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        _updateTotalCost();
      });
    }
  }

  Future<void> _selectCheckOutDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate ?? DateTime.now(),
      firstDate: _checkInDate ?? DateTime.now(),
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
      final giaCoBanMoiDem = widget.roomType['GiaCoBanMoiDem'] as double;
      setState(() {
        _totalCost = giaCoBanMoiDem * days;
      });
    }
  }

  Future<void> _bookRoom() async {
    if (_formKey.currentState!.validate() && _idNguoiDung != null) {
      setState(() {
        _isLoading = true;
      });

      final dbHelper = DatabaseHelper.instance;
      final success = await dbHelper.bookRoom(
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

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đặt phòng thành công!')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đặt phòng thất bại. Vui lòng thử lại.'),
          ),
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
      appBar: AppBar(title: const Text('Đặt Phòng')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.roomType['TenLoaiPhong'] ?? 'N/A',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Giá mỗi đêm: ${widget.roomType['GiaCoBanMoiDem']?.toStringAsFixed(0) ?? 'N/A'} VND',
                        style: const TextStyle(color: Colors.green),
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        title: Text(
                          _checkInDate == null
                              ? 'Chọn ngày nhận phòng'
                              : 'Ngày nhận phòng: ${DateFormat('dd/MM/yyyy').format(_checkInDate!)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectCheckInDate(context),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        title: Text(
                          _checkOutDate == null
                              ? 'Chọn ngày trả phòng'
                              : 'Ngày trả phòng: ${DateFormat('dd/MM/yyyy').format(_checkOutDate!)}',
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () => _selectCheckOutDate(context),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<int>(
                        decoration: const InputDecoration(
                          labelText: 'Số lượng khách',
                          border: OutlineInputBorder(),
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
                          if (value == null) {
                            return 'Vui lòng chọn số lượng khách';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      if (_totalCost != null)
                        Text(
                          'Tổng chi phí: ${_totalCost!.toStringAsFixed(0)} VND',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      const SizedBox(height: 20),
                      const Text(
                        'Thông tin người đặt',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Họ tên',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập họ tên';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập email';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Email không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập số điện thoại';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _specialRequestController,
                        decoration: const InputDecoration(
                          labelText: 'Yêu cầu đặc biệt (tuỳ chọn)',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _bookRoom,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Xác nhận đặt phòng',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
