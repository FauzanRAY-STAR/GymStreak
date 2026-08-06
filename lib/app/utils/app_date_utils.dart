import 'package:flutter/material.dart' show TimeOfDay;

/// Helper tanggal bersama. Minggu dihitung mulai Senin sampai Minggu.
class AppDateUtils {
  AppDateUtils._();

  /// Format 'HH:mm' untuk disimpan di SQLite.
  static String formatTimeOfDay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static TimeOfDay parseTimeOfDay(String value) {
    final parts = value.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  /// Format tanggal (tanpa jam) untuk disimpan sebagai key di SQLite,
  /// contoh: 2026-08-06.
  static String formatDateKey(DateTime date) {
    final normalized = dateOnly(date);
    final y = normalized.year.toString().padLeft(4, '0');
    final m = normalized.month.toString().padLeft(2, '0');
    final d = normalized.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static DateTime parseDateKey(String key) {
    final parts = key.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  /// Membuang komponen jam/menit/detik agar perbandingan tanggal akurat.
  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Senin pada minggu yang sama dengan [date].
  static DateTime startOfWeek(DateTime date) {
    final normalized = dateOnly(date);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  /// Minggu (hari terakhir) pada minggu yang sama dengan [date].
  static DateTime endOfWeek(DateTime date) {
    return startOfWeek(date).add(const Duration(days: 6));
  }

  static bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// True jika [date] berada di antara [start] dan [end] (inklusif),
  /// dibandingkan tanpa komponen jam.
  static bool isWithinInclusive(DateTime date, DateTime start, DateTime end) {
    final d = dateOnly(date);
    final s = dateOnly(start);
    final e = dateOnly(end);
    return !d.isBefore(s) && !d.isAfter(e);
  }
}
