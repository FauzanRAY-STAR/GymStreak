# GymStreak — Nutrition Recommendations

Gunakan patch ini pada branch:

`feature/nutrition-recommendations`

## Memasang patch

1. Pastikan branch aktif:

```powershell
git branch --show-current
```

2. Ekstrak ZIP ke folder utama project GymStreak.
3. Pilih Replace/Overwrite untuk file yang sudah ada.
4. Jalankan:

```powershell
dart format lib test
flutter analyze
flutter test
flutter run
```

## Fitur yang ditambahkan

- Rekomendasi resep harian yang tetap sama pada hari yang sama.
- Menghindari pengulangan resep selama tujuh hari.
- Tombol Ganti Menu.
- Daftar 30 resep lokal.
- Pencarian resep.
- Filter bahan utama dan kategori.
- Resep favorit.
- Detail bahan, langkah, protein, kalori, dan durasi.
- Rekomendasi resep nyata pada halaman Home.
- Fallback placeholder untuk gambar resep yang belum tersedia.

## Commit

Setelah pengujian berhasil:

```powershell
git add .
git commit -m "feat: add nutrition recommendations and recipe catalog"
git push
```
