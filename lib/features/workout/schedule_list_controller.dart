import 'package:get/get.dart';

import '../../app/data/models/workout_schedule.dart';
import '../../app/data/repositories/workout_schedule_repository.dart';
import '../../app/routes/app_routes.dart';

class ScheduleListController extends GetxController {
  ScheduleListController({WorkoutScheduleRepository? repository})
    : _repository = repository ?? WorkoutScheduleRepository();

  final WorkoutScheduleRepository _repository;

  final RxList<WorkoutSchedule> schedules = <WorkoutSchedule>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    isLoading.value = true;
    final all = await _repository.getAll();
    schedules.value = all;
    isLoading.value = false;
  }

  Future<void> addSchedule() async {
    final result = await Get.toNamed(AppRoutes.scheduleForm);
    if (result == true) {
      await loadSchedules();
    }
  }

  Future<void> editSchedule(WorkoutSchedule schedule) async {
    final result = await Get.toNamed(
      AppRoutes.scheduleForm,
      arguments: schedule,
    );
    if (result == true) {
      await loadSchedules();
    }
  }

  Future<void> toggleActive(WorkoutSchedule schedule, bool active) async {
    await _repository.update(schedule.copyWith(active: active));
    await loadSchedules();
  }

  Future<void> deleteSchedule(int id) async {
    await _repository.delete(id);
    await loadSchedules();
  }
}
