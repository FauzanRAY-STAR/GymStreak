import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      appBar: AppBar(title: const Text('Edit Profil & Preferensi')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nama Kamu', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 8),
                    TextField(controller: controller.nameController),
                    const SizedBox(height: 24),

                    Text(
                      'Target Workout per Minggu',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => Row(
                        children: [
                          StepperButton(
                            icon: Icons.remove_rounded,
                            onTap: () => controller.setWeeklyTarget(
                              controller.weeklyTarget.value - 1,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                '${controller.weeklyTarget.value}x / minggu',
                                style: theme.textTheme.titleLarge,
                              ),
                            ),
                          ),
                          StepperButton(
                            icon: Icons.add_rounded,
                            onTap: () => controller.setWeeklyTarget(
                              controller.weeklyTarget.value + 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('Hari Workout', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Obx(
                      () => Text(
                        'Pilih maksimal ${controller.weeklyTarget.value} hari '
                        '(mengikuti target mingguan)',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Obx(
                      () => DayChipsSelector(
                        selectedDays: controller.workoutDays.toSet(),
                        onToggle: controller.toggleDay,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('Jam Pengingat', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Obx(
                      () => OutlinedButton.icon(
                        onPressed: () => controller.pickReminderTime(context),
                        icon: const Icon(Icons.access_time_rounded),
                        label: Text(controller.reminderTimeLabel),
                      ),
                    ),
                    const SizedBox(height: 24),

                    Text('Tujuanmu', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Obx(
                      () => GoalChipsSelector(
                        selectedGoal: controller.fitnessGoal.value,
                        onSelected: controller.selectFitnessGoal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0B1210),
                            ),
                          )
                        : const Text('Simpan Perubahan'),
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
