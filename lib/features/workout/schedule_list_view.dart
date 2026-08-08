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
      appBar: AppBar(
        title: const Text('Jadwal Workout'),
        actions: [
          IconButton(
            onPressed: controller.addSchedule,
            tooltip: 'Tambah jadwal',
            icon: const Icon(
              Icons.add_rounded,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.schedules.isEmpty) {
          return _EmptyState(
            onAdd: controller.addSchedule,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                18,
              ),
              child: Text(
                'Atur rutinitas latihan mingguanmu.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  28,
                ),
                itemCount: controller.schedules.length,
                separatorBuilder: (_, _) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final schedule =
                  controller.schedules[index];

                  return _ScheduleCard(
                    schedule: schedule,
                    onTap: () =>
                        controller.editSchedule(schedule),
                    onActiveChanged: (value) =>
                        controller.toggleActive(
                          schedule,
                          value,
                        ),
                    onDelete: () =>
                        _confirmDelete(
                          context,
                          schedule,
                        ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }

  void _confirmDelete(
      BuildContext context,
      WorkoutSchedule schedule,
      ) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: Text(
          'Jadwal "${schedule.workoutType}" pada hari '
              '${AppConstants.dayLabel(schedule.dayOfWeek)} '
              'akan dihapus.',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteSchedule(
                schedule.id!,
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: AppColors.error,
              ),
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

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: schedule.active
                      ? AppColors.accent
                      .withValues(alpha: 0.12)
                      : AppColors.surfaceElevated,
                  borderRadius:
                  BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.calendar_month_rounded,
                  color: schedule.active
                      ? AppColors.accent
                      : AppColors.textMuted,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            AppConstants.dayLabel(
                              schedule.dayOfWeek,
                            ),
                            style: theme
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    Text(
                      schedule.workoutType,
                      style: theme
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                        color:
                        AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 15,
                          color: AppColors.accent,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          schedule.reminderTime,
                          style:
                          theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Transform.scale(
                scale: 0.78,
                child: Switch(
                  value: schedule.active,
                  onChanged: onActiveChanged,
                ),
              ),

              PopupMenuButton<String>(
                tooltip: 'Opsi jadwal',
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: AppColors.textSecondary,
                ),
                onSelected: (value) {
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: AppColors.error,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Hapus jadwal',
                          style: TextStyle(
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent
                    .withValues(alpha: 0.10),
                borderRadius:
                BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                size: 34,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Belum ada jadwal',
              style:
              theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tambahkan jadwal workout untuk '
                  'membangun rutinitas mingguan.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'Tambah Jadwal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}