# 🎬 Dims Movie

Sebuah aplikasi katalog film berbasis Flutter yang komprehensif. Aplikasi ini memungkinkan pengguna untuk menemukan film-film yang sedang tren, mencari judul spesifik melalui API TMDB, dan mengelola daftar tontonan (watchlist) pribadi lengkap dengan catatan kustom.

## 📱 Cuplikan Layar (Screenshots)

<div style="display: flex; justify-content: space-between;">
  <img src="screenshots/WhatsApp Image 2026-07-08 at 20.08.09.jpeg" alt="Beranda" width="23%">
  <img src="screenshots/WhatsApp Image 2026-07-08 at 20.08.09 (1).jpeg" alt="Pencarian" width="23%">
  <img src="screenshots/WhatsApp Image 2026-07-08 at 20.08.10.jpeg" alt="Detail Film" width="23%">
  <img src="screenshots/WhatsApp Image 2026-07-08 at 20.16.11.jpeg" alt="Watchlist & Catatan" width="23%">
</div>

## ✨ Fitur Utama

- **Film Trending**: Temukan film-film populer dan dengan rating tertinggi langsung dari halaman utama.
- **Pencarian Film**: Cari film favorit Anda melalui database TMDB yang sangat luas.
- **Informasi Detail**: Lihat detail film secara komprehensif, termasuk poster, rating, sinopsis, dan lainnya.
- **Watchlist Pribadi**: Simpan film ke dalam daftar tontonan pribadi untuk ditonton nanti.
- **Catatan Kustom**: Tambahkan catatan pribadi atau ulasan pada film yang ada di watchlist Anda.
- **State Management**: Dibangun menggunakan manajemen state yang andal dengan `provider`.
- **Integrasi Backend**: Mendukung sinkronisasi data melalui backend kustom (Node.js/PHP).

## 🛠️ Tech Stack (Teknologi yang Digunakan)

- **Frontend**: Flutter & Dart
- **State Management**: Provider
- **API**: [The Movie Database (TMDB) API](https://developer.themoviedb.org/docs)
- **Backend**: Integrasi backend kustom dengan Node.js / PHP untuk manajemen watchlist.

## 🚀 Panduan Memulai

### Prasyarat

- Flutter SDK (v3.12.0 atau lebih baru)
- Akses Token TMDB API v4

### Instalasi

1. **Clone repositori**
   ```bash
   git clone https://github.com/dimas-septiaji/dims-movie.git
   cd dplayer
   ```

2. **Instal dependensi**
   ```bash
   flutter pub get
   ```

3. **Setup Backend (Opsional)**
   Untuk menggunakan backend Node.js (opsional), salin file environment contoh dan sesuaikan:
   ```bash
   cp backend/.env.example backend/.env
   ```
   *Catatan: Isi variabel yang dibutuhkan secara lokal. File `.env` diabaikan oleh Git.*

### Menjalankan Aplikasi

> **⚠️ Penting**: Jangan pernah commit API keys atau kredensial database ke version control (Git).

Sertakan TMDB Access Token Anda saat menjalankan aplikasi.

**Untuk Development (Menjalankan secara lokal):**
```bash
flutter run --dart-define=TMDB_ACCESS_TOKEN=your_tmdb_v4_access_token
```

**Untuk Build Rilis (APK):**
```bash
flutter build apk --dart-define=TMDB_ACCESS_TOKEN=your_tmdb_v4_access_token
```

## 📂 Struktur Proyek

- `lib/screens/`: Berisi semua halaman UI (`home_screen`, `detail_screen`, `search_screen`, `watchlist_screen`).
- `lib/services/`: Menangani panggilan API ke TMDB (`tmdb_service`) dan backend kustom (`backend_service`).
- `lib/providers/`: File untuk state management aplikasi.
- `lib/models/`: Model data Dart untuk melakukan parsing respons JSON.
- `lib/widgets/`: Komponen UI yang dapat digunakan kembali (reusable).

## 📝 Lisensi

Proyek ini bersifat open-source dan tersedia di bawah [MIT License](LICENSE).
