import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? _userInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final idNguoiDung = prefs.getInt('idNguoiDung');
    if (idNguoiDung != null) {
      final dbHelper = DatabaseHelper.instance;
      final user = await dbHelper.getUserById(idNguoiDung);
      if (mounted) {
        setState(() {
          _userInfo = user;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        Navigator.pushReplacementNamed(
          context,
          '/home',
        ); // Quay lại nếu không có thông tin
      }
    }
  }

  Future<void> _logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('idNguoiDung');
      if (mounted) {
        setState(() {
          _userInfo = null;
        });
        Navigator.pushReplacementNamed(context, '/home');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Đăng xuất thành công!')));
      }
    } catch (e) {
      print('Lỗi khi đăng xuất: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã xảy ra lỗi khi đăng xuất: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông Tin Người Dùng')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _userInfo == null
              ? const Center(
                child: Text('Không tìm thấy thông tin người dùng.'),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
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
                ),
              ),
    );
  }
}
