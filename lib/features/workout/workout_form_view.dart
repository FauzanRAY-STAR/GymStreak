import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app/widgets/intensity_chips_selector.dart';
import '../../app/widgets/workout_type_chips_selector.dart';
import 'workout_form_controller.dart';

class WorkoutFormView extends GetView<WorkoutFormController> {
  const WorkoutFormView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditing ? 'Edit Workout' : 'Tambah Workout'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Jenis Workout', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Obx(
                    () => WorkoutTypeChipsSelector(
                      selectedType: controller.workoutType.value,
                      onSelected: controller.selectWorkoutType,
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

                  Text('Tanggal', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Obx(
                    () => OutlinedButton.icon(
                      onPressed: () => controller.pickDate(context),
                      icon: const Icon(Icons.calendar_today_rounded),
                      label: Text(
                        DateFormat(
                          'EEEE, d MMMM yyyy',
                          'id_ID',
                        ).format(controller.workoutDate.value),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text('Durasi (menit)', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.durationController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: 'Contoh: 45'),
                  ),
                  const SizedBox(height: 24),

                  Text('Intensitas', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Obx(
                    () => IntensityChipsSelector(
                      selectedIntensity: controller.intensity.value,
                      onSelected: controller.selectIntensity,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    'Catatan (opsional)',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller.notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: PR bench press 60kg',
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
