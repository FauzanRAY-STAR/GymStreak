import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app/data/models/workout_session.dart';
import '../../app/theme/app_colors.dart';
import '../../app/widgets/workout_session_tile.dart';
import 'workout_list_controller.dart';

class WorkoutListView extends GetView<WorkoutListController> {
  const WorkoutListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Workout')),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addWorkout,
        child: const Icon(Icons.add_rounded),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.sessions.isEmpty) {
          return const _EmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: controller.sessions.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final session = controller.sessions[index];
            return WorkoutSessionTile(
              session: session,
              onTap: () => controller.editWorkout(session),
              onDelete: () => _confirmDelete(context, session),
            );
          },
        );
      }),
    );
  }

  void _confirmDelete(BuildContext context, WorkoutSession session) {
    Get.dialog(
      AlertDialog(
        title: const Text('Hapus Workout?'),
        content: Text(
          'Catatan workout "${session.workoutType}" pada '
          '${DateFormat('d MMMM yyyy', 'id_ID').format(session.workoutDate)} '
          'akan dihapus permanen.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteWorkout(session);
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
              Icons.fitness_center_rounded,
              size: 56,
              color: AppColors.accent,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada workout tercatat',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tekan tombol + untuk mencatat workout pertamamu.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
