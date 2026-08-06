/// Konstanta nilai pilihan yang dipakai lintas fitur (dropdown, chip filter, dll).
class AppConstants {
  AppConstants._();

  /// Jenis workout awal. "Custom Workout" mengizinkan pengguna mengisi nama
  /// jenis workout sendiri melalui input teks terpisah.
  static const List<String> defaultWorkoutTypes = [
    'Push Day',
    'Pull Day',
    'Leg Day',
    'Full Body',
    'Cardio',
    'Custom Workout',
  ];

  static const List<String> fitnessGoals = [
    'Membangun Kebiasaan',
    'Bulking',
    'Cutting',
    'Menjaga Kebugaran',
  ];

  static const List<String> recipeCategories = [
    'Tinggi Protein',
    'Hemat',
    'Cepat Dibuat',
    'Bulking',
    'Cutting',
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
  ];

  static const List<String> recipeDifficulties = ['Mudah', 'Sedang', 'Sulit'];

  static const List<String> recipeMainIngredients = [
    'Dada Ayam',
    'Telur',
    'Tempe',
    'Tahu',
  ];

  /// Label hari dalam seminggu, index 0 = Senin sesuai konvensi dayOfWeek 1-7.
  static const List<String> dayLabels = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static String dayLabel(int dayOfWeek) => dayLabels[dayOfWeek - 1];
}
