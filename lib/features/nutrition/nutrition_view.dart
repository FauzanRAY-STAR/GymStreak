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
      body: SafeArea(
        bottom: false,
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.loadNutrition,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                48,
              ),
              children: [
                _NutritionHeader(
                  favoritesOnly:
                  controller.favoritesOnly.value,
                  onFavoriteTap:
                  controller.toggleFavoritesOnly,
                ),

                const SizedBox(height: 24),

                _DailyRecommendationCard(
                  recipe:
                  controller.todayRecommendation.value,
                  changing:
                  controller
                      .isChangingRecommendation
                      .value,
                  onOpen: () {
                    final recipe =
                        controller
                            .todayRecommendation
                            .value;

                    if (recipe != null) {
                      controller.openRecipe(recipe);
                    }
                  },
                  onChange:
                  controller.changeRecommendation,
                ),

                const SizedBox(height: 24),

                _SearchField(
                  controller:
                  controller.searchController,
                  query:
                  controller.searchQuery.value,
                  onChanged:
                  controller.updateSearch,
                  onClear:
                  controller.clearSearch,
                ),

                const SizedBox(height: 20),

                _FilterButtons(
                  ingredientOptions: controller.ingredientOptions,
                  categoryOptions: controller.categoryOptions,
                  selectedIngredient: controller.selectedIngredient.value,
                  selectedCategory: controller.selectedCategory.value,
                  onIngredientSelected: controller.selectIngredient,
                  onCategorySelected: controller.selectCategory,
                ),

                const SizedBox(height: 28),

                _RecipeSectionHeader(
                  favoritesOnly:
                  controller.favoritesOnly.value,
                  count:
                  controller.filteredRecipes.length,
                ),

                const SizedBox(height: 12),

                if (controller.filteredRecipes.isEmpty)
                  _EmptyResult(
                    onReset:
                    controller.clearFilters,
                  )
                else
                  ...controller.filteredRecipes.map(
                        (recipe) => Padding(
                      padding:
                      const EdgeInsets.only(
                        bottom: 12,
                      ),
                      child: RecipeCard(
                        recipe: recipe,
                        onTap: () =>
                            controller.openRecipe(
                              recipe,
                            ),
                        onFavoriteChanged:
                            (value) =>
                            controller
                                .toggleFavorite(
                              recipe,
                              value,
                            ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _NutritionHeader extends StatelessWidget {
  const _NutritionHeader({
    required this.favoritesOnly,
    required this.onFavoriteTap,
  });

  final bool favoritesOnly;
  final VoidCallback onFavoriteTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Nutrisi',
                style: theme
                    .textTheme.headlineMedium
                    ?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Temukan inspirasi makanan untuk mendukung workout kamu.',
                style:
                theme.textTheme.bodySmall?.copyWith(
                  color:
                  AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        Material(
          color: AppColors.surface,
          borderRadius:
          BorderRadius.circular(14),
          child: InkWell(
            onTap: onFavoriteTap,
            borderRadius:
            BorderRadius.circular(14),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(14),
                border: Border.all(
                  color: favoritesOnly
                      ? AppColors.accent
                      .withValues(
                    alpha: 0.45,
                  )
                      : AppColors.divider,
                ),
              ),
              child: Icon(
                favoritesOnly
                    ? Icons.favorite_rounded
                    : Icons
                    .favorite_border_rounded,
                color: favoritesOnly
                    ? AppColors.accent
                    : AppColors.textSecondary,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyRecommendationCard
    extends StatelessWidget {
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
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius:
          BorderRadius.circular(24),
          border: Border.all(
            color: AppColors.divider,
          ),
        ),
        child: const Text(
          'Rekomendasi resep belum tersedia.',
        ),
      );
    }

    final item = recipe!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.accent
              .withValues(alpha: 0.22),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              InkWell(
                onTap: onOpen,
                child: RecipeImage(
                  recipe: item,
                  width: double.infinity,
                  height: 205,
                ),
              ),

              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background
                        .withValues(
                      alpha: 0.82,
                    ),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize:
                    MainAxisSize.min,
                    children: [
                      Icon(
                        Icons
                            .auto_awesome_rounded,
                        color:
                        AppColors.accent,
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Pilihan Hari Ini',
                        style: TextStyle(
                          color: AppColors
                              .textPrimary,
                          fontSize: 11,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                top: 14,
                right: 14,
                child: Material(
                  color: AppColors.background
                      .withValues(alpha: 0.82),
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap:
                    changing ? null : onChange,
                    customBorder:
                    const CircleBorder(),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: changing
                          ? const Padding(
                        padding:
                        EdgeInsets.all(
                          11,
                        ),
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(
                        Icons
                            .refresh_rounded,
                        color: AppColors
                            .textPrimary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding:
            const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style: theme
                      .textTheme.titleLarge
                      ?.copyWith(
                    fontWeight:
                    FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  item.description,
                  maxLines: 2,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  theme.textTheme.bodyMedium,
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _MetricBox(
                        icon:
                        Icons.bolt_rounded,
                        value:
                        '${item.estimatedProtein.toStringAsFixed(0)} g',
                        label: 'Protein',
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _MetricBox(
                        icon: Icons.local_fire_department_rounded,
                        value: item.estimatedCalories.toStringAsFixed(0),
                        label: 'Kalori',
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: _MetricBox(
                        icon: Icons
                            .schedule_rounded,
                        value:
                        '${item.cookingTimeMinutes}',
                        label: 'Menit',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onOpen,
                    child: const Text(
                      'Lihat Resep',
                    ),
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

class _MetricBox extends StatelessWidget {
  const _MetricBox({
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
      padding:
      const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 17,
            color: AppColors.accent,
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color:
              AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction:
      TextInputAction.search,
      decoration: InputDecoration(
        hintText:
        'Cari resep atau bahan...',
        prefixIcon: const Icon(
          Icons.search_rounded,
        ),
        suffixIcon: query.isEmpty
            ? null
            : IconButton(
          tooltip:
          'Hapus pencarian',
          onPressed: onClear,
          icon: const Icon(
            Icons.close_rounded,
          ),
        ),
      ),
    );
  }
}

class _FilterButtons extends StatelessWidget {
  const _FilterButtons({
    required this.ingredientOptions,
    required this.categoryOptions,
    required this.selectedIngredient,
    required this.selectedCategory,
    required this.onIngredientSelected,
    required this.onCategorySelected,
  });

  final List<String> ingredientOptions;
  final List<String> categoryOptions;

  final String selectedIngredient;
  final String selectedCategory;

  final ValueChanged<String> onIngredientSelected;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _FilterButton(
            icon: Icons.restaurant_rounded,
            label: 'Bahan',
            value: selectedIngredient,
            onTap: () {
              _showFilterSheet(
                context,
                title: 'Pilih Bahan Utama',
                options: ingredientOptions,
                selected: selectedIngredient,
                onSelected: onIngredientSelected,
              );
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _FilterButton(
            icon: Icons.category_rounded,
            label: 'Kategori',
            value: selectedCategory,
            onTap: () {
              _showFilterSheet(
                context,
                title: 'Pilih Kategori',
                options: categoryOptions,
                selected: selectedCategory,
                onSelected: onCategorySelected,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final active = value != 'Semua';

    return Material(
      color: active
          ? AppColors.accent.withValues(alpha: 0.10)
          : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(
            horizontal: 13,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active
                  ? AppColors.accent.withValues(alpha: 0.35)
                  : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19,
                color: active
                    ? AppColors.accent
                    : AppColors.textSecondary,
              ),

              const SizedBox(width: 9),

              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: active
                            ? AppColors.accent
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeSectionHeader
    extends StatelessWidget {
  const _RecipeSectionHeader({
    required this.favoritesOnly,
    required this.count,
  });

  final bool favoritesOnly;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: Text(
            favoritesOnly
                ? 'Resep Favorit'
                : 'Semua Resep',
            style:
            theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius:
            BorderRadius.circular(20),
          ),
          child: Text(
            '$count resep',
            style:
            theme.textTheme.bodySmall?.copyWith(
              color:
              AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyResult extends StatelessWidget {
  const _EmptyResult({
    required this.onReset,
  });

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius:
        BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            color: AppColors.textSecondary,
            size: 38,
          ),
          const SizedBox(height: 12),
          Text(
            'Resep tidak ditemukan',
            style:
            theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Coba pencarian atau filter yang berbeda.',
            textAlign: TextAlign.center,
            style:
            theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onReset,
            child: const Text(
              'Reset Filter',
            ),
          ),
        ],
      ),
    );
  }
}
Future<void> _showFilterSheet(
    BuildContext context, {
      required String title,
      required List<String> options,
      required String selected,
      required ValueChanged<String> onSelected,
    }) async {
  final result = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surface,
    showDragHandle: true,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
            MediaQuery.of(context).size.height * 0.65,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  4,
                  20,
                  14,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const Divider(height: 1),

              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final active = option == selected;

                    return ListTile(
                      onTap: () {
                        Navigator.pop(
                          context,
                          option,
                        );
                      },
                      title: Text(option),
                      trailing: active
                          ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accent,
                      )
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );

  if (result != null) {
    onSelected(result);
  }
}