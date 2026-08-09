import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/recipe.dart';
import '../../app/data/models/workout_schedule.dart';
import '../../app/data/models/workout_session.dart';
import '../../app/theme/app_colors.dart';
import '../../app/widgets/recipe_image.dart';
import '../../app/widgets/workout_session_tile.dart';
import 'home_controller.dart';
import 'dart:io';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = controller.settings.value;

          if (settings == null) {
            return const Center(
              child: Text('Data pengaturan tidak ditemukan.'),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadHome,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
              children: [
                _HomeHeader(
                  greeting: controller.greeting,
                  name: settings.name,
                  imagePath: controller.profileImagePath.value,
                ),

                const SizedBox(height: 20),

                _StreakHeroCard(
                  currentStreak: controller.currentStreak.value,
                  longestStreak: controller.longestStreak.value,
                  completed: controller.weeklyCompletedDays.value,
                  target: settings.weeklyTarget,
                ),

                const SizedBox(height: 16),

                _TodayWorkoutCard(
                  schedule: controller.todaySchedule.value,
                  session: controller.todaySession.value,
                ),

                const SizedBox(height: 28),

                _SectionHeader(
                  title: 'Untuk Kamu',
                  subtitle: 'Rekomendasi makanan hari ini',
                ),

                const SizedBox(height: 12),

                _DailyRecipeCard(
                  recipe: controller.recipeRecommendation.value,
                  onOpen: () {
                    final recipe = controller.recipeRecommendation.value;

                    if (recipe != null) {
                      controller.openRecipe(recipe);
                    }
                  },
                ),

                const SizedBox(height: 28),

                _RecentWorkoutsSection(
                  sessions: controller.recentSessions,
                  onSeeAll: controller.viewAllWorkouts,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.greeting,
    required this.name,
    required this.imagePath,
  });

  final String greeting;
  final String name;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final initial = name.trim().isEmpty
        ? '?'
        : name.trim().substring(0, 1).toUpperCase();

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 3),
              Text(
                name,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tetap konsisten. Sedikit progres tetap progres.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.accentMuted,
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.30),
              width: 1.5,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: imagePath != null
              ? Image.file(File(imagePath!), fit: BoxFit.cover)
              : Center(
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _StreakHeroCard extends StatelessWidget {
  const _StreakHeroCard({
    required this.currentStreak,
    required this.longestStreak,
    required this.completed,
    required this.target,
  });

  final int currentStreak;
  final int longestStreak;
  final int completed;
  final int target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final progress = target <= 0 ? 0.0 : (completed / target).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A261F), Color(0xFF202F20)],
        ),
        border: Border.all(
          color: AppColors.accent.withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.06),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.local_fire_department_rounded,
                  color: AppColors.accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Streak Mingguan', style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      'Minggu berturut-turut mencapai target',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$currentStreak',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 44,
                  height: 1,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('minggu', style: theme.textTheme.bodyMedium),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Terbaik', style: theme.textTheme.bodySmall),
                  const SizedBox(height: 3),
                  Text(
                    '$longestStreak minggu',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Text(
                'Target minggu ini',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '$completed / $target hari',
                style: theme.textTheme.bodySmall?.copyWith(
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
              value: progress,
              minHeight: 9,
              backgroundColor: AppColors.surfaceElevated,
              valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({required this.schedule, required this.session});

  final WorkoutSchedule? schedule;
  final WorkoutSession? session;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasWorkout = session != null;
    final hasSchedule = schedule != null;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: hasWorkout
                  ? AppColors.accent.withValues(alpha: 0.12)
                  : AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              hasWorkout
                  ? Icons.check_rounded
                  : hasSchedule
                  ? Icons.fitness_center_rounded
                  : Icons.self_improvement_rounded,
              color: AppColors.accent,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasWorkout
                      ? 'Workout Selesai'
                      : hasSchedule
                      ? 'Workout Hari Ini'
                      : 'Rest Day',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                if (hasWorkout) ...[
                  Text(
                    session!.workoutType,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${session!.durationMinutes} menit'
                    ' • ${session!.intensity.label}',
                    style: theme.textTheme.bodySmall,
                  ),
                ] else if (hasSchedule) ...[
                  Text(
                    '${schedule!.workoutType} • '
                    '${schedule!.reminderTime}',
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 3),

                  Text(
                    'Belum diselesaikan',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Gunakan hari ini untuk pemulihan.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),

          if (hasWorkout)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Selesai',
                style: TextStyle(
                  color: AppColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(subtitle, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

class _DailyRecipeCard extends StatelessWidget {
  const _DailyRecipeCard({required this.recipe, required this.onOpen});

  final Recipe? recipe;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (recipe == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Text('Rekomendasi resep belum tersedia.'),
      );
    }

    final item = recipe!;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeImage(recipe: item, width: double.infinity, height: 175),

            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      _RecipeMetric(
                        icon: Icons.bolt_rounded,
                        text: '${item.estimatedProtein.toStringAsFixed(0)} g',
                      ),
                      const SizedBox(width: 16),
                      _RecipeMetric(
                        icon: Icons.local_fire_department_rounded,
                        text:
                            '${item.estimatedCalories.toStringAsFixed(0)} kkal',
                      ),
                      const SizedBox(width: 16),
                      _RecipeMetric(
                        icon: Icons.schedule_rounded,
                        text: '${item.cookingTimeMinutes} mnt',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeMetric extends StatelessWidget {
  const _RecipeMetric({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.accent, size: 16),
        const SizedBox(width: 5),
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _RecentWorkoutsSection extends StatelessWidget {
  const _RecentWorkoutsSection({
    required this.sessions,
    required this.onSeeAll,
  });

  final List<WorkoutSession> sessions;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Workout Terbaru',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            TextButton(onPressed: onSeeAll, child: const Text('Lihat Semua')),
          ],
        ),

        const SizedBox(height: 10),

        if (sessions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.fitness_center_rounded,
                  size: 34,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 12),
                Text(
                  'Belum ada workout tercatat',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 5),
                Text(
                  'Workout yang kamu selesaikan akan muncul di sini.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          )
        else
          Column(
            children: sessions
                .map(
                  (session) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: WorkoutSessionTile(session: session),
                  ),
                )
                .toList(),
          ),
      ],
    );
  }
}
