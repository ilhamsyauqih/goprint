# 📦 GoPrint — Product Requirements Document

> **Print & Administrasi Kampus**  
> Versi Dokumen: `v1.0.0` · Platform: `Flutter (iOS & Android)` · Backend: `Supabase`  
> Status: **Draft — Siap Review** · Terakhir diperbarui: Mei 2026

---

## Daftar Isi

1. [Ringkasan Eksekutif](#1-ringkasan-eksekutif)
2. [Informasi Produk & Ruang Lingkup](#2-informasi-produk--ruang-lingkup)
3. [Arsitektur Sistem & Teknologi](#3-arsitektur-sistem--teknologi)
4. [Panduan Desain Sistem](#4-panduan-desain-sistem-design-system)
5. [Autentikasi & Manajemen Role](#5-autentikasi--manajemen-role)
6. [Fitur — User / Pemesan](#6-fitur--user--pemesan)
7. [Fitur — Admin / Seller](#7-fitur--admin--seller-mitra-fotokopi)
8. [User Stories](#8-user-stories)
9. [Acceptance Criteria & Definition of Done](#9-acceptance-criteria--definition-of-done)
10. [Persyaratan Non-Fungsional](#10-persyaratan-non-fungsional)
11. [Alur Navigasi Aplikasi](#11-alur-navigasi-aplikasi)
12. [Rencana Pengembangan & Milestones](#12-rencana-pengembangan--milestones)
13. [Analisis Risiko & Mitigasi](#13-analisis-risiko--mitigasi)
14. [Metrik Keberhasilan (KPIs)](#14-metrik-keberhasilan-kpis)
15. [Glosarium & Referensi](#15-glosarium--referensi)

---

## 1. Ringkasan Eksekutif

**GoPrint** adalah aplikasi mobile berbasis Flutter yang menghubungkan mahasiswa dengan mitra fotokopi dan percetakan lokal di area kampus. Aplikasi ini hadir sebagai solusi atas permasalahan umum mahasiswa: antre panjang menjelang deadline, ketidakpastian harga, dan kesulitan mendapatkan layanan print berkualitas dengan cepat.

Dengan GoPrint, mahasiswa dapat mengunggah file, memilih layanan (print, jilid, laminating, scan, fotokopi), melihat estimasi harga secara real-time, dan memesan pengantaran ke kos atau titik tertentu. Di sisi lain, mitra fotokopi (Admin/Seller) mendapatkan dashboard manajemen pesanan yang terstruktur dan efisien.

> 🎯 **Visi:** Menjadi platform layanan dokumen kampus #1 di Indonesia yang memudahkan mahasiswa mendapatkan layanan cetak berkualitas, cepat, dan terjangkau dari genggaman tangan.

### 1.1 Pernyataan Masalah

- Mahasiswa sering mengalami antrean panjang di fotokopi saat mendekati deadline tugas atau ujian
- Tidak ada transparansi harga — mahasiswa harus datang langsung untuk mengetahui biaya
- Ketidaktersediaan template dokumen standar kampus (surat izin, cover laporan, daftar pustaka)
- Mitra fotokopi kesulitan mengelola banyak pesanan secara bersamaan tanpa sistem digital
- Tidak ada layanan antar dokumen ke kos atau titik penjemputan

### 1.2 Solusi yang Ditawarkan

- Pemesanan layanan print, jilid, laminating, scan, dan fotokopi secara digital
- Kalkulasi harga otomatis berdasarkan jumlah halaman, jenis kertas, warna, dan finishing
- Upload file langsung dari aplikasi (PDF, Word, JPG, dll.) ke cloud Supabase Storage
- Layanan antar ke kos atau titik kampus yang telah ditentukan
- Template dokumen kampus siap pakai yang dapat diunduh dan dikustomisasi
- Dashboard Admin/Seller untuk manajemen pesanan, laporan, dan keuangan
- Sistem notifikasi real-time via Supabase Realtime untuk update status pesanan

---

## 2. Informasi Produk & Ruang Lingkup

### 2.1 Identitas Produk

| Parameter | Keterangan |
|-----------|------------|
| **Nama Aplikasi** | GoPrint |
| **Tagline** | Print dan Administrasi Kampus, Cepat di Genggamanmu |
| **Platform** | Flutter (Android & iOS) |
| **Min. Android Version** | Android 8.0 (API Level 26) |
| **Min. iOS Version** | iOS 14.0 |
| **Backend** | Supabase (PostgreSQL, Auth, Storage, Realtime, Edge Functions) |
| **State Management** | Riverpod / BLoC |
| **Bahasa Aplikasi** | Indonesia |
| **Tema Warna** | Light Mode (Abu-abu Cerah) & Dark Mode (Abu-abu Gelap) + Aksen Teal |

### 2.2 Target Pengguna

| Segmen | Deskripsi | Kebutuhan Utama |
|--------|-----------|-----------------|
| **Mahasiswa (User/Pemesan)** | Mahasiswa aktif usia 18–25 tahun yang membutuhkan layanan cetak untuk tugas, laporan, dan keperluan kampus | Kemudahan pesan, harga transparan, antar ke kos |
| **Mitra Fotokopi (Admin/Seller)** | Pemilik atau operator fotokopi lokal di area kampus yang ingin meningkatkan efisiensi operasional | Dashboard pesanan, manajemen layanan & harga, laporan keuangan |
| **Superadmin (Platform)** | Tim internal GoPrint yang mengelola ekosistem platform secara keseluruhan | Manajemen mitra, monitoring, analitik platform |

### 2.3 Ruang Lingkup (Scope)

#### ✅ Dalam Scope (In-Scope)

- Autentikasi pengguna dengan role (User, Admin/Seller) via Supabase Auth
- Fitur pemesanan layanan: print, jilid, laminating, scan, fotokopi
- Upload dan manajemen file dokumen via Supabase Storage
- Kalkulasi harga otomatis real-time
- Sistem pembayaran in-app (integrasi payment gateway)
- Notifikasi real-time status pesanan
- Layanan antar ke lokasi pengguna
- Template dokumen kampus
- Dashboard Admin: manajemen pesanan, layanan, harga, laporan
- Histori pesanan dan tracking status untuk User
- Ulasan dan rating layanan
- Light Mode dan Dark Mode dengan tema abu-abu + gradasi teal

#### ❌ Di Luar Scope (Out-of-Scope)

- Layanan percetakan besar (undangan, spanduk, baliho) — fase berikutnya
- Integrasi dengan sistem akademik kampus (SIAKAD) — fase berikutnya
- Aplikasi web (web app) — hanya mobile Flutter
- Fitur chat langsung antara user dan seller — gunakan notifikasi

---

## 3. Arsitektur Sistem & Teknologi

### 3.1 Arsitektur Aplikasi

GoPrint menggunakan **Clean Architecture** dengan pemisahan layer yang jelas:

| Layer | Tanggung Jawab | Teknologi |
|-------|---------------|-----------|
| **Presentation Layer** | UI, Widget, Screen, State Management | Flutter, Riverpod/BLoC |
| **Domain Layer** | Business Logic, Use Cases, Entities | Pure Dart |
| **Data Layer** | Repository Impl, Data Sources, Models | Supabase SDK, Dart |
| **Infrastructure** | Storage, Auth, Realtime, Edge Functions | Supabase Platform |

### 3.2 Stack Teknologi

#### Frontend (Flutter)

| Package | Fungsi | Versi Target |
|---------|--------|--------------|
| `supabase_flutter` | Koneksi ke Supabase (Auth, DB, Storage, Realtime) | `^2.x` |
| `flutter_riverpod` | State management | `^2.x` |
| `go_router` | Navigasi deklaratif berbasis route | `^12.x` |
| `dio` | HTTP client untuk API eksternal | `^5.x` |
| `file_picker` | Pilih file dari storage device | `^6.x` |
| `image_picker` | Pilih gambar dari kamera/galeri | `^1.x` |
| `flutter_pdfview` | Preview PDF dalam aplikasi | `^1.x` |
| `cached_network_image` | Cache gambar dari network | `^3.x` |
| `fl_chart` | Grafik dan chart untuk dashboard | `^0.67.x` |
| `lottie` | Animasi Lottie untuk loading & success state | `^2.x` |
| `shimmer` | Loading skeleton effect | `^3.x` |
| `intl` | Formatting tanggal, waktu, mata uang (IDR) | `^0.19.x` |
| `path_provider` | Akses direktori sistem file lokal | `^2.x` |
| `flutter_local_notifications` | Notifikasi lokal | `^16.x` |
| `share_plus` | Berbagi file/link | `^7.x` |
| `url_launcher` | Buka URL eksternal / WhatsApp | `^6.x` |

#### Backend (Supabase)

| Komponen Supabase | Penggunaan |
|-------------------|------------|
| **Authentication** | Login, Register, Role-based Access (user / admin) |
| **PostgreSQL Database** | Semua data: users, orders, services, files, payments, reviews |
| **Row Level Security (RLS)** | Pembatasan akses data berdasarkan role pengguna |
| **Storage** | Upload & download file dokumen (PDF, DOCX, JPG, PNG) |
| **Realtime** | Update status pesanan secara live tanpa polling |
| **Edge Functions** | Logika server-side: hitung harga, validasi, kirim notifikasi |
| **PostgREST API** | Auto-generated REST API dari schema database |
| **Webhooks** | Trigger aksi setelah event tertentu (pesanan baru, status berubah) |

---

### 3.3 Skema Database Supabase

#### Tabel: `users`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | `UUID (PK)` | ID unik pengguna, referensi ke `auth.users` |
| `email` | `TEXT UNIQUE` | Email pengguna |
| `full_name` | `TEXT` | Nama lengkap |
| `phone_number` | `TEXT` | Nomor WhatsApp aktif |
| `avatar_url` | `TEXT` | URL foto profil di Supabase Storage |
| `role` | `ENUM('user','admin','superadmin')` | Role pengguna dalam sistem |
| `address` | `TEXT` | Alamat kos / domisili default |
| `is_active` | `BOOLEAN DEFAULT true` | Status akun aktif/nonaktif |
| `created_at` | `TIMESTAMPTZ` | Waktu registrasi |

#### Tabel: `shops`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | `UUID (PK)` | ID unik toko |
| `owner_id` | `UUID (FK → users.id)` | ID pemilik / admin toko |
| `shop_name` | `TEXT` | Nama toko fotokopi |
| `description` | `TEXT` | Deskripsi layanan toko |
| `address` | `TEXT` | Alamat fisik toko |
| `latitude` | `FLOAT8` | Koordinat GPS lintang |
| `longitude` | `FLOAT8` | Koordinat GPS bujur |
| `phone` | `TEXT` | Nomor kontak toko |
| `logo_url` | `TEXT` | URL logo toko |
| `is_open` | `BOOLEAN DEFAULT true` | Status buka/tutup |
| `operating_hours` | `JSONB` | Jam operasional per hari |
| `rating_avg` | `FLOAT4 DEFAULT 0` | Rata-rata rating toko |
| `total_reviews` | `INTEGER DEFAULT 0` | Total ulasan yang masuk |
| `created_at` | `TIMESTAMPTZ` | Waktu toko dibuat |

#### Tabel: `services`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | `UUID (PK)` | ID layanan |
| `shop_id` | `UUID (FK → shops.id)` | Toko yang menyediakan layanan |
| `service_type` | `ENUM('print','binding','laminating','scan','photocopy')` | Jenis layanan |
| `name` | `TEXT` | Nama tampilan layanan |
| `base_price_per_page` | `INTEGER` | Harga dasar per halaman (IDR) |
| `color_price_per_page` | `INTEGER` | Harga tambahan untuk warna |
| `paper_types` | `JSONB` | Jenis kertas tersedia + harga tambahan |
| `finishing_options` | `JSONB` | Opsi finishing + harga (spiral, softcover, dll) |
| `is_available` | `BOOLEAN DEFAULT true` | Status ketersediaan layanan |
| `description` | `TEXT` | Keterangan tambahan layanan |
| `estimated_hours` | `INTEGER` | Estimasi waktu pengerjaan (jam) |

#### Tabel: `orders`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | `UUID (PK)` | ID unik pesanan |
| `order_number` | `TEXT UNIQUE` | Kode pesanan (DOC-20260501-0001) |
| `user_id` | `UUID (FK → users.id)` | ID pengguna pemesan |
| `shop_id` | `UUID (FK → shops.id)` | ID toko yang menangani |
| `status` | `ENUM` | `pending` → `confirmed` → `processing` → `ready` → `delivered` → `completed` → `cancelled` |
| `total_pages` | `INTEGER` | Total halaman yang dicetak |
| `total_price` | `INTEGER` | Total harga dalam IDR |
| `delivery_type` | `ENUM('pickup','delivery')` | Ambil sendiri / antar |
| `delivery_address` | `TEXT` | Alamat pengantaran (jika delivery) |
| `delivery_fee` | `INTEGER DEFAULT 0` | Biaya antar (IDR) |
| `payment_status` | `ENUM('unpaid','paid','refunded')` | Status pembayaran |
| `payment_method` | `TEXT` | Metode pembayaran |
| `notes` | `TEXT` | Catatan khusus dari pemesan |
| `estimated_done_at` | `TIMESTAMPTZ` | Estimasi selesai |
| `confirmed_at` | `TIMESTAMPTZ` | Waktu dikonfirmasi admin |
| `completed_at` | `TIMESTAMPTZ` | Waktu selesai |
| `created_at` | `TIMESTAMPTZ` | Waktu pesanan dibuat |

#### Tabel: `order_items`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | `UUID (PK)` | ID item |
| `order_id` | `UUID (FK → orders.id)` | ID pesanan induk |
| `service_id` | `UUID (FK → services.id)` | ID layanan yang dipilih |
| `file_url` | `TEXT` | URL file di Supabase Storage |
| `file_name` | `TEXT` | Nama file asli |
| `page_count` | `INTEGER` | Jumlah halaman file |
| `copies` | `INTEGER DEFAULT 1` | Jumlah eksemplar |
| `is_color` | `BOOLEAN DEFAULT false` | Hitam-putih atau berwarna |
| `paper_type` | `TEXT` | Jenis kertas (A4, HVS, Art Paper, dll) |
| `finishing` | `TEXT` | Jenis finishing (spiral, softcover, dll) |
| `double_sided` | `BOOLEAN DEFAULT false` | Bolak-balik atau satu sisi |
| `subtotal` | `INTEGER` | Subtotal item (IDR) |
| `notes` | `TEXT` | Catatan per item |

#### Tabel: `payments`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | `UUID (PK)` | ID pembayaran |
| `order_id` | `UUID (FK → orders.id)` | ID pesanan terkait |
| `amount` | `INTEGER` | Jumlah pembayaran (IDR) |
| `payment_method` | `TEXT` | QRIS, Transfer Bank, GoPay, OVO, Dana |
| `payment_proof_url` | `TEXT` | URL bukti pembayaran di Storage |
| `status` | `ENUM('pending','verified','rejected')` | Status verifikasi |
| `verified_by` | `UUID (FK → users.id)` | Admin yang memverifikasi |
| `verified_at` | `TIMESTAMPTZ` | Waktu verifikasi |
| `transaction_id` | `TEXT` | ID transaksi dari payment gateway |
| `created_at` | `TIMESTAMPTZ` | Waktu pembayaran dibuat |

#### Tabel: `reviews`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | `UUID (PK)` | ID ulasan |
| `order_id` | `UUID (FK → orders.id)` | ID pesanan yang diulas |
| `user_id` | `UUID (FK → users.id)` | ID pengguna pemberi ulasan |
| `shop_id` | `UUID (FK → shops.id)` | ID toko yang diulas |
| `rating` | `INTEGER CHECK (1–5)` | Nilai rating 1–5 bintang |
| `comment` | `TEXT` | Komentar teks ulasan |
| `photo_urls` | `JSONB` | Array URL foto bukti (opsional) |
| `is_anonymous` | `BOOLEAN DEFAULT false` | Tampilkan anonim atau tidak |
| `created_at` | `TIMESTAMPTZ` | Waktu ulasan dikirim |

#### Tabel: `templates`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | `UUID (PK)` | ID template |
| `name` | `TEXT` | Nama template |
| `category` | `TEXT` | `surat_izin`, `cover_laporan`, `daftar_pustaka`, `proposal`, `abstrak`, `berita_acara` |
| `file_url` | `TEXT` | URL file template di Storage |
| `thumbnail_url` | `TEXT` | URL thumbnail preview |
| `download_count` | `INTEGER DEFAULT 0` | Jumlah unduhan |
| `is_active` | `BOOLEAN DEFAULT true` | Status aktif |
| `created_at` | `TIMESTAMPTZ` | Waktu ditambahkan |

#### Tabel: `notifications`

| Kolom | Tipe | Keterangan |
|-------|------|------------|
| `id` | `UUID (PK)` | ID notifikasi |
| `user_id` | `UUID (FK → users.id)` | Penerima notifikasi |
| `title` | `TEXT` | Judul notifikasi |
| `body` | `TEXT` | Isi pesan notifikasi |
| `type` | `TEXT` | `order_update`, `payment`, `promo`, `system` |
| `related_id` | `UUID` | ID entitas terkait (order/payment) |
| `is_read` | `BOOLEAN DEFAULT false` | Status sudah dibaca |
| `created_at` | `TIMESTAMPTZ` | Waktu dikirim |

---

## 4. Panduan Desain Sistem (Design System)

### 4.1 Filosofi Desain

GoPrint mengadopsi filosofi **Modern Minimalist** dengan sentuhan gradasi yang memberikan kesan profesional namun tetap hangat dan mudah digunakan oleh mahasiswa. Desain berfokus pada kemudahan navigasi, keterbacaan tinggi, dan konsistensi visual di kedua mode tampilan.

> 💡 **Prinsip Desain:** Clarity · Consistency · Accessibility · Delight

### 4.2 Palet Warna — Light Mode (Abu-abu Cerah)

| Peran Warna | Nama | Hex | Penggunaan |
|-------------|------|-----|------------|
| Primary Background | Light Grey 50 | `#F5F5F5` | Background utama semua halaman |
| Surface / Card | Light Grey 100 | `#EEEEEE` | Kartu, modal, bottom sheet |
| Border / Divider | Light Grey 300 | `#E0E0E0` | Garis pemisah, border kartu |
| Subtle Text | Grey 500 | `#9E9E9E` | Label sekunder, placeholder |
| Primary Text | Grey 900 | `#212121` | Judul, body text utama |
| Accent / Brand | Teal 700 | `#00796B` | Tombol utama, ikon aktif, highlight |
| Accent Light | Teal 200 | `#80CBC4` | Background chip, badge, indikator |
| Gradient Start | Teal 600 | `#00897B` | Awal gradasi header |
| Gradient End | Teal 900 | `#004D40` | Akhir gradasi header |
| Success | Green 800 | `#2E7D32` | Status selesai, konfirmasi |
| Warning | Amber 800 | `#F57F17` | Status proses, peringatan |
| Error | Red 800 | `#C62828` | Status batal, error validasi |
| Info | Blue 900 | `#01579B` | Status konfirmasi, informasi |

### 4.3 Palet Warna — Dark Mode (Abu-abu Gelap)

| Peran Warna | Nama | Hex | Penggunaan |
|-------------|------|-----|------------|
| Primary Background | Dark Grey 900 | `#1A1A1A` | Background utama semua halaman |
| Surface / Card | Dark Grey 800 | `#2E2E2E` | Kartu, modal, bottom sheet |
| Elevated Surface | Dark Grey 700 | `#3D3D3D` | Kartu terangkat, dialog |
| Border / Divider | Dark Grey 600 | `#4D4D4D` | Garis pemisah, border |
| Muted Text | Grey 500 | `#9E9E9E` | Label sekunder, placeholder |
| Primary Text | Grey 50 | `#FAFAFA` | Judul, body text utama |
| Accent / Brand | Teal 300 | `#4DB6AC` | Tombol utama, ikon aktif |
| Accent Dark | Teal 700 | `#00796B` | Background chip, badge |
| Gradient Start | Teal 800 | `#00695C` | Awal gradasi header |
| Gradient End | Dark Grey 900 | `#1A1A1A` | Akhir gradasi header |
| Success | Green 400 | `#66BB6A` | Status selesai |
| Warning | Amber 400 | `#FFCA28` | Status proses |
| Error | Red 400 | `#EF5350` | Status batal, error |
| Info | Blue 400 | `#42A5F5` | Status konfirmasi |

### 4.4 Tipografi

| Style | Font Family | Size | Weight | Penggunaan |
|-------|-------------|------|--------|------------|
| Display Large | Poppins | 32sp | Bold 700 | Judul splash screen, onboarding |
| Headline Large | Poppins | 28sp | SemiBold 600 | Judul halaman utama |
| Headline Medium | Poppins | 24sp | SemiBold 600 | Judul seksi, kartu utama |
| Title Large | Poppins | 20sp | Medium 500 | Nama layanan, judul dialog |
| Title Medium | Poppins | 16sp | Medium 500 | Label tab, header list |
| Body Large | Inter | 16sp | Regular 400 | Deskripsi, paragraf panjang |
| Body Medium | Inter | 14sp | Regular 400 | Konten umum, label form |
| Label Large | Inter | 14sp | Medium 500 | Teks tombol, badge |
| Label Medium | Inter | 12sp | Medium 500 | Caption, metadata |
| Label Small | Inter | 10sp | Regular 400 | Timestamp, footnote |

### 4.5 Komponen UI Utama

#### Tombol (Button)
- **Primary Button** — Background gradasi teal (`Teal 600 → Teal 900`), radius 12dp, teks putih Bold
- **Secondary Button** — Border teal 1.5dp, background transparan, teks teal, radius 12dp
- **Danger Button** — Background gradasi merah, radius 12dp, teks putih
- **Icon Button** — Circular, background surface, ikon teal, shadow elevation 2
- **FAB** — Gradasi teal, ikon putih, shadow elevation 6, radius 16dp

#### Kartu (Card)
- **Order Card** — Radius 16dp, shadow elevation 3, border-left 4dp berwarna status
- **Service Card** — Radius 12dp, thumbnail atas, padding 16dp, gradient overlay pada gambar
- **Info Card** — Background surface, radius 8dp, border teal kiri, padding 12–16dp

#### Form & Input
- **TextField** — Underline style (light), filled style (dark), label float, ikon prefix teal
- **Dropdown** — Custom styling dengan panah teal, radius 8dp
- **Checkbox / Toggle** — Warna teal saat aktif
- **File Upload Area** — Dashed border teal, ikon upload, background `lightCard`

#### Navigasi
- **Bottom Navigation Bar** — 5 tab (Home, Pesanan, Template, Notifikasi, Profil), ikon + label
- **App Bar** — Gradasi teal, judul putih SemiBold, back button putih
- **Drawer (Admin)** — Menu sidebar dengan header bergradasi, ikon teal

#### Gradasi (Gradients)
- **Header Gradient** — `LinearGradient(Teal 600 → Teal 900)`, arah 135°
- **Card Overlay** — `LinearGradient(transparan → Black 70%)`, arah bawah
- **Status Badge** — Sesuai status pesanan
- **Splash Screen** — `RadialGradient(Teal 400 → Teal 900)`

---

## 5. Autentikasi & Manajemen Role

### 5.1 Sistem Autentikasi Supabase

GoPrint menggunakan **Supabase Authentication** sebagai sistem autentikasi terpusat. Setelah login berhasil, JWT token Supabase digunakan untuk semua request API. Row Level Security (RLS) pada setiap tabel memastikan pengguna hanya dapat mengakses data yang sesuai dengan role-nya.

### 5.2 Role Pengguna

| Role | Akses | Registrasi |
|------|-------|------------|
| `user` | Fitur pemesanan, histori, template, profil, ulasan | Self-register via form registrasi aplikasi |
| `admin` | Dashboard manajemen pesanan, layanan, harga, laporan | Disetujui superadmin setelah verifikasi |
| `superadmin` | Akses penuh: semua user, admin, toko, template, analitik | Hanya dari backend / seeding database |

### 5.3 Alur Registrasi User (Pemesan)

```
1. User buka aplikasi → pilih "Daftar Akun"
2. Isi form: Nama Lengkap, Email, Password, Nomor HP
3. Supabase Auth kirim email verifikasi
4. User klik link verifikasi
5. Supabase buat record di tabel users dengan role = 'user'
6. User diarahkan ke pengisian profil lengkap (alamat, foto)
7. User siap menggunakan aplikasi ✓
```

### 5.4 Alur Registrasi Admin (Seller/Mitra Fotokopi)

```
1. Calon admin isi form pendaftaran mitra (Nama Usaha, Alamat, KTP, Nomor HP)
2. Data dikirim → superadmin menerima notifikasi pengajuan baru
3. Superadmin melakukan verifikasi → setujui / tolak
4. Jika disetujui: akun admin dibuat, toko (shop) diaktifkan
5. Admin terima email kredensial + panduan onboarding
6. Admin lengkapi profil toko: jam operasional, layanan, harga ✓
```

### 5.5 Alur Login

```
1. User/Admin masukkan email + password
2. Supabase Auth validasi kredensial
3. JWT token diterima → disimpan di Flutter Secure Storage
4. Aplikasi baca role dari tabel users berdasarkan auth.uid()
5. Routing sesuai role:
   - user → Home Screen
   - admin → Dashboard Admin
   - superadmin → Admin Panel ✓
```

### 5.6 Row Level Security (RLS) Policies

| Tabel | Policy | Deskripsi |
|-------|--------|-----------|
| `users` | SELECT own | User hanya bisa lihat data dirinya sendiri |
| `users` | UPDATE own | User hanya bisa update data dirinya |
| `shops` | SELECT all | Semua user bisa lihat daftar toko aktif |
| `shops` | UPDATE own | Admin hanya bisa update toko miliknya |
| `orders` | SELECT own (user) | User hanya lihat pesanan miliknya |
| `orders` | SELECT shop (admin) | Admin hanya lihat pesanan ke tokonya |
| `orders` | INSERT (user) | Hanya user yang bisa membuat pesanan baru |
| `order_items` | Via orders RLS | Inherit RLS dari tabel orders |
| `payments` | SELECT own | User lihat miliknya, admin lihat ke tokonya |
| `reviews` | INSERT (once per order) | Satu ulasan per pesanan selesai |
| `templates` | SELECT all | Semua user bisa download template |
| `notifications` | SELECT own | User hanya lihat notifikasi miliknya |

---

## 6. Fitur — User / Pemesan

### 6.1 Onboarding & Splash Screen

#### Splash Screen
- Logo GoPrint dengan animasi Lottie
- Background gradasi radial: `Teal 400 → Teal 900`
- Tagline muncul dengan efek fade-in
- Auto-navigate setelah 2.5 detik → cek status login

#### Onboarding (3 Slide)
| Slide | Ilustrasi | Deskripsi |
|-------|-----------|-----------|
| 1 | Upload file | _"Upload file dari mana saja"_ |
| 2 | Kalkulasi harga | _"Harga transparan sebelum bayar"_ |
| 3 | Pengantaran | _"Terima dokumen di kos kamu"_ |

- Indicator dots bergradasi, tombol Skip & Next
- Slide 3 memiliki tombol **"Mulai Sekarang"** → halaman login

---

### 6.2 Halaman Utama (Home)

**Komponen:**
- App Bar bergradasi — sapaan `"Halo, {Nama}!"` + ikon notifikasi
- Search Bar untuk mencari toko atau layanan
- **Banner Promo** — Horizontal scroll, gambar promosi dari admin
- **Kategori Layanan** — Grid 2×3: Print, Jilid, Laminating, Scan, Fotokopi, Template
- **Toko Terdekat** — Horizontal scroll kartu (nama, rating, jarak, status buka)
- **Pesanan Aktif** — Card ringkasan pesanan berjalan (real-time)
- **Rekomendasi Template** — Grid template populer

**Logika Bisnis:**
- Jarak toko dihitung dari GPS pengguna vs koordinat toko (Haversine formula)
- Toko ditampilkan berdasarkan jarak terdekat + status buka
- Pesanan aktif diambil real-time via Supabase Realtime

---

### 6.3 Pembuatan Pesanan (Order Flow — 6 Langkah)

#### Langkah 1: Pilih Toko
- Daftar/peta toko aktif terdekat
- Filter: jenis layanan, rating, jarak, jam buka
- Detail toko: foto, rating, jam operasional, layanan, ulasan

#### Langkah 2: Pilih Layanan
- Menu layanan dari toko yang dipilih
- Setiap layanan: nama, harga mulai dari, estimasi waktu
- Multi-item: bisa tambah beberapa layanan sekaligus

#### Langkah 3: Upload File & Konfigurasi
- Upload via File Picker (PDF, DOCX, JPG, PNG — maks 50MB/file)
- Preview file sebelum konfirmasi
- Konfigurasi per file: jumlah eksemplar, warna/hitam-putih, jenis kertas, double-side, finishing
- Deteksi otomatis jumlah halaman dari PDF
- Catatan khusus per item (opsional)

#### Langkah 4: Kalkulasi Harga (Real-time)

```
Subtotal = (halaman × harga_per_halaman)
         + (is_color ? halaman × color_price : 0)
         + biaya_finishing
         + biaya_kertas_premium
         + delivery_fee (jika delivery)
```

- Update instan setiap konfigurasi berubah
- Tampilkan breakdown harga per item + estimasi selesai

#### Langkah 5: Pilih Metode Pengambilan
| Tipe | Keterangan |
|------|------------|
| **Pickup** | Ambil sendiri — tampilkan alamat toko + jam buka |
| **Delivery** | Antar ke lokasi — input alamat, tampilkan estimasi biaya |

#### Langkah 6: Konfirmasi & Pembayaran
- Ringkasan pesanan lengkap sebelum submit
- Metode pembayaran: QRIS, Transfer Bank, GoPay, OVO, Dana
- Upload bukti transfer (jika metode manual)
- Nomor pesanan auto-generate: `DOC-YYYYMMDD-XXXX`
- Pesanan masuk ke tabel `orders` dengan status `pending`

---

### 6.4 Tracking Pesanan

#### Daftar Pesanan
- Tab: **Aktif | Selesai | Dibatalkan**
- Kartu pesanan: nomor, nama toko, status badge, total, tanggal
- Pull-to-refresh

#### Detail Pesanan — Timeline Status

```
📋 Menunggu Konfirmasi
       ↓
✅ Dikonfirmasi
       ↓
⚙️  Diproses
       ↓
📦 Siap Diambil / Diantar
       ↓
🎉 Selesai
```

- Timeline visual bergradasi teal dengan titik-titik status
- Detail item: thumbnail file, konfigurasi, subtotal
- Informasi pembayaran dan bukti transfer
- Tombol **Batalkan** (hanya status `pending`)
- Tombol **Beri Ulasan** (hanya status `completed`)
- Update status real-time via Supabase Realtime

---

### 6.5 Template Dokumen Kampus

| Kategori | Contoh Template |
|----------|----------------|
| Surat Izin | Surat izin tidak masuk, surat permohonan |
| Cover Laporan | Cover PKL, cover skripsi, cover KKN |
| Daftar Pustaka | Format APA, IEEE, Chicago |
| Proposal | Proposal penelitian, proposal kegiatan |
| Abstrak | Abstrak skripsi, abstrak jurnal |
| Berita Acara | Berita acara rapat, serah terima |

**Fitur:**
- Preview thumbnail sebelum download
- Download dalam format DOCX / PDF
- Cari dan filter template
- Track jumlah download
- Rating template (1–5 bintang)

---

### 6.6 Notifikasi

- Push notification via **Firebase Cloud Messaging (FCM)** + Supabase Webhook
- In-app notification center dengan badge merah
- Jenis: `order_update`, `payment`, `promo`, `system`
- Tandai semua sudah dibaca dengan satu tap
- Tap notifikasi → deep link ke halaman terkait

---

### 6.7 Profil Pengguna

- Foto profil: ambil dari kamera/galeri → upload ke Supabase Storage
- Edit data: nama, nomor HP, alamat kos
- Manajemen alamat: simpan beberapa alamat pengiriman favorit
- Ubah password dengan validasi password lama
- Pengaturan notifikasi per kategori
- **Toggle tema: Light Mode / Dark Mode / Ikuti Sistem**
- Tentang Aplikasi, Kebijakan Privasi, Syarat & Ketentuan
- Logout dengan konfirmasi dialog

---

### 6.8 Ulasan & Rating

- Ulasan hanya tersedia setelah pesanan `completed`
- Rating bintang 1–5 (wajib)
- Komentar teks (opsional, maks 500 karakter)
- Upload foto hasil cetakan (opsional, maks 3 foto)
- Pilihan tampil anonim
- Satu ulasan per pesanan (enforced via RLS)

---

## 7. Fitur — Admin / Seller (Mitra Fotokopi)

### 7.1 Dashboard Utama Admin

#### Statistik Hari Ini (Real-time Cards)
- 📊 Total pesanan masuk hari ini
- ⚠️ Pesanan menunggu konfirmasi (badge merah jika > 0)
- 💰 Total pendapatan hari ini (IDR)
- ⚙️ Pesanan sedang diproses

#### Grafik Pendapatan
- Line chart: pendapatan 7 / 30 hari terakhir
- Bar chart: pesanan per layanan (print, jilid, dll)
- Filter periode: Hari Ini, 7 Hari, 30 Hari, Custom Range

#### Widget Pesanan Terbaru
- Daftar 5 pesanan terbaru dengan status real-time
- Tap → langsung ke detail pesanan

---

### 7.2 Manajemen Pesanan

#### Daftar Pesanan
- Tab: **Semua | Pending | Konfirmasi | Proses | Siap | Selesai | Batal**
- Pencarian: nomor pesanan atau nama pemesan
- Sort: terbaru, terlama, nilai tertinggi
- Pagination: 20 item per halaman

#### Detail Pesanan (Admin View) — Aksi per Status

| Status | Tombol Aksi |
|--------|------------|
| `pending` | ✅ Konfirmasi / ❌ Tolak (+ isi alasan) |
| `confirmed` | ▶️ Mulai Proses + set estimasi selesai |
| `processing` | 📦 Tandai Siap |
| `ready` (delivery) | 🚚 Konfirmasi Sudah Diantar |
| `ready` (pickup) | ✅ Selesai |

**Fitur tambahan:**
- Download file yang diupload pemesan
- Klik nomor HP pemesan → langsung WhatsApp
- Verifikasi pembayaran manual (approve/reject bukti transfer)
- Kolom catatan internal (tidak terlihat user)

---

### 7.3 Manajemen Layanan & Harga

#### Konfigurasi per Layanan

| Field | Keterangan |
|-------|------------|
| Tipe layanan | Print, Jilid, Laminating, Scan, Fotokopi |
| Nama tampilan | Nama yang ditampilkan ke pemesan |
| Harga dasar per halaman | Hitam-putih (IDR) |
| Harga tambahan warna | Per halaman berwarna (IDR) |
| Harga kertas | A4 HVS, A4 Buram, F4, A3, Art Paper (masing-masing) |
| Opsi finishing | Spiral, Softcover, Hardcover, Klip, Laminating + harga |
| Estimasi waktu | Jam pengerjaan |
| Status | Aktif / Nonaktif |

---

### 7.4 Manajemen Profil Toko

- Edit nama, deskripsi, alamat lengkap
- Upload logo toko (Supabase Storage)
- Upload foto toko (galeri, maks 5 foto)
- Atur koordinat GPS (pilih di peta atau input manual)
- **Jam operasional per hari** (Senin–Minggu) dengan toggle libur
- Nomor kontak (WhatsApp) untuk pemesan
- **Toggle status buka/tutup** manual (untuk libur mendadak)

---

### 7.5 Laporan & Keuangan

#### Laporan Pendapatan
- Total pendapatan per periode (harian, mingguan, bulanan)
- Breakdown per layanan
- Grafik tren pendapatan

#### Laporan Pesanan
- Total pesanan per status per periode
- Pesanan dibatalkan + alasan pembatalan
- Rata-rata nilai pesanan & waktu pengerjaan

#### Export Laporan
- Format: **PDF** / **Excel (CSV)**
- Filter tanggal custom sebelum export

---

### 7.6 Manajemen Ulasan

- Lihat semua ulasan yang masuk ke toko
- Filter berdasarkan rating (1–5 bintang)
- Balas ulasan (reply) dari admin
- Laporkan ulasan tidak pantas ke superadmin

---

### 7.7 Notifikasi Admin

- Notifikasi real-time untuk pesanan baru (**kritis!**)
- Notifikasi pembayaran yang perlu diverifikasi
- Ringkasan harian terjadwal (jumlah pesanan & pendapatan)
- Setting: bunyi, getar, intensitas notifikasi

---

## 8. User Stories

### 8.1 User Stories — Pengguna (User/Pemesan)

| ID | As a... | I want to... | So that... | Priority |
|----|---------|-------------|------------|----------|
| US-001 | User | Mendaftar akun dengan email dan password | Saya dapat menggunakan layanan GoPrint | 🔴 Critical |
| US-002 | User | Login ke aplikasi | Saya dapat mengakses fitur pemesanan | 🔴 Critical |
| US-003 | User | Melihat daftar toko fotokopi terdekat | Saya dapat memilih toko yang paling mudah dijangkau | 🔴 Critical |
| US-004 | User | Upload file dokumen dari HP saya | File saya dapat diproses untuk dicetak | 🔴 Critical |
| US-005 | User | Melihat estimasi harga secara real-time | Saya tahu berapa biaya sebelum konfirmasi pesanan | 🔴 Critical |
| US-006 | User | Memilih konfigurasi cetak (warna, kertas, finishing) | Dokumen dicetak sesuai kebutuhan saya | 🟠 High |
| US-007 | User | Memilih layanan antar ke kos | Saya tidak perlu datang ke toko | 🟠 High |
| US-008 | User | Melakukan pembayaran in-app via QRIS | Pembayaran mudah tanpa cash | 🟠 High |
| US-009 | User | Memantau status pesanan secara real-time | Saya tahu kapan dokumen siap diambil | 🔴 Critical |
| US-010 | User | Menerima notifikasi update pesanan | Saya tidak perlu terus membuka aplikasi | 🟠 High |
| US-011 | User | Membatalkan pesanan yang belum dikonfirmasi | Saya bisa ubah keputusan jika ada perubahan | 🟡 Medium |
| US-012 | User | Melihat histori semua pesanan saya | Saya bisa lacak pengeluaran dan riwayat cetak | 🟡 Medium |
| US-013 | User | Mengunduh template dokumen kampus | Saya hemat waktu dalam membuat dokumen standar | 🟠 High |
| US-014 | User | Memberikan ulasan dan rating setelah pesanan selesai | Saya bisa bantu pengguna lain memilih toko | 🟡 Medium |
| US-015 | User | Menyimpan beberapa alamat pengiriman | Saya tidak perlu input ulang setiap memesan | 🟢 Low |
| US-016 | User | Beralih antara Light Mode dan Dark Mode | Saya bisa gunakan aplikasi sesuai kondisi pencahayaan | 🟡 Medium |

### 8.2 User Stories — Admin / Seller

| ID | As an... | I want to... | So that... | Priority |
|----|---------|-------------|------------|----------|
| AS-001 | Admin | Login ke dashboard admin | Saya dapat mengelola pesanan dan toko | 🔴 Critical |
| AS-002 | Admin | Melihat notifikasi pesanan baru secara real-time | Saya segera tahu ada pesanan masuk | 🔴 Critical |
| AS-003 | Admin | Mengkonfirmasi atau menolak pesanan masuk | Pesanan yang tidak bisa diproses bisa ditolak dengan alasan | 🔴 Critical |
| AS-004 | Admin | Mengupdate status pesanan tahap demi tahap | Pemesan tahu progress dokumen mereka | 🔴 Critical |
| AS-005 | Admin | Download file yang diupload pemesan | Saya bisa mencetak file yang dipesan | 🔴 Critical |
| AS-006 | Admin | Mengatur harga layanan dengan mudah | Harga selalu akurat dan update | 🟠 High |
| AS-007 | Admin | Memverifikasi bukti pembayaran manual | Pesanan hanya diproses jika sudah dibayar | 🟠 High |
| AS-008 | Admin | Melihat laporan pendapatan harian/bulanan | Saya bisa evaluasi performa bisnis | 🟠 High |
| AS-009 | Admin | Export laporan ke PDF/Excel | Data mudah dianalisis dan dilaporkan | 🟡 Medium |
| AS-010 | Admin | Mengatur jam operasional toko | Pemesan tahu kapan toko saya buka | 🟡 Medium |
| AS-011 | Admin | Membalas ulasan pemesan | Saya bisa merespons feedback dengan profesional | 🟢 Low |
| AS-012 | Admin | Toggle status toko buka/tutup mendadak | Pemesan tidak masuk saat toko sedang tutup darurat | 🟠 High |

---

## 9. Acceptance Criteria & Definition of Done

### 9.1 Acceptance Criteria — Fitur Kritis

#### AC-001: Upload File
- [ ] File berhasil diupload ke Supabase Storage dalam < 30 detik untuk file 10MB di koneksi 4G
- [ ] Aplikasi menampilkan progress upload dalam persentase
- [ ] Format file yang didukung: PDF, DOCX, JPG, JPEG, PNG
- [ ] File > 50MB ditolak dengan pesan error yang jelas
- [ ] Preview file tersedia setelah upload berhasil

#### AC-002: Kalkulasi Harga
- [ ] Harga terupdate < 500ms setelah setiap perubahan konfigurasi
- [ ] Kalkulasi 100% sesuai formula yang ditetapkan admin toko
- [ ] Harga di konfirmasi sama persis dengan yang dibayar

#### AC-003: Real-time Status Update
- [ ] Update status sampai ke sisi user dalam < 3 detik setelah admin mengubah
- [ ] Push notification diterima dalam < 5 detik
- [ ] Status di halaman daftar dan detail pesanan konsisten

#### AC-004: Autentikasi
- [ ] Login berhasil dalam < 3 detik di koneksi normal
- [ ] Sesi login aktif selama 7 hari (refresh token otomatis)
- [ ] Logout menghapus semua token dari secure storage
- [ ] User dengan role `user` tidak bisa akses halaman admin

---

### 9.2 Definition of Done (DoD)

- [ ] Semua acceptance criteria untuk fitur tersebut terpenuhi
- [ ] Unit test menutupi minimal **80% logika bisnis utama**
- [ ] Widget test untuk semua screen utama
- [ ] Tidak ada error kritis di crash reporting
- [ ] Responsif di ukuran layar 5.5" – 6.7"
- [ ] Light mode dan dark mode tampil dengan benar
- [ ] Aksesibilitas: ukuran font minimal 12sp, kontras WCAG AA
- [ ] Code review oleh minimal 1 developer lain
- [ ] RLS Supabase telah ditest untuk semua skenario akses

---

## 10. Persyaratan Non-Fungsional

### 10.1 Performa

| Metrik | Target | Keterangan |
|--------|--------|------------|
| App Launch Time | < 3 detik | Cold start pada device mid-range |
| Screen Load Time | < 1.5 detik | Waktu render halaman setelah navigasi |
| API Response Time | < 2 detik | Dari send request hingga data tampil di UI |
| Real-time Latency | < 3 detik | Update status pesanan via Supabase Realtime |
| File Upload Speed | < 30 detik | File 10MB di koneksi 4G |
| Offline Behavior | Graceful degradation | Tampilkan data cache jika tidak ada internet |
| Frame Rate | 60fps minimum | Semua animasi dan transisi layar |

### 10.2 Keamanan

| Aspek | Implementasi |
|-------|-------------|
| Autentikasi | Supabase Auth dengan JWT + refresh token + Flutter Secure Storage |
| Otorisasi | Row Level Security (RLS) di semua tabel Supabase |
| File Storage | Signed URL dengan expiry time untuk akses file |
| SSL/TLS | Semua komunikasi via HTTPS (Supabase default) |
| Input Validation | Validasi di sisi client (Flutter) dan server (Edge Functions) |
| API Key | Supabase anon key di app, service key hanya di Edge Functions |
| Data Sensitif | Nomor HP dan email tidak ditampilkan ke toko lain via RLS |
| Payment | Bukti transfer di private Storage bucket, hanya admin toko yang bisa akses |

### 10.3 Skalabilitas

- Supabase (PostgreSQL) mendukung scaling horizontal
- Indexing pada kolom yang sering diquery: `user_id`, `shop_id`, `status`, `created_at`
- Pagination pada semua daftar (maks 20 item per halaman)
- Infinite scroll dengan lazy loading
- Image compression sebelum upload

### 10.4 Aksesibilitas

- Semantic labels pada semua widget interaktif
- Touch target minimal **48×48dp** (Material Design guideline)
- Kontras warna **WCAG AA** (4.5:1 untuk teks normal, 3:1 untuk teks besar)
- Font size tidak di-hardcode, mengikuti pengaturan sistem
- Semua gambar penting memiliki `semanticLabel`

### 10.5 Kompatibilitas

| Platform | Versi Minimum | Versi Target |
|----------|---------------|--------------|
| Android | 8.0 (API 26) | 14.0 (API 35) |
| iOS | 14.0 | 17.x |
| Flutter SDK | 3.x.x | Latest stable |
| Supabase SDK | 2.x | Latest stable |

---

## 11. Alur Navigasi Aplikasi

### 11.1 Navigasi User — Bottom Navigation Bar (5 Tab)

| Tab | Ikon | Halaman | Sub-halaman |
|-----|------|---------|-------------|
| **Home** | `home_outlined` | Halaman Utama | Detail Toko, Buat Pesanan (multi-step) |
| **Pesanan** | `receipt_outlined` | Daftar Pesanan | Detail Pesanan, Tracking, Ulasan |
| **Template** | `description_outlined` | Galeri Template | Preview Template, Download |
| **Notifikasi** | `notifications_outlined` | Pusat Notifikasi | Detail Notifikasi |
| **Profil** | `person_outlined` | Profil Saya | Edit Profil, Alamat, Pengaturan |

### 11.2 Navigasi Admin — Drawer Navigation Sidebar

| Menu | Ikon | Halaman | Sub-halaman |
|------|------|---------|-------------|
| **Dashboard** | `dashboard` | Dashboard Utama | Statistik, Grafik, Pesanan Terbaru |
| **Pesanan** | `receipt_long` | Manajemen Pesanan | Detail, Update Status, Verifikasi Bayar |
| **Layanan** | `miscellaneous_services` | Manajemen Layanan | Tambah/Edit Layanan, Harga |
| **Toko** | `store` | Profil Toko | Edit Toko, Jam Operasional, Foto |
| **Laporan** | `analytics` | Laporan & Keuangan | Pendapatan, Pesanan, Export |
| **Ulasan** | `reviews` | Manajemen Ulasan | Balas Ulasan, Filter Rating |
| **Notifikasi** | `notifications` | Notifikasi Masuk | — |
| **Pengaturan** | `settings` | Pengaturan Akun | Profil Admin, Ubah Password |

### 11.3 Alur Order End-to-End

| Langkah | Aktor | Aksi | Status Pesanan |
|---------|-------|------|----------------|
| 1 | User | Buat pesanan + upload file + bayar | `pending` |
| 2 | Admin | Terima notifikasi pesanan baru | `pending` |
| 3 | Admin | Review & konfirmasi pesanan | `confirmed` |
| 4 | Admin | Mulai proses cetak | `processing` |
| 5 | Admin | Dokumen siap | `ready` |
| 6a (Pickup) | User | Ambil dokumen di toko | `delivered` |
| 6b (Delivery) | Admin | Kirim dokumen ke lokasi user | `delivered` |
| 7 | User | Konfirmasi terima + beri ulasan | `completed` |

---

## 12. Rencana Pengembangan & Milestones

### 12.1 Roadmap Pengembangan

| Fase | Nama Fase | Durasi | Deliverable Utama |
|------|-----------|--------|-------------------|
| **Phase 0** | Setup & Fondasi | 2 Minggu | Project setup Flutter, Supabase konfigurasi, Design System, Database schema, RLS |
| **Phase 1** | MVP Core | 6 Minggu | Autentikasi (User + Admin), Pembuatan pesanan end-to-end, Upload file, Kalkulasi harga, Status tracking |
| **Phase 2** | Fitur Lengkap | 4 Minggu | Payment integration, Notifikasi real-time, Template dokumen, Dashboard Admin lengkap, Laporan |
| **Phase 3** | Enhancement | 3 Minggu | Ulasan & rating, Dark mode, Manajemen alamat, Export laporan, Optimasi performa |
| **Phase 4** | Testing & Launch | 3 Minggu | UAT, Bug fixing, Submit ke Play Store & App Store |

**Total Estimasi:** ~18 Minggu

### 12.2 Prioritas Fitur (MoSCoW)

#### 🔴 Must Have (Wajib Ada)
- Autentikasi user dan admin dengan Supabase Auth
- Upload file dan konfigurasi layanan cetak
- Kalkulasi harga otomatis real-time
- Pembuatan dan tracking pesanan
- Dashboard admin dengan manajemen pesanan
- Update status pesanan real-time
- Light Mode dan Dark Mode

#### 🟠 Should Have (Sebaiknya Ada)
- Integrasi payment gateway (QRIS, e-wallet)
- Push notification via FCM
- Layanan antar ke lokasi
- Template dokumen kampus
- Laporan dan export data

#### 🟡 Could Have (Bisa Ditambahkan)
- Fitur peta untuk tampilkan lokasi toko
- Promo dan diskon dari admin toko
- Program loyalitas / poin reward
- Fitur referral (ajak teman)

#### ⚪ Won't Have (Fase Berikutnya)
- Integrasi dengan SIAKAD kampus
- Aplikasi web versi desktop
- Live chat antara user dan admin
- AR preview dokumen sebelum cetak

---

## 13. Analisis Risiko & Mitigasi

| ID | Risiko | Dampak | Probabilitas | Strategi Mitigasi |
|----|--------|--------|--------------|-------------------|
| R-001 | Koneksi internet buruk saat upload file besar | Tinggi | Tinggi | Resumable upload, kompresi file, feedback progress yang jelas |
| R-002 | Admin lambat merespons pesanan masuk | Tinggi | Sedang | SLA response 30 menit, notifikasi eskalasi ke superadmin jika melewati batas |
| R-003 | File rusak/corrupt setelah upload | Tinggi | Rendah | Validasi checksum, preview wajib sebelum konfirmasi pesanan |
| R-004 | Supabase downtime | Tinggi | Rendah | Monitoring uptime, fallback message informatif, SLA Supabase 99.9% |
| R-005 | Data bocor akibat RLS misconfiguration | Kritis | Rendah | Audit RLS berkala, penetration testing, mandatory code review untuk perubahan policy |
| R-006 | Pembayaran manual tidak terverifikasi | Sedang | Sedang | SLA verifikasi 1 jam, reminder otomatis ke admin, refund otomatis jika > 2 jam |
| R-007 | Ulasan palsu / tidak pantas | Sedang | Sedang | Filter kata-kata kasar, fitur lapor ulasan, moderasi superadmin |
| R-008 | Persaingan dengan layanan serupa | Sedang | Tinggi | Fokus UX terbaik, harga transparan, kecepatan respons layanan |

---

## 14. Metrik Keberhasilan (KPIs)

### 14.1 Metrik Produk

| Kategori | Metrik | Target 3 Bulan | Target 6 Bulan |
|----------|--------|----------------|----------------|
| Pengguna | Total User Terdaftar | 500 user | 2.000 user |
| Pengguna | Monthly Active Users (MAU) | 300 user | 1.500 user |
| Transaksi | Total Pesanan per Bulan | 500 pesanan | 3.000 pesanan |
| Transaksi | Gross Merchandise Value (GMV) | Rp 5 juta/bulan | Rp 30 juta/bulan |
| Kualitas | Rating Rata-rata Aplikasi | ≥ 4.2 ⭐ | ≥ 4.5 ⭐ |
| Kualitas | Order Completion Rate | ≥ 85% | ≥ 92% |
| Retensi | 30-day Retention Rate | ≥ 40% | ≥ 55% |
| Mitra | Jumlah Admin/Toko Aktif | 5 toko | 20 toko |

### 14.2 Metrik Teknis

| Metrik | Target |
|--------|--------|
| App Crash Rate | < 0.5% dari total sesi |
| API Error Rate | < 1% dari total request |
| App Store Rating | ≥ 4.0 ⭐ |
| Average Session Duration | ≥ 5 menit |
| Mean Time to Resolve Bug Kritis | < 24 jam |
| Coverage Unit Test | ≥ 80% |

---

## 15. Glosarium & Referensi

### 15.1 Glosarium

| Istilah | Definisi |
|---------|----------|
| **Admin / Seller** | Mitra fotokopi/percetakan lokal yang mengelola toko dan pesanan via dashboard |
| **User / Pemesan** | Mahasiswa yang menggunakan aplikasi untuk memesan layanan cetak |
| **Superadmin** | Tim internal GoPrint yang mengelola seluruh platform |
| **RLS** | Row Level Security — mekanisme keamanan PostgreSQL yang membatasi akses baris data berdasarkan identitas pengguna |
| **JWT** | JSON Web Token — token autentikasi untuk memverifikasi identitas pengguna dalam setiap request API |
| **Supabase Realtime** | Fitur Supabase yang memungkinkan subscripsi perubahan database secara live via WebSocket |
| **Edge Functions** | Serverless function di infrastruktur Supabase untuk logika server-side |
| **Riverpod / BLoC** | Library state management untuk Flutter |
| **QRIS** | Quick Response Code Indonesian Standard — standar pembayaran QR Code di Indonesia |
| **GMV** | Gross Merchandise Value — total nilai transaksi yang diproses melalui platform |
| **MAU** | Monthly Active Users — jumlah pengguna unik yang aktif dalam satu bulan |
| **FCM** | Firebase Cloud Messaging — layanan push notification dari Google |
| **DoD** | Definition of Done — kriteria yang harus dipenuhi agar sebuah fitur dianggap selesai |
| **MoSCoW** | Must Have, Should Have, Could Have, Won't Have — framework prioritasi fitur |
| **Haversine** | Formula untuk menghitung jarak antara dua titik di permukaan bola (GPS) |

### 15.2 Referensi Teknologi

| Resource | URL |
|----------|-----|
| Flutter Documentation | https://docs.flutter.dev |
| Supabase Documentation | https://supabase.com/docs |
| Supabase RLS Guide | https://supabase.com/docs/guides/auth/row-level-security |
| Material Design 3 | https://m3.material.io |
| Riverpod Documentation | https://riverpod.dev |
| go_router | https://pub.dev/packages/go_router |
| fl_chart | https://pub.dev/packages/fl_chart |
| Flutter Local Notifications | https://pub.dev/packages/flutter_local_notifications |

### 15.3 Riwayat Revisi Dokumen

| Versi | Tanggal | Penulis | Perubahan |
|-------|---------|---------|-----------|
| `1.0.0` | Mei 2026 | Tim GoPrint | Dokumen PRD awal — mencakup semua fitur MVP dan fase pengembangan |

---

<div align="center">

**GoPrint** · Print & Administrasi Kampus  
PRD v1.0.0 · Mei 2026

_Dokumen ini bersifat rahasia dan hanya untuk keperluan internal pengembangan produk._

</div>
