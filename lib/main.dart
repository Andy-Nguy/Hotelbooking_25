// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';
import 'app.dart'; // Import file app.dart sẽ tạo ở bước 2

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.resetDatabase();

  runApp(const MyApp());
}
