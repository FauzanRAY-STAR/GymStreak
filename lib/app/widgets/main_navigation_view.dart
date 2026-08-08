import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/calendar/calendar_view.dart';
import '../../features/home/home_view.dart';
import '../../features/nutrition/nutrition_view.dart';
import '../../features/profile/profile_view.dart';
import '../controllers/main_navigation_controller.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';
import '../../features/home/home_controller.dart';
import '../data/repositories/workout_session_repository.dart';
import '../utils/app_date_utils.dart';
import '../utils/clock_service.dart';

class MainNavigationView extends GetView<MainNavigationController> {
  const MainNavigationView({super.key});

  static const List<Widget> _pages = [
    HomeView(),
    CalendarView(),
    NutritionView(),
    ProfileView(),
  ];
  Future<void> _openWorkout() async {
    final repository = WorkoutSessionRepository();
    final clock = Get.find<ClockService>();

    final today = AppDateUtils.dateOnly(clock.now());

    final existingWorkout =
    await repository.getOneByDate(today);

    dynamic arguments;

    if (existingWorkout != null) {
      // Workout hari ini sudah ada:
      // buka workout tersebut dalam mode edit.
      arguments = existingWorkout;
    } else {
      // Belum ada workout:
      // gunakan jadwal hari ini sebagai default bila tersedia.
      final homeController = Get.find<HomeController>();
      final schedule = homeController.todaySchedule.value;

      if (schedule != null) {
        arguments = {
          'workoutType': schedule.workoutType,
        };
      }
    }

    final result = await Get.toNamed(
      AppRoutes.workoutForm,
      arguments: arguments,
    );

    if (result == true &&
        Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().loadHome();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Obx(
          () => Scaffold(
        extendBody: false,

        body: IndexedStack(
          index: controller.currentIndex.value,
          children: _pages,
        ),

        // Tombol workout di tengah
        floatingActionButtonLocation:
        FloatingActionButtonLocation.centerDocked,

            floatingActionButton: _WorkoutButton(
              onTap: _openWorkout,
            ),

        bottomNavigationBar: _GymBottomNavigation(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}

class _WorkoutButton extends StatelessWidget {
  const _WorkoutButton({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.16),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: FloatingActionButton(
        heroTag: 'workout_quick_action',
        onPressed: onTap,
        elevation: 0,
        highlightElevation: 0,
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        shape: const CircleBorder(),
        tooltip: 'Catat Workout',
        child: const Icon(
          Icons.fitness_center_rounded,
          size: 25,
        ),
      ),
    );
  }
}

class _GymBottomNavigation extends StatelessWidget {
  const _GymBottomNavigation({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.surface,
      elevation: 0,
      notchMargin: 10,
      shape: const CircularNotchedRectangle(),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 70,
          child: Row(
            children: [
              Expanded(
                child: _NavigationItem(
                  icon: Icons.home_rounded,
                  label: 'Beranda',
                  selected: currentIndex == 0,
                  onTap: () => onTap(0),
                ),
              ),

              Expanded(
                child: _NavigationItem(
                  icon: Icons.calendar_month_rounded,
                  label: 'Kalender',
                  selected: currentIndex == 1,
                  onTap: () => onTap(1),
                ),
              ),

              // Ruang untuk tombol workout tengah
              const SizedBox(width: 72),

              Expanded(
                child: _NavigationItem(
                  icon: Icons.restaurant_rounded,
                  label: 'Nutrisi',
                  selected: currentIndex == 2,
                  onTap: () => onTap(2),
                ),
              ),

              Expanded(
                child: _NavigationItem(
                  icon: Icons.person_rounded,
                  label: 'Profil',
                  selected: currentIndex == 3,
                  onTap: () => onTap(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppColors.accent
        : AppColors.textSecondary;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: SizedBox(
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutBack,
              child: Icon(
                icon,
                size: 24,
                color: color,
              ),
            ),

            const SizedBox(height: 5),

            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight:
                selected ? FontWeight.w700 : FontWeight.w500,
                color: color,
              ),
              child: Text(label),
            ),

            const SizedBox(height: 3),

            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: selected ? 18 : 0,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}