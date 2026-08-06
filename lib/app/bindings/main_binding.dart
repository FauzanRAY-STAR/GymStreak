import 'package:get/get.dart';

import '../../features/calendar/calendar_controller.dart';
import '../../features/home/home_controller.dart';
import '../../features/nutrition/nutrition_controller.dart';
import '../../features/profile/profile_controller.dart';
import '../controllers/main_navigation_controller.dart';

/// Binding untuk shell navigasi utama (bottom navigation) beserta
/// controller tab yang aktif sejak shell dimuat.
class MainBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainNavigationController>(() => MainNavigationController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<CalendarController>(() => CalendarController());
    Get.lazyPut<NutritionController>(() => NutritionController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
