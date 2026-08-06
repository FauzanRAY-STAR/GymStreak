import 'package:get/get.dart';

import 'schedule_list_controller.dart';

class ScheduleListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduleListController>(() => ScheduleListController());
  }
}
