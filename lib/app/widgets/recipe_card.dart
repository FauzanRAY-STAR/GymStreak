import 'package:flutter/material.dart';

import '../data/models/recipe.dart';
import '../theme/app_colors.dart';
import 'recipe_image.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onFavoriteChanged,
  });

  final Recipe recipe;
  final VoidCallback onTap;
  final ValueChanged<bool>? onFavoriteChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RecipeImage(recipe: recipe, width: 112, height: 142),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            recipe.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        if (onFavoriteChanged != null)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            tooltip: recipe.isFavorite
                                ? 'Hapus dari favorit'
                                : 'Tambahkan ke favorit',
                            onPressed: () =>
                                onFavoriteChanged!(!recipe.isFavorite),
                            icon: Icon(
                              recipe.isFavorite
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: recipe.isFavorite
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.mainIngredient,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.accent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        _Info(
                          icon: Icons.bolt_rounded,
                          label:
                              '${recipe.estimatedProtein.toStringAsFixed(0)} g protein',
                        ),
                        _Info(
                          icon: Icons.local_fire_department_rounded,
                          label:
                              '${recipe.estimatedCalories.toStringAsFixed(0)} kkal',
                        ),
                        _Info(
                          icon: Icons.schedule_rounded,
                          label: '${recipe.cookingTimeMinutes} menit',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
