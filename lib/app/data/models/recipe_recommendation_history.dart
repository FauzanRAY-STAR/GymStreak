import '../../utils/app_date_utils.dart';

/// Riwayat resep yang pernah direkomendasikan pada tanggal tertentu.
/// Dipakai agar resep yang sama tidak berulang dalam 7 hari terakhir.
class RecipeRecommendationHistory {
  const RecipeRecommendationHistory({
    this.id,
    required this.recipeId,
    required this.recommendationDate,
    required this.changedManually,
  });

  final int? id;
  final String recipeId;
  final DateTime recommendationDate;

  /// True jika resep ini hasil tekan tombol "Ganti Menu", bukan rekomendasi
  /// otomatis harian.
  final bool changedManually;

  factory RecipeRecommendationHistory.fromMap(Map<String, dynamic> map) {
    return RecipeRecommendationHistory(
      id: map['id'] as int,
      recipeId: map['recipe_id'] as String,
      recommendationDate: AppDateUtils.parseDateKey(
        map['recommendation_date'] as String,
      ),
      changedManually: (map['changed_manually'] as int) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'recipe_id': recipeId,
      'recommendation_date': AppDateUtils.formatDateKey(recommendationDate),
      'changed_manually': changedManually ? 1 : 0,
    };
  }
}
