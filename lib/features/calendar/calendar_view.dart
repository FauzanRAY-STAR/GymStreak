import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../app/data/models/workout_session.dart';
import '../../app/theme/app_colors.dart';
import '../../app/widgets/info_row.dart';
import '../../app/widgets/workout_session_tile.dart';
import 'calendar_controller.dart';

class CalendarView extends GetView<CalendarController> {
  const CalendarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender'),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                controller.showHeatmap.value
                    ? Icons.calendar_month_rounded
                    : Icons.grid_on_rounded,
              ),
              tooltip: controller.showHeatmap.value
                  ? 'Tampilan Kalender'
                  : 'Tampilan Heatmap',
              onPressed: controller.toggleView,
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.sessionsByDate.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: controller.showHeatmap.value
                    ? _HeatmapGrid(controller: controller)
                    : _MonthCalendar(controller: controller),
              ),
            ),
            const SizedBox(height: 12),
            const _LegendRow(),
            const SizedBox(height: 16),
            _SelectedDateDetail(controller: controller),
            const SizedBox(height: 16),
            _MonthlyStatsCard(controller: controller),
          ],
        );
      }),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  const _MonthCalendar({required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    return TableCalendar<WorkoutSession>(
      locale: 'id_ID',
      firstDay: DateTime(2020, 1, 1),
      lastDay: DateTime(2035, 12, 31),
      focusedDay: controller.focusedMonth.value,
      currentDay: controller.selectedDate.value,
      selectedDayPredicate: (day) =>
          isSameDay(day, controller.selectedDate.value),
      onDaySelected: (selected, focused) {
        controller.selectDate(selected);
      },
      onPageChanged: controller.onPageChanged,
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {CalendarFormat.month: 'Bulan'},
      headerStyle: const HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
        leftChevronIcon: Icon(
          Icons.chevron_left_rounded,
          color: AppColors.textPrimary,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textPrimary,
        ),
      ),
      daysOfWeekStyle: const DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: AppColors.textSecondary),
        weekendStyle: TextStyle(color: AppColors.textSecondary),
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
    Color background;
    Color textColor = AppColors.textPrimary;
    switch (intensity) {
      case null:
        background = AppColors.heatmapNone;
        break;
      case WorkoutIntensity.ringan:
        background = AppColors.heatmapLight;
        break;
      case WorkoutIntensity.sedang:
        background = AppColors.heatmapMedium;
        break;
      case WorkoutIntensity.berat:
        background = AppColors.heatmapHeavy;
        textColor = const Color(0xFF0B1210);
        break;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: isSelected
            ? Border.all(color: AppColors.accent, width: 2)
            : isToday
            ? Border.all(color: AppColors.textPrimary, width: 1.2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: isOutside ? AppColors.textMuted : textColor,
          fontWeight: isToday ? FontWeight.w700 : FontWeight.normal,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _HeatmapGrid extends StatelessWidget {
  const _HeatmapGrid({required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final month = controller.focusedMonth.value;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstDay = DateTime(month.year, month.month, 1);
    // Kolom = hari dalam seminggu (Senin-Minggu), baris = minggu ke berapa.
    final leadingBlanks = firstDay.weekday - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            DateFormat('MMMM yyyy', 'id_ID').format(month),
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: leadingBlanks + daysInMonth,
            itemBuilder: (context, index) {
              if (index < leadingBlanks) return const SizedBox.shrink();
              final day = DateTime(
                month.year,
                month.month,
                index - leadingBlanks + 1,
              );
              final intensity = controller.heaviestIntensity(day);
              Color color;
              switch (intensity) {
                case null:
                  color = AppColors.heatmapNone;
                  break;
                case WorkoutIntensity.ringan:
                  color = AppColors.heatmapLight;
                  break;
                case WorkoutIntensity.sedang:
                  color = AppColors.heatmapMedium;
                  break;
                case WorkoutIntensity.berat:
                  color = AppColors.heatmapHeavy;
                  break;
              }
              final selected = isSameDay(day, controller.selectedDate.value);
              return GestureDetector(
                onTap: () => controller.selectDate(day),
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(6),
                    border: selected
                        ? Border.all(color: AppColors.accent, width: 2)
                        : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _LegendItem(color: AppColors.heatmapNone, label: 'Tidak ada'),
        _LegendItem(color: AppColors.heatmapLight, label: 'Ringan'),
        _LegendItem(color: AppColors.heatmapMedium, label: 'Sedang'),
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
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(date),
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            if (sessions.isEmpty)
              Text(
                'Tidak ada aktivitas workout pada tanggal ini.',
                style: theme.textTheme.bodyMedium,
              )
            else
              Column(
                children: sessions
                    .map(
                      (session) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: WorkoutSessionTile(session: session),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyStatsCard extends StatelessWidget {
  const _MonthlyStatsCard({required this.controller});

  final CalendarController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = controller.monthlyTargetPercentage;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Statistik Bulan Ini', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.fitness_center_rounded,
              label: 'Total Workout',
              value: '${controller.monthlyTotalWorkouts} kali',
            ),
            const SizedBox(height: 10),
            InfoRow(
              icon: Icons.timer_rounded,
              label: 'Total Durasi',
              value: '${controller.monthlyTotalMinutes} menit',
            ),
            const SizedBox(height: 10),
            InfoRow(
              icon: Icons.flag_rounded,
              label: 'Target Mingguan Tercapai',
              value: controller.weeksTotalInMonth.value == 0
                  ? '-'
                  : '${percentage.round()}% (${controller.weeksAchievedInMonth.value}/${controller.weeksTotalInMonth.value} minggu)',
            ),
            const SizedBox(height: 10),
            InfoRow(
              icon: Icons.local_fire_department_rounded,
              label: 'Weekly Streak',
              value: '${controller.currentStreak.value}',
            ),
          ],
        ),
      ),
    );
  }
}
