import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:gymstreak/app/theme/app_theme.dart';
import 'package:gymstreak/features/onboarding/onboarding_controller.dart';
import 'package:gymstreak/features/onboarding/onboarding_view.dart';

// Widget test ini sengaja tidak menyentuh database (lihat
// test/database/database_helper_test.dart untuk pengujian SQLite end-to-end)
// agar cepat dan stabil di lingkungan `flutter test`.
void main() {
  tearDown(() => Get.reset());

  testWidgets(
    'OnboardingView menampilkan seluruh bagian form yang dibutuhkan',
    (tester) async {
      Get.put(OnboardingController());

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.dark, home: const OnboardingView()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Selamat Datang di GymStreak'), findsOneWidget);
      expect(find.text('Nama Kamu'), findsOneWidget);
      expect(find.text('Target Workout per Minggu'), findsOneWidget);
      expect(find.text('Hari Workout'), findsOneWidget);
      expect(find.text('Jam Pengingat'), findsOneWidget);
      expect(find.text('Tujuanmu'), findsOneWidget);
      expect(find.text('Mulai'), findsOneWidget);
    },
  );
}
