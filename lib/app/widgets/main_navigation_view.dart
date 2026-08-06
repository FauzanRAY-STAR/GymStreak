import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/calendar/calendar_view.dart';
import '../../features/home/home_view.dart';
import '../../features/nutrition/nutrition_view.dart';
import '../../features/profile/profile_view.dart';
import '../controllers/main_navigation_controller.dart';

/// Shell utama aplikasi berisi BottomNavigationBar dengan 4 menu:
/// Beranda, Kalender, Nutrisi, dan Profil.
class MainNavigationView extends GetView<MainNavigationController> {
  const MainNavigationView({super.key});

  static const List<Widget> _pages = [
    HomeView(),
    CalendarView(),
    NutritionView(),
    ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: _pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Kalender',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_rounded),
              label: 'Nutrisi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
