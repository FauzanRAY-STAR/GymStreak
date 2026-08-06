import 'package:get/get.dart';

import 'schedule_form_controller.dart';

class ScheduleFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduleFormController>(() => ScheduleFormController());
  }
}
