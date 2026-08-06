import 'package:get/get.dart';

import '../data/repositories/user_settings_repository.dart';
import '../routes/app_routes.dart';

/// Menentukan halaman awal aplikasi: Onboarding untuk pengguna baru, atau
/// langsung ke shell utama jika onboarding sudah pernah diselesaikan.
class SplashController extends GetxController {
  final UserSettingsRepository _repository = UserSettingsRepository();

  @override
  void onReady() {
    super.onReady();
    _decideNextRoute();
  }

  Future<void> _decideNextRoute() async {
    final settings = await _repository.getSettings();
    if (settings != null && settings.onboardingCompleted) {
      Get.offAllNamed(AppRoutes.main);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
