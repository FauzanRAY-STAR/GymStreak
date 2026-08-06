import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/workout_schedule.dart';
import '../../app/theme/app_colors.dart';
import '../../app/utils/app_constants.dart';
import 'schedule_list_controller.dart';

class ScheduleListView extends GetView<ScheduleListController> {
  const ScheduleListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jadwal Workout')),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addSchedule,
        child: const Icon(Icons.add_rounded),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.schedules.isEmpty) {
          return const _EmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: controller.schedules.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final schedule = controller.schedules[index];
            return _ScheduleCard(
              schedule: schedule,
              onTap: () => controller.editSchedule(schedule),
              onActiveChanged: (value) =>
                  controller.toggleActive(schedule, value),
              onDelete: () => _confirmDelete(context, schedule),
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, WorkoutSchedule schedule) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: Text(
          'Jadwal "${schedule.workoutType}" pada hari '
          '${AppConstants.dayLabel(schedule.dayOfWeek)} akan dihapus.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteSchedule(schedule.id!);
            },
            child: const Text(
              'Hapus',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.schedule,
    required this.onTap,
    required this.onActiveChanged,
    required this.onDelete,
  });

  final WorkoutSchedule schedule;
  final VoidCallback onTap;
  final ValueChanged<bool> onActiveChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppConstants.dayLabel(schedule.dayOfWeek),
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${schedule.workoutType} • ${schedule.reminderTime}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Switch(value: schedule.active, onChanged: onActiveChanged),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                ),
                onPressed: onDelete,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_today_rounded,
              size: 56,
              color: AppColors.accent,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada jadwal workout',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tekan tombol + untuk menambah jadwal baru.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
