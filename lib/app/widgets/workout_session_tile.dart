import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/models/workout_session.dart';
import '../theme/app_colors.dart';

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

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: AppColors.divider,
            ),
          ),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _intensityColor
                      .withValues(alpha: 0.12),
                  borderRadius:
                  BorderRadius.circular(15),
                ),
                child: Icon(
                  Icons.fitness_center_rounded,
                  color: _intensityColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.workoutType,
                      style: theme
                          .textTheme
                          .titleMedium
                          ?.copyWith(
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      DateFormat(
                        'EEEE, d MMM yyyy',
                        'id_ID',
                      ).format(
                        session.workoutDate,
                      ),
                      style: theme.textTheme.bodySmall,
                    ),

                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.schedule_rounded,
                          label:
                          '${session.durationMinutes} menit',
                        ),
                        _InfoChip(
                          icon:
                          Icons.bolt_rounded,
                          label:
                          session.intensity.label,
                          color: _intensityColor,
                        ),
                      ],
                    ),

                    if (session.notes != null &&
                        session.notes!
                            .trim()
                            .isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        session.notes!,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: theme
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color: AppColors
                              .textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (onDelete != null)
                PopupMenuButton<String>(
                  tooltip: 'Opsi workout',
                  icon: const Icon(
                    Icons.more_vert_rounded,
                    color:
                    AppColors.textSecondary,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons
                                .delete_outline_rounded,
                            color: AppColors.error,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Hapus workout',
                            style: TextStyle(
                              color:
                              AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else if (onTap != null)
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor =
        color ?? AppColors.textSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: effectiveColor,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: effectiveColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}