import 'package:flutter/material.dart';

import '../data/models/recipe.dart';
import '../theme/app_colors.dart';

class RecipeImage extends StatelessWidget {
  const RecipeImage({
    super.key,
    required this.recipe,
    this.width,
    this.height,
    this.borderRadius = BorderRadius.zero,
    this.fit = BoxFit.cover,
  });

  final Recipe recipe;
  final double? width;
  final double? height;
  final BorderRadius borderRadius;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.asset(
        recipe.imageAsset,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, _, _) {
          return Image.asset(
            'assets/images/recipes/placeholder.png',
            width: width,
            height: height,
            fit: fit,
            errorBuilder: (_, _, _) => Container(
              width: width,
              height: height,
              color: AppColors.surfaceElevated,
              alignment: Alignment.center,
              child: const Icon(
                Icons.restaurant_rounded,
                color: AppColors.accent,
                size: 42,
              ),
            ),
          );
        },
      ),
    );
  }
}
