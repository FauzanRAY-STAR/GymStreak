import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/user_settings.dart';
import '../../app/theme/app_colors.dart';
import '../../app/utils/app_constants.dart';
import '../../app/widgets/info_row.dart';
import '../../app/widgets/stat_card.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final settings = controller.settings.value;
        if (settings == null) {
          return const Center(child: Text('Data pengaturan tidak ditemukan.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _ProfileHeaderCard(
              name: settings.name,
              goal: settings.fitnessGoal,
              onEdit: controller.openSettings,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Weekly Streak',
                    value: '${controller.currentStreak.value}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Streak Terpanjang',
                    value: '${controller.longestStreak.value}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total Workout',
                    value: '${controller.totalWorkouts.value}',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Target Mingguan',
                    value: '${settings.weeklyTarget}x',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _PreferencesCard(settings: settings),
            const SizedBox(height: 16),
            _ManageWorkoutCard(
              onScheduleTap: controller.openScheduleList,
              onHistoryTap: controller.openWorkoutList,
            ),
            const SizedBox(height: 16),
            _NotificationCard(
              reminderEnabled: settings.reminderEnabled,
              secondReminderEnabled: settings.secondReminderEnabled,
              onReminderChanged: controller.toggleReminder,
              onSecondReminderChanged: controller.toggleSecondReminder,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _confirmReset(context),
              icon: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
              ),
              label: const Text(
                'Reset Semua Data',
                style: TextStyle(color: AppColors.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      }),
    );
  }

  void _confirmReset(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reset Semua Data?'),
        content: const Text(
          'Semua data workout, jadwal, streak, dan pengaturan akan dihapus '
          'permanen. Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              Get.back();
              controller.resetAllData();
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

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({
    required this.name,
    required this.goal,
    required this.onEdit,
  });

  final String name;
  final String goal;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.accentMuted,
              child: Icon(
                Icons.person_rounded,
                color: AppColors.accent,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text(goal, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
            IconButton(icon: const Icon(Icons.edit_rounded), onPressed: onEdit),
          ],
        ),
      ),
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({required this.settings});

  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferensi Workout', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.flag_rounded,
              label: 'Target',
              value: '${settings.weeklyTarget}x per minggu',
            ),
            const SizedBox(height: 10),
            InfoRow(
              icon: Icons.calendar_today_rounded,
              label: 'Hari Workout',
              value: settings.workoutDays.map(AppConstants.dayLabel).join(', '),
            ),
            const SizedBox(height: 10),
            InfoRow(
              icon: Icons.access_time_rounded,
              label: 'Jam Pengingat',
              value: 'Diatur per jadwal',
            ),
          ],
        ),
      ),
    );
  }
}

class _ManageWorkoutCard extends StatelessWidget {
  const _ManageWorkoutCard({
    required this.onScheduleTap,
    required this.onHistoryTap,
  });

  final VoidCallback onScheduleTap;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(
              Icons.calendar_today_rounded,
              color: AppColors.accent,
            ),
            title: const Text('Jadwal Workout'),
            subtitle: const Text('Atur hari, jenis, dan jam pengingat'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onScheduleTap,
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: const Icon(Icons.history_rounded, color: AppColors.accent),
            title: const Text('Riwayat Workout'),
            subtitle: const Text('Lihat, tambah, edit, atau hapus workout'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: onHistoryTap,
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.reminderEnabled,
    required this.secondReminderEnabled,
    required this.onReminderChanged,
    required this.onSecondReminderChanged,
  });

  final bool reminderEnabled;
  final bool secondReminderEnabled;
  final ValueChanged<bool> onReminderChanged;
  final ValueChanged<bool> onSecondReminderChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Pengingat Workout'),
              subtitle: const Text('Notifikasi jam workout sesuai jadwal'),
              value: reminderEnabled,
              onChanged: onReminderChanged,
            ),
            SwitchListTile(
              title: const Text('Pengingat Kedua'),
              subtitle: const Text(
                'Ingatkan lagi jika workout belum diselesaikan',
              ),
              value: secondReminderEnabled,
              onChanged: onSecondReminderChanged,
            ),
          ],
        ),
      ),
    );
  }
}
