<div align="center">

# 🏋️ GymStreak

### Build consistency. Track progress. Keep the streak alive.

Aplikasi workout berbasis Flutter untuk membantu pengguna membangun kebiasaan latihan melalui sistem **weekly streak**, jadwal workout, riwayat latihan, pengingat, dan rekomendasi makanan tinggi protein.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-07405E?style=for-the-badge&logo=sqlite&logoColor=white)
![GetX](https://img.shields.io/badge/GetX-8A2BE2?style=for-the-badge)

</div>

---

## 📱 Tentang GymStreak

**GymStreak** adalah aplikasi mobile yang dirancang untuk membantu pengguna lebih konsisten dalam menjalankan rutinitas workout.

Berbeda dengan streak harian biasa, GymStreak menggunakan sistem **target workout mingguan**. Pengguna dapat menentukan berapa kali ingin latihan dalam satu minggu tanpa harus kehilangan streak karena rest day.

Contoh:

```text
Target mingguan : 4x workout

Senin   ✅
Selasa  Rest Day
Rabu    ✅
Kamis   Rest Day
Jumat   ✅
Sabtu   ✅

Target tercapai → Weekly Streak +1 🔥
```

---

## ✨ Fitur Utama

### 🔥 Weekly Streak

- Menentukan target workout mingguan.
- Streak bertambah ketika target minggu tersebut tercapai.
- Rest day tidak mematikan streak.
- Menampilkan current streak dan streak terbaik.
- Progress workout mingguan ditampilkan secara visual.

### 🏋️ Workout Tracking

- Mencatat jenis workout.
- Mencatat durasi latihan.
- Memilih intensitas:
  - Ringan
  - Sedang
  - Berat
- Menambahkan catatan workout.
- Maksimal **1 workout per tanggal**.
- Edit dan hapus riwayat workout.

### 📅 Workout Schedule

- Membuat jadwal workout mingguan.
- Menentukan jenis workout per hari.
- Menentukan jam pengingat.
- Aktif/nonaktifkan jadwal.
- Edit atau hapus jadwal.

### 🔔 Workout Reminder

GymStreak menyediakan beberapa mode pengingat:

```text
🔕 Mati
🔔 Pengingat 1x
🔔 Pengingat 2x
```

Notifikasi menggunakan local notification sehingga tidak membutuhkan server.

### 🥗 Rekomendasi Nutrisi

- Rekomendasi resep makanan.
- Informasi estimasi protein.
- Informasi estimasi kalori.
- Waktu memasak.
- Daftar bahan dan langkah memasak.
- Filter berdasarkan kategori makanan.
- Dukungan favorite recipe.

### 📆 Calendar Progress

Calendar membantu pengguna melihat aktivitas workout berdasarkan tanggal dan memantau konsistensi latihan.

### 👤 Profile & Preferences

Pengguna dapat mengatur:

- Nama.
- Target workout mingguan.
- Hari workout.
- Jam pengingat.
- Fitness goal.
- Jadwal workout.
- Riwayat workout.
- Pengaturan notifikasi.

---

## 🎯 Fitness Goal

GymStreak mendukung beberapa tujuan fitness:

```text
Membangun Kebiasaan
Bulking
Cutting
Menjaga Kebugaran
```

Tujuan pengguna digunakan sebagai bagian dari personalisasi pengalaman aplikasi.

---

## 🛠️ Tech Stack

| Technology | Penggunaan |
|---|---|
| Flutter | Framework utama aplikasi |
| Dart | Bahasa pemrograman |
| GetX | State management & navigation |
| SQLite / Sqflite | Database lokal |
| Shared Preferences | Penyimpanan konfigurasi sederhana |
| Flutter Local Notifications | Pengingat workout |
| Table Calendar | Tampilan kalender |
| Intl | Formatting tanggal dan waktu |

---

## 🗄️ Local-First Architecture

GymStreak dirancang sebagai aplikasi **local-first**.

Data utama disimpan langsung di perangkat menggunakan SQLite sehingga fitur utama tetap dapat digunakan tanpa koneksi internet.

Data yang disimpan meliputi:

```text
User Settings
Workout Schedule
Workout Session
Weekly Progress
Favorite Recipe
```

---

## 📂 Struktur Project

```text
lib/
├── app/
│   ├── bindings/
│   ├── controllers/
│   ├── data/
│   │   ├── database/
│   │   ├── models/
│   │   ├── repositories/
│   │   └── services/
│   ├── routes/
│   ├── theme/
│   ├── utils/
│   └── widgets/
│
├── features/
│   ├── calendar/
│   ├── home/
│   ├── nutrition/
│   ├── onboarding/
│   ├── profile/
│   └── workout/
│
└── main.dart
```

---

## 🚀 Menjalankan Project

Pastikan Flutter sudah terinstall.

### 1. Clone repository

```bash
git clone https://github.com/FauzanRAY-STAR/GymStreak.git
```

### 2. Masuk ke folder project

```bash
cd GymStreak
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Cek device

```bash
flutter devices
```

### 5. Jalankan aplikasi

```bash
flutter run
```

---

## 🧪 Testing

Untuk menjalankan seluruh test:

```bash
flutter test
```

Untuk mengecek masalah pada source code:

```bash
flutter analyze
```

---

## 📦 Build APK

Untuk membuat APK release:

```bash
flutter build apk --release
```

Hasil build biasanya berada di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🗺️ Roadmap

- [x] Onboarding
- [x] Weekly workout streak
- [x] Workout tracking
- [x] One workout per day
- [x] Workout schedule
- [x] Workout reminder
- [x] Workout history
- [x] Nutrition recommendation
- [x] Recipe detail
- [x] Calendar progress
- [x] Profile & preferences
- [ ] Light / Dark / System theme
- [ ] Final UI polish
- [ ] Release APK

---

## 📌 Status

GymStreak saat ini masih dalam tahap **development dan UI refinement**.

Beberapa fitur dan desain masih dapat berubah selama proses pengembangan.

---

<div align="center">

### GymStreak

**Consistency beats motivation. 🔥**

Made with Flutter.

</div>
