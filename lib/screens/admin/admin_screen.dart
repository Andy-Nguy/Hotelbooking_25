import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'xetduyet_moi_page.dart';
import 'xetduyet_hethan_page.dart';
import 'quanly_account_page.dart';
import 'thongtin_phong_page.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;

  final List<Widget> _tabs = [
    const XetDuyetMoiScreen(),
    const XetDuyetHetHanPage(),
    const ThongTinPhongPage(),
    const QuanLyAccountPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('idNguoiDung');
    await prefs.remove('role');
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Quản trị hệ thống'),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _tabs[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Màu cho item được chọn
        unselectedItemColor: Colors.grey[600], // Màu cho item không chọn
        backgroundColor: Colors.white, // Đặt màu nền rõ ràng
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ), // Tùy chỉnh style label
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Duyệt mới',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Hết hạn'),
          BottomNavigationBarItem(
            icon: Icon(Icons.hotel),
            label: 'Thông tin phòng',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}
