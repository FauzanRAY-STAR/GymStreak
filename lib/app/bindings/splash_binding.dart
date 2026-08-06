import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put (bukan lazyPut) supaya SplashController langsung dibuat saat
    // halaman ini dibangun. SplashView tidak membaca state apa pun dari
    // controller, jadi tanpa instansiasi langsung, onInit/onReady tidak akan
    // pernah terpanggil dan _decideNextRoute tidak akan pernah berjalan.
    Get.put<SplashController>(SplashController());
  }
}
