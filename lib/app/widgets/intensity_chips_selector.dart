import 'package:flutter/material.dart';

import '../data/models/workout_session.dart';
import '../theme/app_colors.dart';

/// Baris chip pemilihan intensitas workout (single-select).
class IntensityChipsSelector extends StatelessWidget {
  const IntensityChipsSelector({
    super.key,
    required this.selectedIntensity,
    required this.onSelected,
  });

  final WorkoutIntensity selectedIntensity;
  final ValueChanged<WorkoutIntensity> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: WorkoutIntensity.values.map((value) {
        final selected = selectedIntensity == value;
        return ChoiceChip(
          label: Text(value.label),
          selected: selected,
          onSelected: (_) => onSelected(value),
          labelStyle: TextStyle(
            color: selected ? const Color(0xFF0B1210) : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
