import 'package:get/get.dart';

import '../../app/data/models/workout_schedule.dart';
import '../../app/data/repositories/workout_schedule_repository.dart';
import '../../app/data/services/workout_schedule_sync_service.dart';
import '../../app/routes/app_routes.dart';

class ScheduleListController extends GetxController {
  ScheduleListController({
    WorkoutScheduleRepository? repository,
    WorkoutScheduleSyncService? syncService,
  }) : _repository = repository ?? WorkoutScheduleRepository(),
       _syncService = syncService ?? WorkoutScheduleSyncService();

  final WorkoutScheduleRepository _repository;
  final WorkoutScheduleSyncService _syncService;

  final RxList<WorkoutSchedule> schedules = <WorkoutSchedule>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    isLoading.value = true;
    schedules.value = await _repository.getAll();
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
    if (active) {
      final validationMessage = await _syncService.validateSchedule(
        dayOfWeek: schedule.dayOfWeek,
        active: true,
        editingId: schedule.id,
      );
      if (validationMessage != null) {
        Get.snackbar('Jadwal tidak dapat diaktifkan', validationMessage);
        return;
      }
    }

    await _repository.update(schedule.copyWith(active: active));
    await _syncService.refreshSettingsFromSchedules();
    await loadSchedules();
  }

  Future<void> deleteSchedule(int id) async {
    await _repository.delete(id);
    await _syncService.refreshSettingsFromSchedules();
    await loadSchedules();
  }
}
