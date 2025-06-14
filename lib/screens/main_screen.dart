import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/screens/home/home_screen.dart';
import 'package:flutter_hotelbooking_25/screens/about_screen.dart';
import 'package:flutter_hotelbooking_25/screens/login_screen.dart';
import 'package:flutter_hotelbooking_25/screens/service_screen.dart';
import 'package:flutter_hotelbooking_25/screens/user/UserProfile_screen.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  bool _hasBooking = false;
  bool _isLoading = true;

  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    _loadLoginStatus();
    _checkBookingStatus();
  }

  void _initAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  Future<void> _loadLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final int? idNguoiDung = prefs.getInt('idNguoiDung');
    if (mounted) {
      setState(() {
        _isLoggedIn = idNguoiDung != null;
        _isLoading = false;
      });
      _animationController?.forward();
    }
  }

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

  void _updateLoginStatus(bool isLoggedIn) {
    setState(() {
      _isLoggedIn = isLoggedIn;
    });
    _saveLoginStatus();
    if (isLoggedIn) _checkBookingStatus();
  }

  Future<void> _saveLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isLoggedIn) {
      final int? userId = await _getUserIdFromLogin();
      if (userId != null) {
        prefs.setInt('idNguoiDung', userId);
      }
    } else {
      prefs.remove('idNguoiDung');
      setState(() {
        _hasBooking = false;
      });
    }
  }

  Future<int?> _getUserIdFromLogin() async {
    return 1;
  }

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
    if (index == 3 && !_isLoggedIn) {
      Navigator.pushNamed(context, '/login').then((result) {
        if (result != null && result is Map && result['success'] == true) {
          _updateLoginStatus(true);
          setState(() {
            _selectedIndex = 3;
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
              ? Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade50, Colors.white],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue.shade600,
                          ),
                          strokeWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Đang tải...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : _fadeAnimation != null
              ? FadeTransition(
                opacity: _fadeAnimation!,
                child: _screens[_selectedIndex],
              )
              : _screens[_selectedIndex],
      bottomNavigationBar:
          _isLoading
              ? null
              : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      spreadRadius: 0,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNavItem(
                          icon: Icons.home_rounded,
                          label: 'Trang chủ',
                          index: 0,
                        ),
                        _buildNavItem(
                          icon: Icons.info_rounded,
                          label: 'Giới thiệu',
                          index: 1,
                        ),
                        _buildNavItem(
                          icon: Icons.room_service_rounded,
                          label: 'Dịch vụ',
                          index: 2,
                        ),
                        _buildNavItem(
                          icon:
                              _isLoggedIn
                                  ? Icons.person_rounded
                                  : Icons.login_rounded,
                          label: _isLoggedIn ? 'Hồ sơ' : 'Đăng nhập',
                          index: 3,
                          showBadge: _hasBooking,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    bool showBadge = false,
  }) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? Colors.blue.shade600 : Colors.transparent,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    size: 24,
                  ),
                ),
                if (showBadge)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.red.shade500,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: isSelected ? 12 : 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.blue.shade600 : Colors.grey.shade600,
                letterSpacing: 0.3,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
