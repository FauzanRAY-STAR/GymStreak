import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../utils/app_constants.dart';

/// Baris chip pemilihan satu hari (Senin-Minggu), single-select. Dipakai
/// pada form jadwal workout (satu jadwal = satu hari).
class SingleDayChipsSelector extends StatelessWidget {
  const SingleDayChipsSelector({
    super.key,
    required this.selectedDay,
    required this.onSelected,
  });

  final int selectedDay;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final day = index + 1;
        final selected = selectedDay == day;
        return ChoiceChip(
          label: Text(AppConstants.dayLabel(day)),
          selected: selected,
          onSelected: (_) => onSelected(day),
          labelStyle: TextStyle(
            color: selected ? const Color(0xFF0B1210) : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }),
    );
  }
}
