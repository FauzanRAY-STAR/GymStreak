import 'package:get/get.dart';

import '../../app/data/models/recipe.dart';
import '../../app/data/repositories/recipe_repository.dart';

class RecipeDetailController extends GetxController {
  RecipeDetailController({RecipeRepository? repository})
    : _repository = repository ?? RecipeRepository();

  final RecipeRepository _repository;

  final Rxn<Recipe> recipe = Rxn<Recipe>();
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    final arguments = Get.arguments;
    final recipeId = switch (arguments) {
      Recipe item => item.id,
      String id => id,
      _ => null,
    };

    if (recipeId == null) {
      errorMessage.value = 'Resep tidak ditemukan.';
      isLoading.value = false;
      return;
    }

    final result = await _repository.getById(recipeId);
    if (result == null) {
      errorMessage.value = 'Data resep tidak ditemukan.';
    } else {
      recipe.value = result;
    }

    isLoading.value = false;
  }

  Future<void> toggleFavorite() async {
    final current = recipe.value;
    if (current == null) return;

    final updated = current.copyWith(isFavorite: !current.isFavorite);
    await _repository.setFavorite(updated.id, updated.isFavorite);
    recipe.value = updated;
  }
}
