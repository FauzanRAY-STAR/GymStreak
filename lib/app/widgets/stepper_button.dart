import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tombol bulat kecil untuk menambah/mengurangi nilai numerik, mis. target
/// workout mingguan.
class StepperButton extends StatelessWidget {
  const StepperButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
