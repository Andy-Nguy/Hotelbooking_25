// // lib/main.dart
// import 'package:flutter/material.dart';
// import 'package:flutter_hotelbooking_25/db/database_helper.dart';
// import 'app.dart'; // Import file app.dart sẽ tạo ở bước 2

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await DatabaseHelper.instance.resetDatabase();

//   runApp(const MyApp());
// }

import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/screens/UserProfile_screen.dart';
import 'package:flutter_hotelbooking_25/screens/booking_screen.dart';
import 'package:flutter_hotelbooking_25/screens/home/home_screen.dart';
import 'package:flutter_hotelbooking_25/screens/hotel_details_screen.dart';
import 'package:flutter_hotelbooking_25/screens/login_screen.dart';
import 'package:flutter_hotelbooking_25/screens/main_screen.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.resetDatabase();

  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
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
        '/home': (context) => const MainScreen(),
        '/user_profile': (context) => const UserProfileScreen(),
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
