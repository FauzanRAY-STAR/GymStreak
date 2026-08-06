import 'package:get/get.dart';

/// Mengatur tab aktif pada BottomNavigationBar utama.
class MainNavigationController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }
}
