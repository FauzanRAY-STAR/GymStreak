import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../app/data/models/workout_session.dart';
import '../../app/theme/app_colors.dart';
import '../../app/widgets/workout_session_tile.dart';
import 'calendar_controller.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value && controller.sessionsByDate.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            onRefresh: () =>
                controller.loadMonth(controller.focusedMonth.value),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
              children: [
                const _CalendarHeader(),

                const SizedBox(height: 24),

                _CalendarCard(controller: controller),

                const SizedBox(height: 14),

                const _LegendRow(),

                const SizedBox(height: 28),

                _SelectedDateDetail(controller: controller),

                const SizedBox(height: 28),

                _MonthlyOverview(controller: controller),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kalender',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pantau konsistensi workout kamu.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          _MonthSwitcher(controller: controller),

          const SizedBox(height: 12),

          _MonthCalendar(controller: controller),
        ],
      ),
    );
  }
}

class _MonthSwitcher extends StatelessWidget {
  const _MonthSwitcher({required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final month = controller.focusedMonth.value;

    return Row(
      children: [
        _MonthButton(
          icon: Icons.chevron_left_rounded,
          onTap: () {
            controller.onPageChanged(DateTime(month.year, month.month - 1, 1));
          },
        ),

        Expanded(
          child: Text(
            DateFormat('MMMM yyyy', 'id_ID').format(month),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),

        _MonthButton(
          icon: Icons.chevron_right_rounded,
          onTap: () {
            controller.onPageChanged(DateTime(month.year, month.month + 1, 1));
          },
        ),
      ],
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(icon, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    return TableCalendar<WorkoutSession>(
      startingDayOfWeek: StartingDayOfWeek.monday,
      locale: 'id_ID',
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(2035, 12, 31),
      focusedDay: controller.focusedMonth.value,
      selectedDayPredicate: (day) =>
          isSameDay(day, controller.selectedDate.value),
      onDaySelected: (selected, focused) {
        controller.selectDate(selected);
      },
      onPageChanged: controller.onPageChanged,
      headerVisible: false,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Bulan'},
      rowHeight: 48,
      daysOfWeekHeight: 30,
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) =>
            _DayCell(controller: controller, day: day),
        outsideBuilder: (context, day, focusedDay) =>
            _DayCell(controller: controller, day: day, isOutside: true),
        todayBuilder: (context, day, focusedDay) =>
            _DayCell(controller: controller, day: day, isToday: true),
        selectedBuilder: (context, day, focusedDay) =>
            _DayCell(controller: controller, day: day, isSelected: true),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.controller,
    required this.day,
    this.isToday = false,
    this.isSelected = false,
    this.isOutside = false,
  });

  final CalendarController controller;
  final DateTime day;

  final bool isToday;
  final bool isSelected;
  final bool isOutside;

  @override
  Widget build(BuildContext context) {
    final intensity = controller.heaviestIntensity(day);

    final workoutColor = _intensityColor(intensity);

    final hasWorkout = intensity != null;

    return Container(
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: hasWorkout
            ? workoutColor.withValues(
                alpha: intensity == WorkoutIntensity.berat ? 0.95 : 0.55,
              )
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? Border.all(color: AppColors.accent, width: 2)
            : isToday
            ? Border.all(color: AppColors.textSecondary, width: 1)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: isOutside
              ? AppColors.textMuted
              : intensity == WorkoutIntensity.berat
              ? AppColors.background
              : AppColors.textPrimary,
          fontSize: 13,
          fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(color: AppColors.heatmapNone, label: 'Kosong'),
        SizedBox(width: 12),
        _LegendItem(color: AppColors.heatmapLight, label: 'Ringan'),
        SizedBox(width: 12),
        _LegendItem(color: AppColors.heatmapMedium, label: 'Sedang'),
        SizedBox(width: 12),
        _LegendItem(color: AppColors.heatmapHeavy, label: 'Berat'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),

        const SizedBox(width: 5),

        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: AppColors.textPrimary.withValues(alpha: 0.72),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _SelectedDateDetail extends StatelessWidget {
  const _SelectedDateDetail({required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final date = controller.selectedDate.value;
    final sessions = controller.sessionsFor(date);
    final schedule = controller.scheduleFor(date);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aktivitas',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date),
          style: theme.textTheme.bodySmall,
        ),

        const SizedBox(height: 12),

        if (sessions.isNotEmpty)
          ...sessions.map((session) => WorkoutSessionTile(session: session))
        else if (schedule != null)
          _ScheduledWorkoutCard(
            workoutType: schedule.workoutType,
            reminderTime: schedule.reminderTime,
          )
        else
          const _NoWorkoutCard(),
      ],
    );
  }
}

class _ScheduledWorkoutCard extends StatelessWidget {
  const _ScheduledWorkoutCard({
    required this.workoutType,
    required this.reminderTime,
  });

  final String workoutType;
  final String reminderTime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: AppColors.accent,
              size: 20,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  workoutType,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      reminderTime,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  'Belum diselesaikan',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NoWorkoutCard extends StatelessWidget {
  const _NoWorkoutCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.self_improvement_rounded,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tidak ada workout',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Hari tanpa latihan atau rest day.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MonthlyOverview extends StatelessWidget {
  const _MonthlyOverview({required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final percentage = controller.monthlyTargetPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ringkasan Bulan',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          DateFormat(
            'MMMM yyyy',
            'id_ID',
          ).format(controller.focusedMonth.value),
          style: theme.textTheme.bodySmall,
        ),

        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _StatItem(
                      icon: Icons.fitness_center_rounded,
                      value: '${controller.monthlyTotalWorkouts}',
                      label: 'Workout',
                    ),
                  ),

                  const _StatDivider(),

                  Expanded(
                    child: _StatItem(
                      icon: Icons.timer_rounded,
                      value: '${controller.monthlyTotalMinutes}',
                      label: 'Menit',
                    ),
                  ),

                  const _StatDivider(),

                  Expanded(
                    child: _StatItem(
                      icon: Icons.local_fire_department_rounded,
                      value: '${controller.currentStreak.value}',
                      label: 'Streak',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Target mingguan tercapai',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          controller.weeksTotalInMonth.value == 0
                              ? '-'
                              : '${percentage.round()}%',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: LinearProgressIndicator(
                        value: controller.weeksTotalInMonth.value == 0
                            ? 0
                            : (percentage / 100).clamp(0.0, 1.0),
                        minHeight: 8,
                        backgroundColor: AppColors.background,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.accent,
                        ),
                      ),
                    ),

                    if (controller.weeksTotalInMonth.value > 0) ...[
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${controller.weeksAchievedInMonth.value} dari '
                          '${controller.weeksTotalInMonth.value} minggu tercapai',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
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
        Icon(icon, color: AppColors.accent, size: 20),

        const SizedBox(height: 7),

        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),

        const SizedBox(height: 2),

        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 44, color: AppColors.divider);
  }
}

Color _intensityColor(WorkoutIntensity? intensity) {
  switch (intensity) {
    case WorkoutIntensity.ringan:
      return AppColors.heatmapLight;

    case WorkoutIntensity.sedang:
      return AppColors.heatmapMedium;

    case WorkoutIntensity.berat:
      return AppColors.heatmapHeavy;

    case null:
      return AppColors.heatmapNone;
  }
}
