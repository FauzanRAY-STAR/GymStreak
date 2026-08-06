import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/data/models/recipe.dart';
import '../../app/data/repositories/recipe_repository.dart';
import '../../app/data/services/recipe_recommendation_service.dart';
import '../../app/routes/app_routes.dart';
import '../home/home_controller.dart';

class NutritionController extends GetxController {
  NutritionController({
    RecipeRepository? recipeRepository,
    RecipeRecommendationService? recommendationService,
  }) : _recipeRepository = recipeRepository ?? RecipeRepository(),
       _recommendationService =
           recommendationService ?? RecipeRecommendationService();

  final RecipeRepository _recipeRepository;
  final RecipeRecommendationService _recommendationService;

  final TextEditingController searchController = TextEditingController();

  final RxList<Recipe> allRecipes = <Recipe>[].obs;
  final RxList<Recipe> filteredRecipes = <Recipe>[].obs;
  final Rxn<Recipe> todayRecommendation = Rxn<Recipe>();

  final RxString searchQuery = ''.obs;
  final RxString selectedIngredient = 'Semua'.obs;
  final RxString selectedCategory = 'Semua'.obs;
  final RxBool favoritesOnly = false.obs;
  final RxBool isLoading = true.obs;
  final RxBool isChangingRecommendation = false.obs;

  List<String> get ingredientOptions {
    final values = allRecipes.map((recipe) => recipe.mainIngredient).toSet()
      ..removeWhere((value) => value.trim().isEmpty);
    final sorted = values.toList()..sort();
    return ['Semua', ...sorted];
  }

  List<String> get categoryOptions {
    final values = allRecipes.expand((recipe) => recipe.categories).toSet()
      ..removeWhere((value) => value.trim().isEmpty);
    final sorted = values.toList()..sort();
    return ['Semua', ...sorted];
  }

  @override
  void onInit() {
    super.onInit();
    loadNutrition();
  }

  Future<void> loadNutrition() async {
    isLoading.value = true;
    allRecipes.value = await _recipeRepository.getAll();
    todayRecommendation.value = await _recommendationService
        .getTodayRecommendation();
    _applyFilters();
    isLoading.value = false;
  }

  Future<void> refreshRecipes() async {
    allRecipes.value = await _recipeRepository.getAll();

    final current = todayRecommendation.value;
    if (current != null) {
      todayRecommendation.value =
          await _recipeRepository.getById(current.id) ?? current;
    }

    _applyFilters();
  }

  void updateSearch(String value) {
    searchQuery.value = value;
    _applyFilters();
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilters();
  }

  void selectIngredient(String value) {
    selectedIngredient.value = value;
    _applyFilters();
  }

  void selectCategory(String value) {
    selectedCategory.value = value;
    _applyFilters();
  }

  void toggleFavoritesOnly() {
    favoritesOnly.value = !favoritesOnly.value;
    _applyFilters();
  }

  void clearFilters() {
    searchController.clear();
    searchQuery.value = '';
    selectedIngredient.value = 'Semua';
    selectedCategory.value = 'Semua';
    favoritesOnly.value = false;
    _applyFilters();
  }

  void _applyFilters() {
    final query = searchQuery.value.trim().toLowerCase();

    final result = allRecipes.where((recipe) {
      final matchesSearch =
          query.isEmpty ||
          recipe.name.toLowerCase().contains(query) ||
          recipe.mainIngredient.toLowerCase().contains(query) ||
          recipe.categories.any(
            (category) => category.toLowerCase().contains(query),
          );

      final matchesIngredient =
          selectedIngredient.value == 'Semua' ||
          recipe.mainIngredient == selectedIngredient.value;

      final matchesCategory =
          selectedCategory.value == 'Semua' ||
          recipe.categories.contains(selectedCategory.value);

      final matchesFavorite = !favoritesOnly.value || recipe.isFavorite;

      return matchesSearch &&
          matchesIngredient &&
          matchesCategory &&
          matchesFavorite;
    }).toList();

    filteredRecipes.value = result;
  }

  Future<void> changeRecommendation() async {
    if (isChangingRecommendation.value) return;

    isChangingRecommendation.value = true;
    final recipe = await _recommendationService.changeTodayRecommendation();
    if (recipe != null) {
      todayRecommendation.value = recipe;

      // Home memakai rekomendasi yang sama tanpa perlu restart aplikasi.
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().setRecipeRecommendation(recipe);
      }
    }
    isChangingRecommendation.value = false;
  }

  Future<void> toggleFavorite(Recipe recipe, bool value) async {
    await _recipeRepository.setFavorite(recipe.id, value);
    final updated = recipe.copyWith(isFavorite: value);

    allRecipes.value = allRecipes
        .map((item) => item.id == recipe.id ? updated : item)
        .toList();

    if (todayRecommendation.value?.id == recipe.id) {
      todayRecommendation.value = updated;
    }

    _applyFilters();
  }

  Future<void> openRecipe(Recipe recipe) async {
    await Get.toNamed(AppRoutes.recipeDetail, arguments: recipe.id);
    await refreshRecipes();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
