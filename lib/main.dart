import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/bindings/initial_binding.dart';
import 'app/data/database/database_helper.dart';
import 'app/data/services/notification_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');

  // Memastikan database dan seed resep siap sebelum UI dirender.
  await DatabaseHelper.instance.database;

  // Inisialisasi local notification, lalu pulihkan jadwal yang sudah
  // tersimpan tanpa menampilkan prompt izin secara paksa saat startup.
  try {
    await NotificationService.instance.initialize();
    await NotificationService.instance.syncFromStoredSettings();
  } catch (error, stackTrace) {
    debugPrint('Gagal menginisialisasi notifikasi: $error');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(const GymStreakApp());
}

class GymStreakApp extends StatelessWidget {
  const GymStreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GymStreak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      initialRoute: AppRoutes.splash,
      initialBinding: InitialBinding(),
      getPages: AppPages.pages,
    );
  }
}
