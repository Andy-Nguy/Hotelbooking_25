// lib/app.dart
import 'package:flutter/material.dart';
import 'screens/main_screen.dart'; // Import MainScreen sẽ tạo ở bước 2
import 'screens/home/home_screen.dart'; // Import HomeScreen sẽ tạo ở bước 3

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hotel Booking App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
