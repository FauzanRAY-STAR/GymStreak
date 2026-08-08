import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app/data/models/workout_session.dart';
import '../../app/theme/app_colors.dart';
import '../../app/widgets/workout_session_tile.dart';
import 'workout_list_controller.dart';

class WorkoutListView
    extends GetView<WorkoutListController> {
  const WorkoutListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Workout'),
        actions: [
          IconButton(
            onPressed: controller.addWorkout,
            tooltip: 'Tambah workout',
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

        if (controller.sessions.isEmpty) {
          return _EmptyState(
            onAdd: controller.addWorkout,
          );
        }

        return Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                18,
              ),
              child: Text(
                '${controller.sessions.length} workout tersimpan',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color:
                  AppColors.textSecondary,
                ),
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  0,
                  20,
                  28,
                ),
                itemCount:
                controller.sessions.length,
                separatorBuilder: (_, _) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final session =
                  controller.sessions[index];

                  return WorkoutSessionTile(
                    session: session,
                    onTap: () =>
                        controller.editWorkout(
                          session,
                        ),
                    onDelete: () =>
                        _confirmDelete(
                          context,
                          session,
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
      WorkoutSession session,
      ) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Hapus Workout?',
        ),
        content: Text(
          'Catatan workout "${session.workoutType}" '
              'pada ${DateFormat('d MMMM yyyy', 'id_ID').format(session.workoutDate)} '
              'akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteWorkout(
                session,
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
                Icons.fitness_center_rounded,
                size: 34,
                color: AppColors.accent,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Belum ada workout',
              style:
              theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Workout yang sudah kamu selesaikan '
                  'akan muncul di sini.',
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
                'Catat Workout',
              ),
            ),
          ],
        ),
      ),
    );
  }
}