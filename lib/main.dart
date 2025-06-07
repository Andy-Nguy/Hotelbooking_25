import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'package:flutter_hotelbooking_25/screens/booking_detail_screen.dart';
import 'package:flutter_hotelbooking_25/screens/booking_screen.dart';
import 'package:flutter_hotelbooking_25/screens/home/home_screen.dart';
import 'package:flutter_hotelbooking_25/screens/hotel_details_screen.dart';
import 'package:flutter_hotelbooking_25/screens/login_screen.dart';
import 'package:flutter_hotelbooking_25/screens/main_screen.dart';
import 'package:flutter_hotelbooking_25/screens/user/UserProfile_screen.dart';
import 'package:flutter_hotelbooking_25/screens/payment_Screen.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_hotelbooking_25/screens/admin/admin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Xóa hoặc tạm thời comment dòng resetDatabase()
  // await DatabaseHelper.instance.resetDatabase(); // Chỉ gọi khi cần thiết
  await DatabaseHelper.instance.database; // Khởi tạo DB
  Workmanager().initialize(callbackDispatcher, isInDebugMode: true); //
  runApp(const MyApp());
}

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final dbHelper = DatabaseHelper.instance;
    final idPhong = inputData?['idPhong'] as int?;
    if (idPhong != null) {
      await dbHelper.updateRoomStatus(
        idPhong,
        1,
      ); // Trả phòng về trạng thái trống
    }
    return Future.value(true);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Booking',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin': (context) => const AdminScreen(),
        '/home': (context) => const MainScreen(),
        '/user_profile': (context) => const UserProfileScreen(),
        '/booking_detail': (context) => const BookingDetailScreen(),
        '/payment': (context) => const PaymentScreen(),
        '/hotel_details':
            (context) => const HotelDetailsScreen(
              hotelId: 1,
              hotelName: 'Khách sạn mẫu',
            ),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/booking') {
          final args = settings.arguments as Map<String, dynamic>?;
          final idLoaiPhong = args?['idLoaiPhong'] as int?;
          final roomType = args?['roomType'] as Map<String, dynamic>?;
          if (idLoaiPhong != null && roomType != null) {
            return MaterialPageRoute(
              builder:
                  (context) => BookingScreen(
                    idLoaiPhong: idLoaiPhong,
                    roomType: roomType,
                  ),
            );
          }
        }
        return null;
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
