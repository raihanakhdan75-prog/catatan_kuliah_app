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

catatan_kuliah/
├── lib/
│ ├── database/
│ │ └── db_helper.dart
│ ├── models/
│ │ └── note.dart
│ ├── screens/
│ │ ├── login_screen.dart
│ │ ├── register_screen.dart
│ │ ├── main_screen.dart
│ │ └── main_screen2.dart
│ └── main.dart
├── assets/
│ └── images/
│ └── logocatatankuliah.png
├── android/
├── ios/
├── pubspec.yaml
└── README.md


2. Install Dependencies

flutter pub get

3. Setup Database
Nyalakan XAMPP (Apache + MySQL)

Buat database catatan_kuliah_db

Import file SQL atau jalankan query:

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

Pastikan api.php berada di path yang benar

Sesuaikan koneksi database di api.php

5. Konfigurasi IP
Buka lib/database/db_helper.dart dan sesuaikan URL:
static const String baseUrl = 'http://192.168.43.100/catatan_kuliah_api/api.php';

PROFILE DEV
[RAIHAN AKHDAN FADHILLAH]	[241091700073]	[04SISP002]
