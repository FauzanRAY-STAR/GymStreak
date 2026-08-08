import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../app/data/models/workout_session.dart';
import '../../app/theme/app_colors.dart';
import '../../app/widgets/workout_session_tile.dart';
import 'workout_list_controller.dart';

class WorkoutListView extends GetView<WorkoutListController> {
  const WorkoutListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Workout'),
        actions: [
          IconButton(
            onPressed: controller.addWorkout,
            tooltip: 'Tambah workout',
            icon: const Icon(
              Icons.add_rounded,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.sessions.isEmpty) {
          return _EmptyState(
            onAdd: controller.addWorkout,
          );
        }

        final groupedSessions =
        _groupSessionsByMonth(controller.sessions);

        final totalMinutes = controller.sessions.fold<int>(
          0,
              (sum, session) => sum + session.durationMinutes,
        );

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            20,
            8,
            20,
            32,
          ),
          children: [
            _HistorySummary(
              totalWorkouts: controller.sessions.length,
              totalMinutes: totalMinutes,
              totalMonths: groupedSessions.length,
            ),

            const SizedBox(height: 26),

            Text(
              'Riwayat per Bulan',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Buka bulan untuk melihat workout.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 14),

            ...groupedSessions.entries.indexed.map(
                  (entry) {
                final index = entry.$1;
                final monthEntry = entry.$2;

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: _MonthSection(
                    month: monthEntry.key,
                    sessions: monthEntry.value,
                    initiallyExpanded: index == 0,
                    onEdit: controller.editWorkout,
                    onDelete: (session) =>
                        _confirmDelete(
                          context,
                          session,
                        ),
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }

  Map<DateTime, List<WorkoutSession>> _groupSessionsByMonth(
      List<WorkoutSession> sessions,
      ) {
    final grouped =
    <DateTime, List<WorkoutSession>>{};

    for (final session in sessions) {
      final month = DateTime(
        session.workoutDate.year,
        session.workoutDate.month,
      );

      grouped.putIfAbsent(
        month,
            () => [],
      );

      grouped[month]!.add(session);
    }

    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return {
      for (final key in sortedKeys)
        key: grouped[key]!,
    };
  }

  void _confirmDelete(
      BuildContext context,
      WorkoutSession session,
      ) {
    Get.dialog(
      AlertDialog(
        title: const Text(
          'Hapus Workout?',
        ),
        content: Text(
          'Catatan workout "${session.workoutType}" '
              'pada ${DateFormat('d MMMM yyyy', 'id_ID').format(session.workoutDate)} '
              'akan dihapus permanen.',
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteWorkout(
                session,
              );
            },
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({
    required this.totalWorkouts,
    required this.totalMinutes,
    required this.totalMonths,
  });

  final int totalWorkouts;
  final int totalMinutes;
  final int totalMonths;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SummaryItem(
              icon: Icons.fitness_center_rounded,
              value: '$totalWorkouts',
              label: 'Workout',
            ),
          ),

          const _SummaryDivider(),

          Expanded(
            child: _SummaryItem(
              icon: Icons.timer_rounded,
              value: '$totalMinutes',
              label: 'Menit',
            ),
          ),

          const _SummaryDivider(),

          Expanded(
            child: _SummaryItem(
              icon: Icons.calendar_month_rounded,
              value: '$totalMonths',
              label: 'Bulan Aktif',
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.accent,
          size: 20,
        ),

        const SizedBox(height: 7),

        Text(
          value,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 45,
      color: AppColors.divider,
    );
  }
}

class _MonthSection extends StatefulWidget {
  const _MonthSection({
    required this.month,
    required this.sessions,
    required this.initiallyExpanded,
    required this.onEdit,
    required this.onDelete,
  });

  final DateTime month;
  final List<WorkoutSession> sessions;
  final bool initiallyExpanded;

  final ValueChanged<WorkoutSession> onEdit;
  final ValueChanged<WorkoutSession> onDelete;

  @override
  State<_MonthSection> createState() =>
      _MonthSectionState();
}

class _MonthSectionState extends State<_MonthSection> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final totalMinutes =
    widget.sessions.fold<int>(
      0,
          (sum, session) =>
      sum + session.durationMinutes,
    );

    final monthLabel = DateFormat(
      'MMMM yyyy',
      'id_ID',
    ).format(widget.month);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.accent
                            .withValues(
                          alpha: 0.10,
                        ),
                        borderRadius:
                        BorderRadius.circular(13),
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.accent,
                        size: 20,
                      ),
                    ),

                    const SizedBox(width: 13),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            monthLabel,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            '${widget.sessions.length} workout • '
                                '$totalMinutes menit',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                        ],
                      ),
                    ),

                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(
                        milliseconds: 200,
                      ),
                      child: const Icon(
                        Icons
                            .keyboard_arrow_down_rounded,
                        color:
                        AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                const Divider(height: 1),

                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    12,
                    12,
                    2,
                  ),
                  child: Column(
                    children: widget.sessions
                        .map(
                          (session) => Padding(
                        padding:
                        const EdgeInsets.only(
                          bottom: 10,
                        ),
                        child: WorkoutSessionTile(
                          session: session,
                          onTap: () =>
                              widget.onEdit(
                                session,
                              ),
                          onDelete: () =>
                              widget.onDelete(
                                session,
                              ),
                        ),
                      ),
                    )
                        .toList(),
                  ),
                ),
              ],
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(
              milliseconds: 220,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onAdd,
  });

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent
                    .withValues(alpha: 0.10),
                borderRadius:
                BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.fitness_center_rounded,
                size: 34,
                color: AppColors.accent,
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Belum ada workout',
              style: theme
                  .textTheme.titleLarge
                  ?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Workout yang sudah kamu selesaikan '
                  'akan muncul di sini.',
              textAlign: TextAlign.center,
              style:
              theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'Catat Workout',
              ),
            ),
          ],
        ),
      ),
    );
  }
}