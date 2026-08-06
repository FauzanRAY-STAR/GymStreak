import 'package:flutter/material.dart';

import '../../app/widgets/feature_placeholder.dart';

// TODO(tahap-6): Ganti dengan halaman Nutrisi lengkap (rekomendasi harian,
// pencarian, filter, daftar resep, favorit).
class NutritionView extends StatelessWidget {
  const NutritionView({super.key});

  @override
  Widget build(BuildContext context) {
    return const FeaturePlaceholder(
      icon: Icons.restaurant_rounded,
      title: 'Nutrisi',
      message: 'Halaman Nutrisi akan dibangun pada Tahap 6.',
    );
  }
}
