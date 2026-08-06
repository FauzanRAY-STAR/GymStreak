import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/widgets/single_day_chips_selector.dart';
import '../../app/widgets/workout_type_chips_selector.dart';
import 'schedule_form_controller.dart';

class ScheduleFormView extends GetView<ScheduleFormController> {
  const ScheduleFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? 'Edit Jadwal' : 'Tambah Jadwal'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hari', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Obx(
                    () => SingleDayChipsSelector(
                      selectedDay: controller.dayOfWeek.value,
                      onSelected: controller.selectDay,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Jenis Workout', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Obx(
                    () => WorkoutTypeChipsSelector(
                      selectedType: controller.workoutType.value,
                      onSelected: controller.selectType,
                    ),
                  ),
                  Obx(() {
                    if (controller.workoutType.value != 'Custom Workout') {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: TextField(
                        controller: controller.customTypeController,
                        decoration: const InputDecoration(
                          hintText: 'Nama workout custom kamu',
                        ),
                      ),
                    );
                  }),
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

                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Aktifkan Jadwal'),
                      subtitle: const Text(
                        'Notifikasi pengingat hanya dikirim untuk jadwal aktif',
                      ),
                      value: controller.active.value,
                      onChanged: controller.setActive,
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
                  onPressed: controller.isSaving.value ? null : controller.save,
                  child: controller.isSaving.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF0B1210),
                          ),
                        )
                      : const Text('Simpan'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
