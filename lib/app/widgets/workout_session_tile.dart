import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/workout_session.dart';
import '../theme/app_colors.dart';

/// Kartu ringkas satu [WorkoutSession]. [onDelete] opsional — jika null,
/// tombol hapus tidak ditampilkan (dipakai untuk ringkasan di Beranda).
class WorkoutSessionTile extends StatelessWidget {
  const WorkoutSessionTile({
    super.key,
    required this.session,
    this.onTap,
    this.onDelete,
  });

  final WorkoutSession session;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  Color get _intensityColor {
    switch (session.intensity) {
      case WorkoutIntensity.ringan:
        return AppColors.heatmapLight;
      case WorkoutIntensity.sedang:
        return AppColors.heatmapMedium;
      case WorkoutIntensity.berat:
        return AppColors.heatmapHeavy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 48,
                decoration: BoxDecoration(
                  color: _intensityColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.workoutType,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('EEEE, d MMM yyyy', 'id_ID').format(session.workoutDate)} '
                      '• ${session.durationMinutes} menit • ${session.intensity.label}',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (session.notes != null && session.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        session.notes!,
                        style: theme.textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
