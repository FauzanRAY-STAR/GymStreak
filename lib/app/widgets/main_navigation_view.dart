import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/calendar/calendar_view.dart';
import '../../features/home/home_view.dart';
import '../../features/nutrition/nutrition_view.dart';
import '../../features/profile/profile_view.dart';
import '../controllers/main_navigation_controller.dart';
import '../theme/app_colors.dart';

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
        bottomNavigationBar: _LiquidNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.changeTab,
        ),
      ),
    );
  }
}

class _LiquidNavigationBar extends StatelessWidget {
  const _LiquidNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  static const List<_NavigationItem> _items = [
    _NavigationItem(
      icon: Icons.home_rounded,
      label: 'Beranda',
    ),
    _NavigationItem(
      icon: Icons.calendar_month_rounded,
      label: 'Kalender',
    ),
    _NavigationItem(
      icon: Icons.restaurant_rounded,
      label: 'Nutrisi',
    ),
    _NavigationItem(
      icon: Icons.person_rounded,
      label: 'Profil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.divider,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 76,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / _items.length;

              return Stack(
                alignment: Alignment.center,
                children: [
                  // Liquid indicator
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 320),
                    curve: Curves.easeOutCubic,
                    left: (itemWidth * currentIndex) + 8,
                    top: 9,
                    width: itemWidth - 16,
                    height: 56,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withValues(alpha: 0.16),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  ),

                  Row(
                    children: List.generate(
                      _items.length,
                          (index) {
                        final item = _items[index];
                        final selected = currentIndex == index;

                        return Expanded(
                          child: InkWell(
                            onTap: () => onTap(index),
                            borderRadius: BorderRadius.circular(22),
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: SizedBox(
                              height: 76,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  AnimatedScale(
                                    duration:
                                    const Duration(milliseconds: 220),
                                    scale: selected ? 1.08 : 1,
                                    curve: Curves.easeOutBack,
                                    child: Icon(
                                      item.icon,
                                      size: 25,
                                      color: selected
                                          ? AppColors.background
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedDefaultTextStyle(
                                    duration:
                                    const Duration(milliseconds: 220),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: selected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: selected
                                          ? AppColors.background
                                          : AppColors.textSecondary,
                                    ),
                                    child: Text(item.label),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;
}