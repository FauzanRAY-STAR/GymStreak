import 'package:get/get.dart';

import '../../utils/app_date_utils.dart';
import '../../utils/clock_service.dart';
import '../models/recipe.dart';
import '../models/recipe_recommendation_history.dart';
import '../repositories/recipe_recommendation_repository.dart';
import '../repositories/recipe_repository.dart';

/// Memilih rekomendasi resep harian dari katalog lokal.
///
/// Rekomendasi pada hari yang sama selalu tetap. Resep yang sudah muncul
/// dalam tujuh hari terakhir dihindari selama masih ada pilihan lain.
class RecipeRecommendationService {
  RecipeRecommendationService({
    RecipeRepository? recipeRepository,
    RecipeRecommendationRepository? historyRepository,
    ClockService? clock,
  }) : _recipeRepository = recipeRepository ?? RecipeRepository(),
       _historyRepository =
           historyRepository ?? RecipeRecommendationRepository(),
       _clock =
           clock ??
           (Get.isRegistered<ClockService>()
               ? Get.find<ClockService>()
               : ClockService());

  final RecipeRepository _recipeRepository;
  final RecipeRecommendationRepository _historyRepository;
  final ClockService _clock;

  Future<Recipe?> getTodayRecommendation() {
    return getRecommendationFor(_clock.now());
  }

  Future<Recipe?> getRecommendationFor(DateTime date) async {
    final day = AppDateUtils.dateOnly(date);
    final existing = await _historyRepository.getLatestForDate(day);

    if (existing != null) {
      final savedRecipe = await _recipeRepository.getById(existing.recipeId);
      if (savedRecipe != null) return savedRecipe;
    }

    return _createRecommendation(
      date: day,
      changedManually: false,
      currentRecipeId: null,
    );
  }

  Future<Recipe?> changeTodayRecommendation() {
    return changeRecommendationFor(_clock.now());
  }

  Future<Recipe?> changeRecommendationFor(DateTime date) async {
    final day = AppDateUtils.dateOnly(date);
    final current = await _historyRepository.getLatestForDate(day);

    return _createRecommendation(
      date: day,
      changedManually: true,
      currentRecipeId: current?.recipeId,
    );
  }

  Future<Recipe?> _createRecommendation({
    required DateTime date,
    required bool changedManually,
    required String? currentRecipeId,
  }) async {
    final allRecipes = await _recipeRepository.getAll();
    if (allRecipes.isEmpty) return null;

    final recentRecipeIds = (await _historyRepository.getRecentRecipeIds(
      date.subtract(const Duration(days: 6)),
    )).toSet();

    var candidates = allRecipes
        .where(
          (recipe) =>
              !recentRecipeIds.contains(recipe.id) &&
              recipe.id != currentRecipeId,
        )
        .toList();

    // Apabila seluruh katalog pernah muncul dalam tujuh hari terakhir,
    // tetap hindari resep yang sedang tampil.
    if (candidates.isEmpty) {
      candidates = allRecipes
          .where((recipe) => recipe.id != currentRecipeId)
          .toList();
    }

    if (candidates.isEmpty) {
      candidates = List<Recipe>.from(allRecipes);
    }

    final recommendationCount = await _historyRepository.countForDate(date);
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final index = (seed + recommendationCount * 31) % candidates.length;
    final selected = candidates[index];

    await _historyRepository.insert(
      RecipeRecommendationHistory(
        recipeId: selected.id,
        recommendationDate: date,
        changedManually: changedManually,
      ),
    );

    return selected;
  }
}
