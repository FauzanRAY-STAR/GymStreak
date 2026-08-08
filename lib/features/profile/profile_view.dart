import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/user_settings.dart';
import '../../app/theme/app_colors.dart';
import '../../app/utils/app_constants.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final settings = controller.settings.value;

          if (settings == null) {
            return const Center(
              child: Text(
                'Data pengaturan tidak ditemukan.',
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadProfile,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                48,
              ),
              children: [
                _ProfileTitle(
                  reminderEnabled: settings.reminderEnabled,
                  secondReminderEnabled: settings.secondReminderEnabled,
                  onNotificationTap: controller.cycleNotificationMode,
                ),

                const SizedBox(height: 20),

                _ProfileHeaderCard(
                  name: settings.name,
                  goal: settings.fitnessGoal,
                  onEdit: controller.openSettings,
                ),

                const SizedBox(height: 16),

                _StatsOverviewCard(
                  currentStreak:
                  controller.currentStreak.value,
                  longestStreak:
                  controller.longestStreak.value,
                  totalWorkouts:
                  controller.totalWorkouts.value,
                ),

                const SizedBox(height: 28),

                const _SectionTitle(
                  title: 'Preferensi',
                  subtitle:
                  'Pengaturan latihan kamu',
                ),

                const SizedBox(height: 12),

                _PreferencesCard(
                  settings: settings,
                ),

                const SizedBox(height: 28),

                const _SectionTitle(
                  title: 'Workout',
                  subtitle:
                  'Kelola jadwal dan riwayat latihan',
                ),

                const SizedBox(height: 12),

                _WorkoutManagementCard(
                  onScheduleTap:
                  controller.openScheduleList,
                  onHistoryTap:
                  controller.openWorkoutList,
                ),
                const SizedBox(height: 28),

                _ResetButton(
                  onPressed: () =>
                      _confirmReset(context),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _confirmReset(
      BuildContext context,
      ) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Reset Semua Data?',
        ),
        content: const Text(
          'Semua data workout, jadwal, streak, '
              'dan pengaturan akan dihapus permanen. '
              'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.resetAllData();
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

class _ProfileTitle extends StatelessWidget {
  const _ProfileTitle({
    required this.reminderEnabled,
    required this.secondReminderEnabled,
    required this.onNotificationTap,
  });

  final bool reminderEnabled;
  final bool secondReminderEnabled;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    IconData notificationIcon;

    if (!reminderEnabled) {
      notificationIcon =
          Icons.notifications_off_rounded;
    } else if (secondReminderEnabled) {
      notificationIcon =
          Icons.notifications_active_rounded;
    } else {
      notificationIcon =
          Icons.notifications_rounded;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Profil',
                style: theme
                    .textTheme.headlineMedium
                    ?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pantau progres dan atur preferensi kamu.',
                style:
                theme.textTheme.bodySmall?.copyWith(
                  color:
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Material(
          color: AppColors.surface,
          borderRadius:
          BorderRadius.circular(14),
          child: InkWell(
            onTap: onNotificationTap,
            borderRadius:
            BorderRadius.circular(14),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.divider,
                ),
              ),
              child: Icon(
                notificationIcon,
                color: reminderEnabled
                    ? AppColors.accent
                    : AppColors.textSecondary,
                size: 23,
              ),
            ),
          ),
        ),
      ],
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

    final initial = name.trim().isEmpty
        ? '?'
        : name
        .trim()
        .substring(0, 1)
        .toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A261F),
            Color(0xFF202F20),
          ],
        ),
        border: Border.all(
          color: AppColors.accent
              .withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.accentMuted,
              borderRadius:
              BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.accent
                    .withValues(alpha: 0.25),
              ),
            ),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.accent,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style:
                  theme.textTheme.titleLarge?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 7),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent
                        .withValues(alpha: 0.10),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Text(
                    goal,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: onEdit,
            tooltip: 'Edit profil',
            icon: const Icon(
              Icons.edit_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsOverviewCard extends StatelessWidget {
  const _StatsOverviewCard({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalWorkouts,
  });

  final int currentStreak;
  final int longestStreak;
  final int totalWorkouts;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons
                  .local_fire_department_rounded,
              value: '$currentStreak',
              label: 'Streak',
            ),
          ),

          const _VerticalDivider(),

          Expanded(
            child: _StatItem(
              icon:
              Icons.emoji_events_rounded,
              value: '$longestStreak',
              label: 'Terbaik',
            ),
          ),

          const _VerticalDivider(),

          Expanded(
            child: _StatItem(
              icon:
              Icons.fitness_center_rounded,
              value: '$totalWorkouts',
              label: 'Workout',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.accent,
          size: 20,
        ),

        const SizedBox(height: 7),

        Text(
          value,
          style:
          theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style:
          theme.textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 48,
      color: AppColors.divider,
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
          theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          subtitle,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard({
    required this.settings,
  });

  final UserSettings settings;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          _PreferenceItem(
            icon: Icons.flag_rounded,
            title: 'Target Mingguan',
            value:
            '${settings.weeklyTarget}x per minggu',
          ),

          const _HorizontalDivider(),

          _PreferenceItem(
            icon:
            Icons.calendar_month_rounded,
            title: 'Hari Workout',
            value: settings.workoutDays
                .map(AppConstants.dayLabel)
                .join(', '),
          ),

          const _HorizontalDivider(),

          const _PreferenceItem(
            icon: Icons.schedule_rounded,
            title: 'Jam Pengingat',
            value: 'Diatur per jadwal',
          ),
        ],
      ),
    );
  }
}

class _PreferenceItem extends StatelessWidget {
  const _PreferenceItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
              AppColors.surfaceElevated,
              borderRadius:
              BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.accent,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                  theme.textTheme.bodyMedium
                      ?.copyWith(
                    color:
                    AppColors.textPrimary,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style:
                  theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkoutManagementCard
    extends StatelessWidget {
  const _WorkoutManagementCard({
    required this.onScheduleTap,
    required this.onHistoryTap,
  });

  final VoidCallback onScheduleTap;
  final VoidCallback onHistoryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          _MenuItem(
            icon:
            Icons.calendar_month_rounded,
            title: 'Jadwal Workout',
            subtitle:
            'Atur hari, jenis, dan jam latihan',
            onTap: onScheduleTap,
          ),

          const _HorizontalDivider(),

          _MenuItem(
            icon: Icons.history_rounded,
            title: 'Riwayat Workout',
            subtitle:
            'Lihat dan kelola workout sebelumnya',
            onTap: onHistoryTap,
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color:
                  AppColors.surfaceElevated,
                  borderRadius:
                  BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: AppColors.accent,
                  size: 21,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme
                          .textTheme.bodyMedium
                          ?.copyWith(
                        color:
                        AppColors.textPrimary,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      subtitle,
                      style:
                      theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color:
                AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HorizontalDivider
    extends StatelessWidget {
  const _HorizontalDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }
}

class _ResetButton extends StatelessWidget {
  const _ResetButton({
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(
          Icons.delete_outline_rounded,
          color: AppColors.error,
        ),
        label: const Text(
          'Reset Semua Data',
          style: TextStyle(
            color: AppColors.error,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: AppColors.error
                .withValues(alpha: 0.5),
          ),
          padding:
          const EdgeInsets.symmetric(
            vertical: 15,
          ),
        ),
      ),
    );
  }
}