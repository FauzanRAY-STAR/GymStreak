import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/app_constants.dart';

/// Baris chip pemilihan hari (Senin-Minggu), bisa memilih lebih dari satu.
class DayChipsSelector extends StatelessWidget {
  const DayChipsSelector({
    super.key,
    required this.selectedDays,
    required this.onToggle,
  });

  final Set<int> selectedDays;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final day = index + 1;
        final selected = selectedDays.contains(day);
        return FilterChip(
          label: Text(AppConstants.dayLabel(day)),
          selected: selected,
          onSelected: (_) => onToggle(day),
          labelStyle: TextStyle(
            color: selected ? const Color(0xFF0B1210) : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
          checkmarkColor: const Color(0xFF0B1210),
        );
      }),
    );
  }
}
