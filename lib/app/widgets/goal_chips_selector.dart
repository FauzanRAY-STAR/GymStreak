import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/app_constants.dart';

/// Baris chip pemilihan tujuan fitness (single-select).
class GoalChipsSelector extends StatelessWidget {
  const GoalChipsSelector({
    super.key,
    required this.selectedGoal,
    required this.onSelected,
  });

  final String selectedGoal;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AppConstants.fitnessGoals.map((goal) {
        final selected = selectedGoal == goal;
        return ChoiceChip(
          label: Text(goal),
          selected: selected,
          onSelected: (_) => onSelected(goal),
          labelStyle: TextStyle(
            color: selected ? const Color(0xFF0B1210) : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }
}
