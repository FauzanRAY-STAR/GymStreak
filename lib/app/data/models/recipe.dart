import 'dart:convert';

/// Resep tinggi protein. Nilai protein dan kalori bersifat estimasi.
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.mainIngredient,
    required this.ingredients,
    required this.steps,
    required this.servings,
    required this.estimatedProtein,
    required this.estimatedCalories,
    required this.cookingTimeMinutes,
    required this.difficulty,
    required this.categories,
    required this.imageAsset,
    this.isFavorite = false,
  });

  final String id;
  final String name;
  final String description;
  final String mainIngredient;
  final List<String> ingredients;
  final List<String> steps;
  final int servings;

  /// Estimasi protein per porsi (gram).
  final double estimatedProtein;

  /// Estimasi kalori per porsi (kkal).
  final double estimatedCalories;
  final int cookingTimeMinutes;
  final String difficulty;
  final List<String> categories;
  final String imageAsset;
  final bool isFavorite;

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      mainIngredient: map['main_ingredient'] as String,
      ingredients: List<String>.from(jsonDecode(map['ingredients'] as String)),
      steps: List<String>.from(jsonDecode(map['steps'] as String)),
      servings: map['servings'] as int,
      estimatedProtein: (map['estimated_protein'] as num).toDouble(),
      estimatedCalories: (map['estimated_calories'] as num).toDouble(),
      cookingTimeMinutes: map['cooking_time_minutes'] as int,
      difficulty: map['difficulty'] as String,
      categories: List<String>.from(jsonDecode(map['categories'] as String)),
      imageAsset: map['image_asset'] as String,
      isFavorite: (map['is_favorite'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'main_ingredient': mainIngredient,
      'ingredients': jsonEncode(ingredients),
      'steps': jsonEncode(steps),
      'servings': servings,
      'estimated_protein': estimatedProtein,
      'estimated_calories': estimatedCalories,
      'cooking_time_minutes': cookingTimeMinutes,
      'difficulty': difficulty,
      'categories': jsonEncode(categories),
      'image_asset': imageAsset,
      'is_favorite': isFavorite ? 1 : 0,
    };
  }

  factory Recipe.fromSeedJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      mainIngredient: json['mainIngredient'] as String,
      ingredients: List<String>.from(json['ingredients'] as List),
      steps: List<String>.from(json['steps'] as List),
      servings: json['servings'] as int,
      estimatedProtein: (json['estimatedProtein'] as num).toDouble(),
      estimatedCalories: (json['estimatedCalories'] as num).toDouble(),
      cookingTimeMinutes: json['cookingTimeMinutes'] as int,
      difficulty: json['difficulty'] as String,
      categories: List<String>.from(json['categories'] as List),
      imageAsset: json['imageAsset'] as String,
    );
  }

  Recipe copyWith({bool? isFavorite}) {
    return Recipe(
      id: id,
      name: name,
      description: description,
      mainIngredient: mainIngredient,
      ingredients: ingredients,
      steps: steps,
      servings: servings,
      estimatedProtein: estimatedProtein,
      estimatedCalories: estimatedCalories,
      cookingTimeMinutes: cookingTimeMinutes,
      difficulty: difficulty,
      categories: categories,
      imageAsset: imageAsset,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
