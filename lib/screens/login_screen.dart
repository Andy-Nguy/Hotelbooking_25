import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final bool fromBooking; // Thêm tham số để xác định nguồn
  final int? idLoaiPhong; // Lưu IDLoaiPhong nếu từ Booking
  final Map<String, dynamic>? roomType; // Lưu roomType nếu từ Booking

  const LoginScreen({
    super.key,
    this.fromBooking = false,
    this.idLoaiPhong,
    this.roomType,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final idNguoiDung = prefs.getInt('idNguoiDung');
    if (idNguoiDung != null) {
      final dbHelper = DatabaseHelper.instance;
      final user = await dbHelper.getUserById(idNguoiDung);
      if (user != null && mounted) {
        setState(() {
          _isLoggedIn = true;
          _userInfo = user;
        });
      }
    }
  }

  Future<void> _login() async {
    // Ẩn bàn phím trước khi xử lý
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email và mật khẩu không được để trống.');
      }

      final dbHelper = DatabaseHelper.instance;
      final user = await dbHelper.loginUser(email, password);

      if (user != null) {
        final idNguoiDung = user['IDNguoiDung'];
        if (idNguoiDung is! int) {
          throw Exception('IDNguoiDung không hợp lệ: $idNguoiDung');
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('idNguoiDung', idNguoiDung);
        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _userInfo = user;
            _isLoading = false;
          });
          await Future.delayed(
            const Duration(milliseconds: 100),
          ); // Đợi render giao diện
          if (mounted) {
            if (widget.fromBooking &&
                widget.idLoaiPhong != null &&
                widget.roomType != null) {
              // Quay lại BookingScreen với thông tin
              Navigator.pop(context, {
                'success': true,
                'idLoaiPhong': widget.idLoaiPhong,
                'roomType': widget.roomType,
              });
            } else {
              // Chuyển hướng đến UserProfileScreen
              Navigator.pushReplacementNamed(context, '/user_profile');
            }
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Email hoặc mật khẩu không đúng.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Lỗi trong _login: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Đã xảy ra lỗi: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('idNguoiDung');
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _userInfo = null;
        _emailController.clear();
        _passwordController.clear();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đăng xuất thành công!')));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng Nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoggedIn
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông Tin Người Dùng',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('Họ Tên: ${_userInfo?['HoTen'] ?? 'N/A'}'),
                    Text('Email: ${_userInfo?['Email'] ?? 'N/A'}'),
                    Text(
                      'Số Điện Thoại: ${_userInfo?['SoDienThoai'] ?? 'N/A'}',
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Đăng Xuất'),
                    ),
                  ],
                )
                : Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Mật Khẩu',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                    const SizedBox(height: 20),
                    _isLoading
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                          onPressed: _login,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                          ),
                          child: const Text('Đăng Nhập'),
                        ),
                  ],
                ),
      ),
    );
  }
}
