// lib/app.dart
import 'package:flutter/material.dart';
import 'screens/home/home_screen.dart'; // Import HomeScreen sẽ tạo ở bước 3

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Marriott Bonvoy Mobile',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(), // Sử dụng HomeScreen thay vì HomePage
      debugShowCheckedModeBanner: false,
    );
  }
}
