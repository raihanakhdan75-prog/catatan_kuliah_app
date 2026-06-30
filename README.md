📚 Catatan Kuliah

Aplikasi pencatatan materi perkuliahan berbasis **Flutter** dengan backend **PHP & MySQL** yang membantu mahasiswa mengelola catatan kuliah secara terstruktur dan mudah diakses.

---

🎯 Fitur Utama

- 🔐 **Autentikasi** - Register & Login dengan database MySQL
- 📝 **CRUD Catatan** - Tambah, Edit, Hapus, dan Lihat catatan kuliah
- 📁 **Folder Mata Kuliah** - Pengelompokan catatan berdasarkan 8 mata kuliah
- 🔍 **Pencarian & Filter** - Cari catatan, filter kategori, urutkan terbaru/terlama
- 🌙 **Dark/Light Mode** - Tema gelap dan terang
- 📤 **Share Catatan** - Bagikan catatan ke WhatsApp, Email, dll
- 📊 **Statistik** - Total catatan, mata kuliah, dan kategori
- 📅 **Date Picker** - Pemilihan tanggal otomatis

---

📱 Daftar Mata Kuliah

| No | Mata Kuliah |
|----|-------------|
| 1 | Kecerdasan Bisnis |
| 2 | Bahasa Inggris 2 |
| 3 | Komputer dan Masyarakat |
| 4 | Rekayasa Perangkat Lunak |
| 5 | Mobile Programming |
| 6 | Analisa Proses Bisnis |
| 7 | Matrik dan Transformasi Linier |
| 8 | Keamanan Komputer |

---

🛠️ Teknologi

| Komponen | Teknologi |
|----------|-----------|
| **Frontend** | Flutter (Dart) |
| **Backend** | PHP (1 file api.php) |
| **Database** | MySQL (XAMPP) |
| **State Management** | Provider |
| **HTTP Client** | http package |
| **Share** | share_plus package |

---

---

## 📁 Struktur Folder

catatan_kuliah/
├── lib/
│ ├── main.dart
│ ├── database/
│ │ └── db_helper.dart
│ ├── models/
│ │ └── note.dart
│ └── screens/
│ ├── login_screen.dart
│ ├── register_screen.dart
│ ├── main_screen.dart
│ └── main_screen2.dart
├── assets/
│ └── images/
│ └── logocatatankuliah.png
├── android/
├── ios/
├── screenshots/
├── pubspec.yaml
└── README.md


---

## 🗄️ Database

### Tabel users

| Field | Type | Keterangan |
|-------|------|------------|
| id | INT | Primary Key |
| username | VARCHAR(50) | Nama pengguna |
| password | VARCHAR(255) | Password |
| created_at | TIMESTAMP | Waktu registrasi |

### Tabel notes

| Field | Type | Keterangan |
|-------|------|------------|
| id | INT | Primary Key |
| user_id | INT | Foreign Key ke users |
| mata_kuliah | VARCHAR(100) | Nama mata kuliah |
| judul | VARCHAR(255) | Judul catatan |
| materi | TEXT | Isi catatan |
| tanggal | VARCHAR(20) | Tanggal catatan |
| kategori | VARCHAR(50) | Teori/Praktikum/Tugas/UTS/UAS |

---

## 📦 Instalasi

### 1. Clone Repository

```bash
git clone https://github.com/username/catatan_kuliah.git
cd catatan_kuliah

2. Install Dependencies
flutter pub get

3. Setup Database
Nyalakan XAMPP (Apache + MySQL)
Buka http://localhost/phpmyadmin
Buat database catatan_kuliah_db
Jalankan query SQL:
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    mata_kuliah VARCHAR(100) NOT NULL,
    judul VARCHAR(255) NOT NULL,
    materi TEXT NOT NULL,
    tanggal VARCHAR(20) NOT NULL,
    kategori VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

4. Setup API
Copy folder catatan_kuliah_api ke C:\xampp\htdocs\
Pastikan file api.php berada di C:\xampp\htdocs\catatan_kuliah_api\api.php
Sesuaikan koneksi database di api.php

5. Konfigurasi IP
Buka lib/database/db_helper.dart dan sesuaikan URL:
static const String baseUrl = 'http://192.168.43.100/catatan_kuliah_api/api.php';
Catatan: Ganti IP dengan IP laptop/kamu saat terhubung ke hotspot HP.

🚀 Menjalankan Aplikasi
bash
# Jalankan di emulator
flutter run
# Build APK
flutter build apk
# Build APK Release
flutter build apk --release

👨‍💻 Profil Developer
Nama	NIM	Kelas
Raihan Akhdan Fadhillah	241091700073	04SISP002

📄 Lisensi
Project ini dibuat untuk memenuhi Proyek Akhir Semester mata kuliah Mobile Programming.

© 2026 Raihan Akhdan Fadhillah - All Rights Reserved

---

## 📁 **CARA PAKE:**

1. **Buat file** `README.md` di root project
2. **Copy paste** kode di atas
3. **Ganti** `username` di link git clone dengan username GitHub kamu
4. **Tambahkan folder** `screenshots/` dengan gambar aplikasi
5. **Push ke GitHub**
