import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/screens/home/home_screen.dart';
import 'package:flutter_hotelbooking_25/screens/about_screen.dart';
import 'package:flutter_hotelbooking_25/screens/login_screen.dart';
import 'package:flutter_hotelbooking_25/screens/service_screen.dart';
import 'package:flutter_hotelbooking_25/screens/user/UserProfile_screen.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart'; // Giả sử bạn có file này
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Theo dõi tab hiện tại
  bool _isLoggedIn = false; // Mặc định là false, sẽ được cập nhật
  bool _hasBooking = false; // Trạng thái đặt phòng
  bool _isLoading = true; // Trạng thái loading

  @override
  void initState() {
    super.initState();
    _loadLoginStatus(); // Kiểm tra trạng thái đăng nhập khi khởi động
    _checkBookingStatus(); // Kiểm tra trạng thái đặt phòng
  }

  // Hàm kiểm tra trạng thái đăng nhập từ SharedPreferences
  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int? idNguoiDung = prefs.getInt(
      'idNguoiDung',
    ); // Khóa lưu ID người dùng
    if (mounted) {
      setState(() {
        _isLoggedIn = idNguoiDung != null; // Nếu có ID, coi như đã đăng nhập
        _isLoading = false; // Kết thúc loading sau khi kiểm tra
      });
    }
  }

  // Hàm kiểm tra trạng thái đặt phòng
  Future<void> _checkBookingStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int? idNguoiDung = prefs.getInt('idNguoiDung');
    if (idNguoiDung != null) {
      try {
        final dbHelper = DatabaseHelper.instance;
        final bookings = await dbHelper.getBookingsByUserId(idNguoiDung);
        if (mounted) {
          setState(() {
            _hasBooking = bookings.isNotEmpty;
          });
        }
      } catch (e) {
        print('MainScreen: Lỗi khi kiểm tra trạng thái đặt phòng: $e');
      }
    }
  }

  // Cập nhật trạng thái đăng nhập sau khi đăng nhập/thoát
  void _updateLoginStatus(bool isLoggedIn) {
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
    _saveLoginStatus();
    if (isLoggedIn)
      _checkBookingStatus(); // Kiểm tra lại đặt phòng khi đăng nhập
  }

  // Lưu trạng thái đăng nhập vào SharedPreferences
  Future<void> _saveLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isLoggedIn) {
      // Thay 1 bằng ID thực tế từ LoginScreen
      final int? userId = await _getUserIdFromLogin(); // Giả sử hàm này
      if (userId != null) {
        prefs.setInt('idNguoiDung', userId);
      }
    } else {
      prefs.remove('idNguoiDung'); // Xóa khi đăng xuất
      setState(() {
        _hasBooking = false; // Đặt lại trạng thái đặt phòng khi đăng xuất
      });
    }
  }

  // Hàm giả lập lấy ID người dùng từ LoginScreen (thay bằng logic thực tế)
  Future<int?> _getUserIdFromLogin() async {
    // Thay bằng logic lấy ID từ LoginScreen (ví dụ: từ API hoặc database)
    return 1; // Giả lập
  }

  // Danh sách các màn hình, truyền trạng thái xuống con
  List<Widget> get _screens => <Widget>[
    const HomeScreen(),
    AboutScreen(hasBooking: _hasBooking),
    ServiceScreen(hasBooking: _hasBooking),
    _isLoggedIn ? const UserProfileScreen() : const LoginScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Điều hướng thủ công nếu nhấn tab Profile/Login và chưa đăng nhập
    if (index == 3 && !_isLoggedIn) {
      Navigator.pushNamed(context, '/login').then((result) {
        if (result != null && result is Map && result['success'] == true) {
          _updateLoginStatus(true);
          setState(() {
            _selectedIndex = 3; // Đảm bảo quay lại tab 3 sau đăng nhập
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _screens[_selectedIndex], // Hiển thị màn hình tương ứng với tab
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'About'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Service'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
