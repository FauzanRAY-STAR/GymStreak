import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/recipe.dart';
import '../../app/data/models/workout_schedule.dart';
import '../../app/data/models/workout_session.dart';
import '../../app/theme/app_colors.dart';
import '../../app/widgets/recipe_image.dart';
import '../../app/widgets/stat_card.dart';
import '../../app/widgets/workout_session_tile.dart';
import 'home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beranda')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final settings = controller.settings.value;
        if (settings == null) {
          return const Center(child: Text('Data pengaturan tidak ditemukan.'));
        }

        return RefreshIndicator(
          onRefresh: controller.loadHome,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${controller.greeting}, ${settings.name}!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Semangat menjaga konsistensi workout-mu.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: 'Weekly Streak',
                      value: '${controller.currentStreak.value}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatCard(
                      label: 'Streak Terpanjang',
                      value: '${controller.longestStreak.value}',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _WeeklyProgressCard(
                completed: controller.weeklyCompletedDays.value,
                target: settings.weeklyTarget,
              ),
              const SizedBox(height: 16),
              _TodayWorkoutCard(
                schedule: controller.todaySchedule.value,
                isLogged: controller.isTodayLogged.value,
                onComplete: controller.completeWorkout,
              ),
              const SizedBox(height: 16),
              _DailyRecipeCard(
                recipe: controller.recipeRecommendation.value,
                onOpen: () {
                  final recipe = controller.recipeRecommendation.value;
                  if (recipe != null) controller.openRecipe(recipe);
                },
              ),
              const SizedBox(height: 16),
              _RecentWorkoutsSection(
                sessions: controller.recentSessions,
                onSeeAll: controller.viewAllWorkouts,
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _WeeklyProgressCard extends StatelessWidget {
  const _WeeklyProgressCard({required this.completed, required this.target});

  final int completed;
  final int target;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = target == 0 ? 0.0 : (completed / target).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Target Minggu Ini',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(value: progress, minHeight: 10),
            ),
            const SizedBox(height: 10),
            Text(
              '$completed dari $target hari selesai',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayWorkoutCard extends StatelessWidget {
  const _TodayWorkoutCard({
    required this.schedule,
    required this.isLogged,
    required this.onComplete,
  });

  final WorkoutSchedule? schedule;
  final bool isLogged;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSchedule = schedule != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasSchedule
                      ? Icons.fitness_center_rounded
                      : Icons.self_improvement_rounded,
                  color: AppColors.accent,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    hasSchedule ? 'Workout Hari Ini' : 'Rest Day',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                if (isLogged)
                  const Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.accent,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              hasSchedule
                  ? '${schedule!.workoutType} • ${schedule!.reminderTime}'
                  : 'Rest Day — waktunya pemulihan. Kamu tetap bisa mencatat workout kalau mau.',
              style: theme.textTheme.bodyMedium,
            ),
            if (isLogged) ...[
              const SizedBox(height: 4),
              const Text(
                'Sudah dicatat hari ini',
                style: TextStyle(color: AppColors.accent, fontSize: 12),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onComplete,
                child: const Text('Selesaikan Workout'),
              ),
            ),
          ],
        ),
      ),
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
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Rekomendasi resep belum tersedia.'),
        ),
      );
    }

    final item = recipe!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onOpen,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeImage(recipe: item, width: double.infinity, height: 165),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rekomendasi Resep Hari Ini',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(item.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.bolt_rounded,
                        size: 17,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${item.estimatedProtein.toStringAsFixed(0)} g protein',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.schedule_rounded,
                        size: 17,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '${item.cookingTimeMinutes} menit',
                        style: theme.textTheme.bodySmall,
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Workout Terbaru', style: theme.textTheme.titleMedium),
            TextButton(onPressed: onSeeAll, child: const Text('Lihat Semua')),
          ],
        ),
        const SizedBox(height: 8),
        if (sessions.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Belum ada workout tercatat. Yuk mulai workout pertamamu!',
                style: theme.textTheme.bodyMedium,
              ),
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
