import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/recipe.dart';
import '../../app/theme/app_colors.dart';
import '../../app/widgets/recipe_card.dart';
import '../../app/widgets/recipe_image.dart';
import 'nutrition_controller.dart';

class NutritionView extends GetView<NutritionController> {
  const NutritionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nutrisi'),
        actions: [
          Obx(
            () => IconButton(
              tooltip: controller.favoritesOnly.value
                  ? 'Tampilkan semua resep'
                  : 'Tampilkan resep favorit',
              onPressed: controller.toggleFavoritesOnly,
              icon: Icon(
                controller.favoritesOnly.value
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: controller.favoritesOnly.value ? AppColors.accent : null,
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadNutrition,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _DailyRecommendationCard(
                recipe: controller.todayRecommendation.value,
                changing: controller.isChangingRecommendation.value,
                onOpen: () {
                  final recipe = controller.todayRecommendation.value;
                  if (recipe != null) controller.openRecipe(recipe);
                },
                onChange: controller.changeRecommendation,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller.searchController,
                onChanged: controller.updateSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Cari resep, bahan, atau kategori',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: controller.searchQuery.value.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Hapus pencarian',
                          onPressed: controller.clearSearch,
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 18),
              _FilterSection(
                title: 'Bahan utama',
                options: controller.ingredientOptions,
                selected: controller.selectedIngredient.value,
                onSelected: controller.selectIngredient,
              ),
              const SizedBox(height: 14),
              _FilterSection(
                title: 'Kategori',
                options: controller.categoryOptions,
                selected: controller.selectedCategory.value,
                onSelected: controller.selectCategory,
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      controller.favoritesOnly.value
                          ? 'Resep Favorit'
                          : 'Semua Resep',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    '${controller.filteredRecipes.length} resep',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (controller.filteredRecipes.isEmpty)
                _EmptyResult(onReset: controller.clearFilters)
              else
                ...controller.filteredRecipes.map(
                  (recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RecipeCard(
                      recipe: recipe,
                      onTap: () => controller.openRecipe(recipe),
                      onFavoriteChanged: (value) =>
                          controller.toggleFavorite(recipe, value),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _DailyRecommendationCard extends StatelessWidget {
  const _DailyRecommendationCard({
    required this.recipe,
    required this.changing,
    required this.onOpen,
    required this.onChange,
  });

  final Recipe? recipe;
  final bool changing;
  final VoidCallback onOpen;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (recipe == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            'Rekomendasi resep belum tersedia.',
            style: theme.textTheme.bodyMedium,
          ),
        ),
      );
    }

    final item = recipe!;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onOpen,
            child: RecipeImage(
              recipe: item,
              width: double.infinity,
              height: 190,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rekomendasi Hari Ini',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 6),
                Text(item.name, style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _Metric(
                      icon: Icons.bolt_rounded,
                      label:
                          '${item.estimatedProtein.toStringAsFixed(0)} g protein',
                    ),
                    _Metric(
                      icon: Icons.local_fire_department_rounded,
                      label:
                          '${item.estimatedCalories.toStringAsFixed(0)} kkal',
                    ),
                    _Metric(
                      icon: Icons.schedule_rounded,
                      label: '${item.cookingTimeMinutes} menit',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onOpen,
                        child: const Text('Lihat Resep'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: changing ? null : onChange,
                      icon: changing
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.refresh_rounded),
                      label: const Text('Ganti'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final String title;
  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options
                .map(
                  (option) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(option),
                      selected: selected == option,
                      selectedColor: AppColors.accent,
                      checkmarkColor: Colors.black,
                      labelStyle: TextStyle(
                        color: selected == option
                            ? Colors.black
                            : AppColors.textPrimary,
                        fontWeight: selected == option
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      onSelected: (_) => onSelected(option),
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 17, color: AppColors.accent),
        const SizedBox(width: 5),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(
              Icons.search_off_rounded,
              color: AppColors.textSecondary,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              'Resep tidak ditemukan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 6),
            Text(
              'Coba kata pencarian atau filter yang berbeda.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 14),
            TextButton(onPressed: onReset, child: const Text('Reset Filter')),
          ],
        ),
      ),
    );
  }
}
