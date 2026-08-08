import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/recipe.dart';
import '../../app/theme/app_colors.dart';
import '../../app/widgets/recipe_image.dart';
import 'recipe_detail_controller.dart';

class RecipeDetailView extends GetView<RecipeDetailController> {
  const RecipeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final recipe = controller.recipe.value;

      return Scaffold(
        appBar: AppBar(
          title: const Text('Detail Resep'),
          actions: [
            if (recipe != null)
              IconButton(
                tooltip: recipe.isFavorite
                    ? 'Hapus dari favorit'
                    : 'Tambahkan ke favorit',
                onPressed: controller.toggleFavorite,
                icon: Icon(
                  recipe.isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: recipe.isFavorite
                      ? AppColors.accent
                      : AppColors.textPrimary,
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: _buildBody(context, recipe),
      );
    });
  }

  Widget _buildBody(
      BuildContext context,
      Recipe? recipe,
      ) {
    if (controller.isLoading.value) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (recipe == null) {
      return Center(
        child: Text(
          controller.errorMessage.value,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        RecipeImage(
          recipe: recipe,
          width: double.infinity,
          height: 260,
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(
            20,
            22,
            20,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                recipe.name,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                recipe.description,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 20),

              _RecipeMetrics(recipe: recipe),

              if (recipe.categories.isNotEmpty) ...[
                const SizedBox(height: 16),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: recipe.categories
                      .map(
                        (category) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius:
                        BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                      .toList(),
                ),
              ],

              const SizedBox(height: 30),

              const _SectionHeader(
                icon: Icons.shopping_basket_rounded,
                title: 'Bahan-bahan',
              ),

              const SizedBox(height: 12),

              _IngredientsCard(
                ingredients: recipe.ingredients,
              ),

              const SizedBox(height: 30),

              const _SectionHeader(
                icon: Icons.menu_book_rounded,
                title: 'Cara Membuat',
              ),

              const SizedBox(height: 12),

              ...recipe.steps.indexed.map(
                    (entry) => _StepItem(
                  number: entry.$1 + 1,
                  text: entry.$2,
                  isLast:
                  entry.$1 == recipe.steps.length - 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecipeMetrics extends StatelessWidget {
  const _RecipeMetrics({
    required this.recipe,
  });

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon: Icons.bolt_rounded,
            value:
            '${recipe.estimatedProtein.toStringAsFixed(0)} g',
            label: 'Protein',
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _MetricCard(
            icon:
            Icons.local_fire_department_rounded,
            value:
            recipe.estimatedCalories.toStringAsFixed(0),
            label: 'Kalori',
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _MetricCard(
            icon: Icons.schedule_rounded,
            value:
            '${recipe.cookingTimeMinutes} mnt',
            label: recipe.difficulty,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.accent,
            size: 19,
          ),

          const SizedBox(height: 7),

          Text(
            value,
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style:
            Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.accent
                .withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppColors.accent,
            size: 19,
          ),
        ),

        const SizedBox(width: 11),

        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _IngredientsCard extends StatelessWidget {
  const _IngredientsCard({
    required this.ingredients,
  });

  final List<String> ingredients;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: ingredients.indexed.map(
              (entry) {
            final index = entry.$1;
            final ingredient = entry.$2;

            return Column(
              children: [
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22,
                      height: 22,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accent
                            .withValues(alpha: 0.12),
                        borderRadius:
                        BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: AppColors.accent,
                        size: 14,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        ingredient,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          color:
                          AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),

                if (index !=
                    ingredients.length - 1) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                ],
              ],
            );
          },
        ).toList(),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  const _StepItem({
    required this.number,
    required this.text,
    required this.isLast,
  });

  final int number;
  final String text;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: AppColors.background,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),

                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin:
                      const EdgeInsets.symmetric(
                        vertical: 6,
                      ),
                      color: AppColors.divider,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Container(
              margin:
              const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius:
                BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.divider,
                ),
              ),
              child: Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}