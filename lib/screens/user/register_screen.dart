import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'dart:math';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _verificationCodeController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationCode; // Mã xác nhận được tạo
  bool _isVerificationSent = false; // Trạng thái gửi mã

  // Color scheme
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color softGray = Color(0xFFF5F7FA);
  static const Color darkGray = Color(0xFF2C3E50);
  static const Color errorRed = Color(0xFFE74C3C);
  static const Color accentPurple = Color(0xFF8B7EC8);
  static const Color successGreen = Color(0xFF27AE60);

  // Hàm tạo mã xác nhận ngẫu nhiên (6 chữ số)
  String _generateVerificationCode() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  // Hàm gửi email xác nhận sử dụng App Password
  Future<void> _sendVerificationEmail(String email) async {
    try {
      final smtpServer = SmtpServer(
        'smtp.gmail.com',
        port: 587,
        username: 'nguyenhoang26042004@gmail.com', // Email của bạn
        password: 'ioqr uhpq jgmu luok', // App Password
        ssl: false,
        allowInsecure: false,
      );
      _verificationCode = _generateVerificationCode();
      final message =
          Message()
            ..from = Address(
              'nguyenhoang26042004@gmail.com',
              'JW Marriott Hotel Booking',
            )
            ..recipients.add(email)
            ..subject = 'Xác nhận địa chỉ email của bạn'
            ..text =
                'Kính chào ${_nameController.text},\n\n'
                'Cảm ơn bạn đã đăng ký tài khoản tại ứng dụng đặt phòng khách sạn JW Marriott.\n\n'
                'Mã xác nhận của bạn là: $_verificationCode\n'
                'Vui lòng nhập mã này để hoàn tất quá trình đăng ký và bắt đầu trải nghiệm dịch vụ cao cấp từ chúng tôi.\n\n'
                'Nếu bạn không yêu cầu đăng ký tài khoản, vui lòng bỏ qua email này.\n\n'
                'Trân trọng,\n'
                'Đội ngũ hỗ trợ khách hàng\n'
                'JW Marriott Hotel Booking';

      final sendReport = await send(message, smtpServer);
      setState(() {
        _isVerificationSent = true;
      });
      print('Email xác nhận gửi thành công đến $email: $sendReport');
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể gửi email xác nhận: $e';
      });
      print('Lỗi khi gửi email xác nhận: $e');
    }
  }

  Future<void> _register() async {
    if (!_isVerificationSent) {
      if (_emailController.text.isEmpty || _nameController.text.isEmpty) {
        setState(() {
          _errorMessage = 'Vui lòng nhập email và họ tên trước khi gửi mã.';
        });
        return;
      }
      setState(() {
        _sendVerificationEmail(_emailController.text);
        _errorMessage = 'Mã xác nhận đã được gửi. Vui lòng kiểm tra email.';
      });
      return;
    }

    if (_verificationCodeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Vui lòng nhập mã xác nhận.';
      });
      return;
    }

    if (_verificationCodeController.text != _verificationCode) {
      setState(() {
        _errorMessage = 'Mã xác nhận không đúng. Vui lòng thử lại.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dbHelper = DatabaseHelper.instance;

      final existingUsers = await dbHelper.queryUser('Email = ?', [
        _emailController.text,
      ]);

      if (existingUsers.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Email này đã được sử dụng. Vui lòng chọn email khác.';
        });
        return;
      }

      final user = {
        'HoTen': _nameController.text,
        'Email': _emailController.text,
        'MatKhauHash': _passwordController.text, // Nên hash mật khẩu
        'SoDienThoai': _phoneController.text,
        'Role': 'KhachHang',
      };

      await dbHelper.insertUser(user);

      final users = await dbHelper.queryUser('Email = ? AND MatKhauHash = ?', [
        _emailController.text,
        _passwordController.text,
      ]);

      if (users.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('idNguoiDung', users.first['IDNguoiDung']);
        await prefs.setString('role', 'KhachHang');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đăng ký thành công!'),
            backgroundColor: successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Không thể đăng ký tài khoản. Vui lòng thử lại.';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Đã xảy ra lỗi khi đăng ký: $e';
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _verificationCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF87CEEB),
                  Color(0xFF4A90E2),
                  Color(0xFF8B7EC8),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Container(
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
                    const Text(
                      'Đăng Ký',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: darkGray,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: softGray,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Họ Tên',
                          prefixIcon: Icon(Icons.person, color: primaryBlue),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: softGray,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email, color: primaryBlue),
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

                    Container(
                      decoration: BoxDecoration(
                        color: softGray,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Mật Khẩu',
                          prefixIcon: Icon(Icons.lock, color: primaryBlue),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        obscureText: true,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      decoration: BoxDecoration(
                        color: softGray,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Số Điện Thoại',
                          prefixIcon: Icon(Icons.phone, color: primaryBlue),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isVerificationSent) ...[
                      Container(
                        decoration: BoxDecoration(
                          color: softGray,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: TextField(
                          controller: _verificationCodeController,
                          decoration: InputDecoration(
                            labelText: 'Mã Xác Nhận',
                            prefixIcon: Icon(
                              Icons.verified,
                              color: primaryBlue,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
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
                            Icon(
                              Icons.error_outline,
                              color: errorRed,
                              size: 20,
                            ),
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
                                onPressed: _register,
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
                                      'Đăng Ký',
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
                    const SizedBox(height: 16),

                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Quay lại đăng nhập',
                        style: TextStyle(color: primaryBlue, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
