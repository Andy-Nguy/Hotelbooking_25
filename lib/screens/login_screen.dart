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
  bool _isLoggedIn = false; // Ban đầu không đăng nhập
  Map<String, dynamic>? _userInfo;

  // Color scheme based on the provided palette
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color lightBlue = Color(0xFF87CEEB);
  static const Color accentPurple = Color(0xFF8B7EC8);
  static const Color softGray = Color(0xFFF5F7FA);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color successGreen = Color(0xFF27AE60);

  @override
  void initState() {
    super.initState();
    // Không kiểm tra tự động đăng nhập khi khởi chạy
    // _checkLoginStatus(); // Comment hoặc xóa để tránh tự động đăng nhập
  }

  // Loại bỏ hoặc vô hiệu hóa _checkLoginStatus() để tránh tự động đăng nhập
  // Future<void> _checkLoginStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final idNguoiDung = prefs.getInt('idNguoiDung');
  //   if (idNguoiDung != null) {
  //     final dbHelper = DatabaseHelper.instance;
  //     final user = await dbHelper.getUserById(idNguoiDung);
  //     if (user != null && mounted) {
  //       setState(() {
  //         _isLoggedIn = true;
  //         _userInfo = user;
  //       });
  //     }
  //   }
  // }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final dbHelper = DatabaseHelper.instance;
      final users = await dbHelper.queryUser(
        'Email = ? AND MatKhauHash = ?', // Thay bằng logic hash thực tế
        [
          _emailController.text,
          _passwordController.text,
        ], // Giả sử mật khẩu chưa hash
      );
      if (users.isNotEmpty) {
        final user = users.first;
        final role = user['Role']; // Lấy Role từ database
        final effectiveRole =
            role ?? 'KhachHang'; // Nếu Role là NULL, coi là KhachHang
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('idNguoiDung', user['IDNguoiDung']);
        await prefs.setString('role', effectiveRole); // Lưu vai trò hiệu quả
        setState(() {
          _isLoading = false;
          _isLoggedIn = true;
          _userInfo = user;
        });
        // Chuyển hướng dựa trên vai trò
        if (effectiveRole == 'NhanVien' || effectiveRole == 'QuanTri') {
          Navigator.pushNamed(context, '/admin');
        } else if (widget.fromBooking &&
            widget.idLoaiPhong != null &&
            widget.roomType != null) {
          Navigator.pushNamed(
            context,
            '/booking',
            arguments: {
              'idLoaiPhong': widget.idLoaiPhong,
              'roomType': widget.roomType,
            },
          );
        } else {
          Navigator.pushNamed(context, '/home');
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email hoặc mật khẩu không đúng.')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xảy ra lỗi khi đăng nhập.')),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('idNguoiDung');
    await prefs.remove('role'); // Xóa vai trò khi đăng xuất
    if (mounted) {
      setState(() {
        _isLoggedIn = false;
        _userInfo = null;
        _emailController.clear();
        _passwordController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Đăng xuất thành công!'),
          backgroundColor: successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF87CEEB), Color(0xFF4A90E2), Color(0xFF8B7EC8)],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo/Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryBlue, accentPurple],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.hotel, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Đăng Nhập',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: darkGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Chào mừng bạn trở lại!',
            style: TextStyle(fontSize: 16, color: darkGray.withOpacity(0.6)),
          ),
          const SizedBox(height: 32),

          // Email Field
          Container(
            decoration: BoxDecoration(
              color: softGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.transparent),
            ),
            child: TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: darkGray.withOpacity(0.7)),
                prefixIcon: Icon(Icons.email_outlined, color: primaryBlue),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          const SizedBox(height: 16),

          // Password Field
          Container(
            decoration: BoxDecoration(
              color: softGray,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.transparent),
            ),
            child: TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mật Khẩu',
                labelStyle: TextStyle(color: darkGray.withOpacity(0.7)),
                prefixIcon: Icon(Icons.lock_outline, color: primaryBlue),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              obscureText: true,
            ),
          ),

          // Error Message
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: errorRed.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: errorRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: errorRed, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Login Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child:
                _isLoading
                    ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryBlue.withOpacity(0.7),
                            accentPurple.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    )
                    : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [primaryBlue, accentPurple],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: const Text(
                            'Đăng Nhập',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfile() {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [primaryBlue, accentPurple],
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Thông Tin Người Dùng',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkGray,
                  ),
                ),
                const SizedBox(height: 24),

                // User Info Cards
                _buildInfoCard(
                  icon: Icons.person_outline,
                  label: 'Họ Tên',
                  value: _userInfo?['HoTen'] ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: _userInfo?['Email'] ?? 'N/A',
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.phone_outlined,
                  label: 'Số Điện Thoại',
                  value: _userInfo?['SoDienThoai'] ?? 'N/A',
                ),
                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: errorRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Đăng Xuất',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: softGray,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: darkGray.withOpacity(0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: darkGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient Background
          _buildGradientBackground(),

          // Content
          SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
                child:
                    _isLoggedIn
                        ? _buildUserProfile()
                        : Center(child: _buildLoginForm()),
              ),
            ),
          ),

          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: primaryBlue),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
