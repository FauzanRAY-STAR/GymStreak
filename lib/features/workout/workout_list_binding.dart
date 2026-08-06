import 'package:get/get.dart';

import 'workout_list_controller.dart';

class WorkoutListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkoutListController>(() => WorkoutListController());
  }
}
