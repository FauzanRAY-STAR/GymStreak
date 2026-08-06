import 'package:get/get.dart';

import '../../features/onboarding/onboarding_binding.dart';
import '../../features/onboarding/onboarding_view.dart';
import '../../features/profile/settings_binding.dart';
import '../../features/profile/settings_view.dart';
import '../../features/workout/schedule_form_binding.dart';
import '../../features/workout/schedule_form_view.dart';
import '../../features/workout/schedule_list_binding.dart';
import '../../features/workout/schedule_list_view.dart';
import '../../features/workout/workout_form_binding.dart';
import '../../features/workout/workout_form_view.dart';
import '../../features/workout/workout_list_binding.dart';
import '../../features/workout/workout_list_view.dart';
import '../bindings/main_binding.dart';
import '../bindings/splash_binding.dart';
import '../widgets/main_navigation_view.dart';
import '../widgets/splash_view.dart';
import 'app_routes.dart';

/// Daftar GetPage aplikasi. Route fitur lain (detail resep, dll.)
/// ditambahkan pada tahap implementasi masing-masing.
class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.main,
      page: () => const MainNavigationView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.workoutList,
      page: () => const WorkoutListView(),
      binding: WorkoutListBinding(),
    ),
    GetPage(
      name: AppRoutes.workoutForm,
      page: () => const WorkoutFormView(),
      binding: WorkoutFormBinding(),
    ),
    GetPage(
      name: AppRoutes.scheduleList,
      page: () => const ScheduleListView(),
      binding: ScheduleListBinding(),
    ),
    GetPage(
      name: AppRoutes.scheduleForm,
      page: () => const ScheduleFormView(),
      binding: ScheduleFormBinding(),
    ),
  ];
}
