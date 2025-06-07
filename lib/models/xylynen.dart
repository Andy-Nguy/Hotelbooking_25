import 'package:flutter/material.dart';
import 'package:flutter_hotelbooking_25/app.dart';
import 'package:workmanager/workmanager.dart';
import 'package:flutter_hotelbooking_25/db/database_helper.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final dbHelper = DatabaseHelper.instance;
    final idPhong = inputData?['idPhong'] as int?;
    print("Running background task for idPhong: $idPhong"); // Log để debug
    if (idPhong != null) {
      await dbHelper.updateRoomStatus(idPhong, 1); // Cập nhật trạng thái trống
      print("Room $idPhong updated to vacant");
    }
    return Future.value(true);
  });
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await DatabaseHelper.instance.database; // Khởi tạo DB
//   Workmanager().initialize(
//     callbackDispatcher,
//     isInDebugMode: true, // Bật debug để xem log
//   );
//   runApp(const MyApp());
// }

void scheduleRoomRelease(int idPhong, DateTime checkOutTime) {
  final now = DateTime.now();
  final delay = checkOutTime.add(const Duration(hours: 1)).difference(now);
  print(
    "Scheduling room release for idPhong: $idPhong at ${checkOutTime.add(const Duration(hours: 1))} with delay: $delay",
  );
  Workmanager().registerOneOffTask(
    "task-release-room-$idPhong",
    "releaseRoom",
    initialDelay: delay,
    inputData: {'idPhong': idPhong},
  );
}
