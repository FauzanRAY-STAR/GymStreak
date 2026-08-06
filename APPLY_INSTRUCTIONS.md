# GymStreak — Core Notification Fixes

Bundle ini dibuat untuk branch:

`feature/core-notification-fixes`

## Cara memasang

1. Pastikan Android Studio sedang berada pada branch tersebut:

```bash
git branch --show-current
```

Hasilnya harus:

```text
feature/core-notification-fixes
```

2. Ekstrak isi ZIP ke folder utama project `GymStreak`.

Pilih **Replace/Overwrite** ketika Windows menanyakan file yang sama.

3. Jalankan:

```bash
flutter clean
flutter pub get
dart format lib
flutter analyze
flutter test
```

4. Jalankan aplikasi di HP:

```bash
flutter run
```

5. Saat onboarding atau ketika mengaktifkan `Pengingat Workout`, izinkan notifikasi.

## Yang ditambahkan

- Local notification mingguan berdasarkan jadwal workout.
- Izin notifikasi Android 13+.
- Pemulihan jadwal notifikasi setelah HP restart.
- Pengingat kedua satu jam setelah pengingat utama.
- Pengingat kedua dibatalkan setelah workout hari ini dicatat.
- Sinkronisasi hari workout pada Settings dengan daftar jadwal.
- Pencegahan dua jadwal pada hari yang sama.
- Pembatasan backfill streak sejak workout pertama.
- Pembatalan notifikasi ketika semua data di-reset.

## Commit setelah lolos pengujian

```bash
git add .
git commit -m "feat: implement workout reminders and schedule sync"
git push
```

Jangan merge ke `main` sebelum `flutter analyze` dan `flutter test` berhasil.
