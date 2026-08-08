import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/widgets/day_chips_selector.dart';
import '../../app/widgets/goal_chips_selector.dart';
import '../../app/widgets/stepper_button.dart';
import 'settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  12,
                  20,
                  24,
                ),
                children: [
                  Text(
                    'Sesuaikan profil dan rutinitas workout kamu.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  _SectionCard(
                    title: 'Informasi Dasar',
                    icon: Icons.person_rounded,
                    child: TextField(
                      controller: controller.nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        hintText: 'Masukkan nama kamu',
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: 'Target Mingguan',
                    icon: Icons.flag_rounded,
                    child: Obx(
                          () => Row(
                        children: [
                          StepperButton(
                            icon: Icons.remove_rounded,
                            onTap: () {
                              controller.setWeeklyTarget(
                                controller.weeklyTarget.value - 1,
                              );
                            },
                          ),

                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  '${controller.weeklyTarget.value}x',
                                  style: theme
                                      .textTheme.headlineMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'per minggu',
                                  style:
                                  theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),

                          StepperButton(
                            icon: Icons.add_rounded,
                            onTap: () {
                              controller.setWeeklyTarget(
                                controller.weeklyTarget.value + 1,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: 'Hari Workout',
                    icon: Icons.calendar_month_rounded,
                    subtitle:
                    'Pilih hari sesuai target mingguan kamu.',
                    child: Obx(
                          () => DayChipsSelector(
                        selectedDays:
                        controller.workoutDays.toSet(),
                        onToggle: controller.toggleDay,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  _SectionCard(
                    title: 'Preferensi',
                    icon: Icons.tune_rounded,
                    child: Column(
                      children: [
                        Obx(
                              () => _SettingRow(
                            icon: Icons.schedule_rounded,
                            title: 'Jam Pengingat',
                            value:
                            controller.reminderTimeLabel,
                            onTap: () {
                              controller.pickReminderTime(
                                context,
                              );
                            },
                          ),
                        ),

                        const Divider(height: 25),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tujuanmu',
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Obx(
                                () => GoalChipsSelector(
                              selectedGoal:
                              controller.fitnessGoal.value,
                              onSelected:
                              controller.selectFitnessGoal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(
                    color: AppColors.divider,
                  ),
                ),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  child: Obx(
                        () => ElevatedButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.save,
                      child: controller.isSaving.value
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.background,
                        ),
                      )
                          : const Text(
                        'Simpan Perubahan',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style:
                        theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 4,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppColors.accent,
                size: 22,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              Text(
                value,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(width: 5),

              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}