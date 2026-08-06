import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/app_constants.dart';

/// Baris chip pemilihan jenis workout (single-select), termasuk opsi
/// "Custom Workout".
class WorkoutTypeChipsSelector extends StatelessWidget {
  const WorkoutTypeChipsSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  final String selectedType;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.defaultWorkoutTypes.map((type) {
        final selected = selectedType == type;
        return ChoiceChip(
          label: Text(type),
          selected: selected,
          onSelected: (_) => onSelected(type),
          labelStyle: TextStyle(
            color: selected ? const Color(0xFF0B1210) : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
