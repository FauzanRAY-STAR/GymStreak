import 'package:get/get.dart';

import '../data/services/notification_service.dart';
import '../utils/clock_service.dart';

/// Binding global yang didaftarkan sekali saat aplikasi pertama kali start.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ClockService>(ClockService(), permanent: true);
    Get.put<NotificationService>(NotificationService.instance, permanent: true);
  }
}
