import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/theme/app_colors.dart';
import '../../app/widgets/single_day_chips_selector.dart';
import '../../app/widgets/workout_type_chips_selector.dart';
import 'schedule_form_controller.dart';

class ScheduleFormView extends GetView<ScheduleFormController> {
  const ScheduleFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          controller.isEditing
              ? 'Edit Jadwal'
              : 'Tambah Jadwal',
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                28,
              ),
              children: [
                Text(
                  controller.isEditing
                      ? 'Sesuaikan jadwal workout kamu.'
                      : 'Atur rutinitas workout untuk hari tertentu.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 22),

                _SectionCard(
                  icon: Icons.calendar_month_rounded,
                  title: 'Hari Workout',
                  subtitle:
                  'Pilih hari untuk jadwal ini.',
                  child: Obx(
                        () => SingleDayChipsSelector(
                      selectedDay:
                      controller.dayOfWeek.value,
                      onSelected:
                      controller.selectDay,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                _SectionCard(
                  icon: Icons.fitness_center_rounded,
                  title: 'Jenis Workout',
                  subtitle:
                  'Pilih jenis latihan yang akan dilakukan.',
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Obx(
                            () =>
                            WorkoutTypeChipsSelector(
                              selectedType:
                              controller
                                  .workoutType.value,
                              onSelected:
                              controller.selectType,
                            ),
                      ),

                      Obx(() {
                        if (controller
                            .workoutType.value !=
                            'Custom Workout') {
                          return const SizedBox
                              .shrink();
                        }

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            top: 14,
                          ),
                          child: TextField(
                            controller: controller
                                .customTypeController,
                            decoration:
                            const InputDecoration(
                              labelText:
                              'Nama Workout',
                              hintText:
                              'Contoh: Upper Body',
                              prefixIcon: Icon(
                                Icons
                                    .edit_rounded,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                _SectionCard(
                  icon: Icons.notifications_rounded,
                  title: 'Pengingat',
                  subtitle:
                  'Atur waktu dan status pengingat.',
                  child: Column(
                    children: [
                      Obx(
                            () => _SettingRow(
                          icon:
                          Icons.schedule_rounded,
                          title:
                          'Jam Pengingat',
                          value: controller
                              .reminderTimeLabel,
                          onTap: () =>
                              controller
                                  .pickReminderTime(
                                context,
                              ),
                        ),
                      ),

                      const Padding(
                        padding:
                        EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        child: Divider(
                          height: 1,
                        ),
                      ),

                      Obx(
                            () => _ScheduleToggle(
                          value:
                          controller.active.value,
                          onChanged:
                          controller.setActive,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _SaveArea(
            isSaving:
            controller.isSaving,
            isEditing:
            controller.isEditing,
            onSave: controller.save,
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors
                      .accent
                      .withValues(
                    alpha: 0.10,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    13,
                  ),
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
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w700,
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
        borderRadius:
        BorderRadius.circular(14),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(
            vertical: 5,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors
                      .surfaceElevated,
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.accent,
                  size: 19,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: theme
                      .textTheme
                      .bodyMedium
                      ?.copyWith(
                    color:
                    AppColors.textPrimary,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors
                      .surfaceElevated,
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(width: 5),

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

class _ScheduleToggle
    extends StatelessWidget {
  const _ScheduleToggle({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color:
            AppColors.surfaceElevated,
            borderRadius:
            BorderRadius.circular(12),
          ),
          child: Icon(
            value
                ? Icons
                .notifications_active_rounded
                : Icons
                .notifications_off_rounded,
            color: value
                ? AppColors.accent
                : AppColors.textMuted,
            size: 19,
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Aktifkan Jadwal',
                style: theme
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color:
                  AppColors.textPrimary,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value
                    ? 'Pengingat akan mengikuti jadwal ini.'
                    : 'Jadwal disimpan tanpa pengingat aktif.',
                style:
                theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        Transform.scale(
          scale: 0.88,
          child: Switch(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}

class _SaveArea extends StatelessWidget {
  const _SaveArea({
    required this.isSaving,
    required this.isEditing,
    required this.onSave,
  });

  final RxBool isSaving;
  final bool isEditing;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
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
              onPressed:
              isSaving.value
                  ? null
                  : onSave,
              child: isSaving.value
                  ? const SizedBox(
                width: 20,
                height: 20,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                  color:
                  AppColors.background,
                ),
              )
                  : Text(
                isEditing
                    ? 'Simpan Perubahan'
                    : 'Simpan Jadwal',
              ),
            ),
          ),
        ),
      ),
    );
  }
}