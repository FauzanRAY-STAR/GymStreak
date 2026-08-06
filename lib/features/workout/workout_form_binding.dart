import 'package:get/get.dart';

import 'workout_form_controller.dart';

class WorkoutFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkoutFormController>(() => WorkoutFormController());
  }
}
