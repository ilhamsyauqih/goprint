# ✅ Task List Frontend — GoPrint

> Platform: **Flutter** · Anggota: **Amir · Ilham · Rafif**
> Hanya mencakup **UI/Frontend** — database & Supabase menyusul

---

## 👥 Ringkasan Pembagian Tugas

| Anggota | Modul Utama |
|---------|-------------|
| 🟦 **Amir** | Autentikasi · Profil · Onboarding · Notifikasi |
| 🟩 **Ilham** | Home · Template · Order Flow (Pilih Toko → Upload) |
| 🟧 **Rafif** | Tracking · Dashboard Admin · Laporan · Ulasan |
| 🟪 **Super Admin** | Dashboard Global · Manajemen Mitra & User · Payout · Pengaturan Sistem |

---

## 🟦 AMIR

### A1 · Splash Screen & Onboarding

- [x] Buat `SplashScreen` — logo + animasi Lottie + background gradasi teal
- [x] Buat `OnboardingScreen` — 3 slide (PageView), indikator dots, tombol Skip & Next
- [x] Slide 1: ilustrasi upload file
- [x] Slide 2: ilustrasi kalkulasi harga
- [x] Slide 3: ilustrasi pengantaran + tombol "Mulai Sekarang"

### A2 · Autentikasi (Login & Register)

- [x] Buat `LoginScreen` — form email + password, tombol login, link ke register
- [x] Buat `RegisterScreen` — form nama, email, password, nomor HP
- [x] Buat `ForgotPasswordScreen` — input email, kirim reset link
- [x] Komponen: `AuthTextField` (custom input field sesuai design system)
- [x] Komponen: `PrimaryButton` (gradient teal, radius 12dp)
- [x] Handling state: loading indicator saat proses login/register
- [x] Validasi form: email format, password min 8 karakter, field wajib

### A3 · Profil Pengguna

- [x] Buat `ProfileScreen` — tampil nama, foto, email, nomor HP
- [x] Buat `EditProfileScreen` — form edit nama, nomor HP, alamat kos
- [x] Komponen: `AvatarPicker` — pilih foto dari kamera/galeri
- [x] Buat `AddressListScreen` — daftar alamat tersimpan (tambah, hapus, pilih default)
- [x] Buat `AddAddressScreen` — form input alamat baru
- [x] Buat `ChangePasswordScreen` — input password lama + baru + konfirmasi
- [x] Buat `SettingsScreen` — pengaturan notifikasi, toggle tema, tentang app, logout

### A4 · Notifikasi

- [x] Buat `NotificationScreen` — daftar notifikasi (title, body, waktu, status baca)
- [x] Komponen: `NotificationCard` — card notifikasi dengan warna per tipe
- [x] Tampil badge merah di ikon notifikasi jika ada yang belum dibaca
- [x] Tombol "Tandai Semua Dibaca"
- [x] State kosong: ilustrasi + teks "Belum ada notifikasi"

---

## 🟩 ILHAM

### I1 · Layout Utama & Navigasi

- [x] Buat `MainLayout` — Bottom Navigation Bar 5 tab (Home, Pesanan, Template, Notifikasi, Profil)
- [x] Komponen: `CustomBottomNavBar` — ikon + label, aksen teal saat aktif
- [x] Setup `go_router` — definisi semua route user & admin
- [x] Buat `CustomAppBar` — gradasi teal, judul putih, back button
- [x] Implementasi Light Mode & Dark Mode (ThemeData + color scheme)

### I2 · Home Screen

- [x] Buat `HomeScreen` — layout keseluruhan dengan ScrollView
- [x] Komponen: `GreetingHeader` — sapaan nama + ikon notifikasi di App Bar
- [x] Komponen: `SearchBar` — input cari toko/layanan
- [x] Komponen: `PromoBanner` — horizontal scroll banner promo (PageView + dots)
- [x] Komponen: `ServiceCategoryGrid` — grid 2×3 ikon layanan (Print, Jilid, Laminating, Scan, Fotokopi, Template)
- [x] Komponen: `NearbyShopCard` — kartu toko (nama, rating bintang, jarak, badge buka/tutup)
- [x] Komponen: `NearbyShopList` — horizontal scroll daftar toko terdekat
- [x] Komponen: `ActiveOrderBanner` — card pesanan aktif (tampil jika ada pesanan berjalan)
- [x] Komponen: `TemplateRecommendGrid` — grid template populer

### I3 · Daftar & Detail Toko

- [x] Buat `ShopListScreen` — daftar toko dengan filter (layanan, rating, jarak)
- [x] Buat `ShopDetailScreen` — foto toko, rating, jam operasional, daftar layanan, ulasan
- [x] Komponen: `ShopInfoHeader` — header bergambar + gradient overlay + nama toko
- [x] Komponen: `ServiceMenuCard` — kartu layanan (nama, harga mulai dari, estimasi waktu)
- [x] Komponen: `OperatingHoursWidget` — tampil jam buka per hari

### I4 · Order Flow — Langkah 1 s.d. 3

- [x] Buat `SelectServiceScreen` — pilih layanan dari toko (multi-item)
- [x] Buat `UploadFileScreen` — tombol upload file, list file terupload
- [x] Komponen: `FileUploadArea` — dashed border teal, ikon upload, drag & drop hint
- [x] Komponen: `FileCard` — tampil nama file, ukuran, jumlah halaman, tombol hapus
- [x] Buat `FileConfigScreen` — konfigurasi per file (eksemplar, warna, kertas, finishing, double-side)
- [x] Komponen: `ConfigOption` — row pilihan dengan label + control (dropdown/toggle/stepper)
- [x] Komponen: `PdfPreviewWidget` — preview file PDF dalam aplikasi

### I5 · Order Flow — Langkah 4 s.d. 6

- [ ] Buat `PriceCalculatorScreen` — breakdown harga real-time per item + total
- [ ] Komponen: `PriceBreakdownCard` — baris rincian harga (label + nilai IDR)
- [ ] Buat `DeliveryPickScreen` — pilih Pickup atau Delivery + input/pilih alamat
- [ ] Buat `OrderSummaryScreen` — ringkasan pesanan lengkap sebelum submit
- [ ] Komponen: `OrderItemSummaryCard` — ringkasan per item pesanan
- [ ] Buat `PaymentScreen` — pilih metode bayar + upload bukti transfer
- [ ] Komponen: `PaymentMethodSelector` — daftar metode (QRIS, Transfer, GoPay, OVO, Dana)
- [ ] Komponen: `PaymentProofUploader` — area upload bukti transfer
- [ ] Buat `OrderSuccessScreen` — animasi sukses (Lottie) + nomor pesanan + tombol ke detail

### I6 · Template Dokumen

- [ ] Buat `TemplateListScreen` — grid template dengan filter kategori
- [ ] Komponen: `TemplateCategoryChip` — chip filter (Surat Izin, Cover, dst.)
- [ ] Komponen: `TemplateCard` — thumbnail, nama, jumlah download, rating
- [ ] Buat `TemplateDetailScreen` — preview besar, deskripsi, tombol Download (DOCX/PDF)
- [ ] State kosong: ilustrasi + teks "Template tidak ditemukan"

---

## 🟧 RAFIF

### R1 · Daftar & Tracking Pesanan (User)git 

- [ ] Buat `OrderListScreen` — tab Aktif / Selesai / Dibatalkan
- [ ] Komponen: `OrderCard` — nomor pesanan, nama toko, status badge, total, tanggal
- [ ] Komponen: `StatusBadge` — chip berwarna sesuai status (pending=abu, confirmed=biru, processing=kuning, ready=teal, completed=hijau, cancelled=merah)
- [ ] Buat `OrderDetailScreen` — detail lengkap pesanan user
- [ ] Komponen: `OrderTimeline` — stepper vertikal bergradasi teal dengan titik status
- [ ] Komponen: `OrderItemDetailCard` — thumbnail file, konfigurasi, subtotal
- [ ] Komponen: `PaymentInfoSection` — info metode bayar + status verifikasi
- [ ] Tombol Batalkan (tampil hanya saat status `pending`)
- [ ] Tombol Beri Ulasan (tampil hanya saat status `completed`)
- [ ] State kosong: ilustrasi + teks per tab

### R2 · Ulasan & Rating

- [ ] Buat `WriteReviewScreen` — form ulasan setelah pesanan selesai
- [ ] Komponen: `StarRatingSelector` — 5 bintang interaktif (tap untuk pilih)
- [ ] Komponen: `ReviewPhotoUploader` — upload maks 3 foto bukti
- [ ] Toggle anonim (switch)
- [ ] Validasi: rating wajib diisi sebelum submit

### R3 · Dashboard Admin

- [x] Buat `AdminDrawer` — sidebar navigasi admin (header bergradasi, 8 menu item)
- [x] Buat `AdminDashboardScreen` — layout utama admin
- [x] Komponen: `StatCard` — kartu statistik (total pesanan, pendapatan, menunggu, proses)
- [x] Komponen: `RevenueLineChart` — grafik pendapatan 7/30 hari (fl_chart)
- [x] Komponen: `ServiceBarChart` — grafik pesanan per layanan (fl_chart)
- [x] Komponen: `PeriodFilterChip` — chip pilihan periode (Hari Ini, 7 Hari, 30 Hari, Custom)
- [x] Komponen: `RecentOrderList` — 5 pesanan terbaru dengan status real-time

### R4 · Manajemen Pesanan (Admin)

- [x] Buat `AdminOrderListScreen` — tab filter + search + sort pesanan
- [x] Komponen: `AdminOrderCard` — kartu pesanan dengan nama pemesan, total, status badge
- [x] Buat `AdminOrderDetailScreen` — detail pesanan versi admin
- [x] Komponen: `CustomerInfoSection` — nama + tombol WhatsApp (url_launcher)
- [x] Komponen: `AdminActionButtons` — tombol aksi sesuai status pesanan
- [x] Komponen: `RejectReasonDialog` — dialog input alasan penolakan
- [x] Komponen: `SetEstimateDialog` — dialog set estimasi waktu selesai
- [x] Komponen: `PaymentVerificationSection` — tampil bukti transfer + tombol Approve/Reject
- [x] Komponen: `InternalNoteField` — field catatan internal admin

### R5 · Manajemen Layanan & Profil Toko (Admin)

- [x] Buat `AdminServiceListScreen` — daftar layanan toko + toggle aktif/nonaktif
- [x] Buat `AdminAddEditServiceScreen` — form tambah/edit layanan (semua field harga & opsi)
- [x] Komponen: `PaperTypePriceList` — form harga per jenis kertas
- [x] Komponen: `FinishingOptionList` — daftar opsi finishing dengan harga masing-masing
- [x] Buat `AdminShopProfileScreen` — form edit profil toko lengkap
- [x] Komponen: `ShopPhotoGallery` — tampil + kelola foto toko (maks 5)
- [x] Komponen: `OperatingHoursEditor` — set jam buka/tutup per hari + toggle libur
- [x] Komponen: `ShopStatusToggle` — toggle buka/tutup mendadak dengan konfirmasi dialog

### R6 · Laporan (Admin)

- [x] Buat `AdminReportScreen` — halaman laporan dengan tab Pendapatan / Pesanan
- [x] Komponen: `ReportSummaryCard` — total pendapatan, rata-rata nilai, completion rate
- [x] Komponen: `DateRangePicker` — pilih rentang tanggal custom
- [x] Komponen: `ExportButton` — tombol export ke PDF / Excel dengan loading state
- [x] Buat `AdminReviewListScreen` — daftar ulasan + filter bintang + tombol balas
- [x] Komponen: `AdminReviewCard` — kartu ulasan + kolom reply admin

---

## 🟪 SUPER ADMIN (SA)

### SA1 · Dashboard & Statistik Global (Super Admin)

- [ ] Buat `SuperAdminDashboardScreen` — ringkasan total transaksi, toko aktif, total user, & grafik pertumbuhan
- [ ] Komponen: `GlobalStatCard` — kartu statistik performa sistem (total GMV, fee platform, mitra baru)
- [ ] Komponen: `SystemRevenueChart` — grafik pendapatan platform dan gross volume mingguan/bulanan (fl_chart)
- [ ] Komponen: `WithdrawalSummaryWidget` — list ringkas request penarikan dana yang perlu segera diproses

### SA2 · Manajemen Mitra Toko (Global Shop Management)

- [ ] Buat `SuperAdminShopListScreen` — daftar semua toko mitra (Pending Approval, Aktif, Ditangguhkan)
- [ ] Buat `SuperAdminShopDetailScreen` — detail profil toko, kelengkapan berkas/dokumen legal, koordinat maps
- [ ] Komponen: `ShopApprovalActions` — tombol Aksi Approve / Reject pendaftaran mitra baru
- [ ] Komponen: `SuspendShopDialog` — dialog input alasan penangguhan toko mitra

### SA3 · Manajemen Pengguna & Hak Akses (User Management)

- [ ] Buat `SuperAdminUserListScreen` — daftar semua user terdaftar dengan search & filter role
- [ ] Buat `SuperAdminUserDetailScreen` — profil lengkap user, riwayat aktivitas, daftar toko terafiliasi
- [ ] Komponen: `RoleSelectorDialog` — dialog untuk mengubah level/role user (Customer, Admin Toko, Super Admin)
- [ ] Komponen: `BanUserDialog` — dialog pemblokiran akun dengan alasan spesifik

### SA4 · Verifikasi Penarikan Dana (Withdrawal & Payouts)

- [ ] Buat `SuperAdminPayoutListScreen` — daftar pengajuan penarikan saldo toko mitra
- [ ] Komponen: `PayoutCard` — info nominal penarikan, nama bank, nomor rekening, pemilik rekening
- [ ] Buat `SuperAdminPayoutDetailScreen` — verifikasi pencairan dana & upload bukti transfer bank
- [ ] Komponen: `PayoutStatusBadge` — status pencairan (pending=abu, processing=kuning, success=hijau, rejected=merah)

### SA5 · Pengaturan Global Aplikasi (System Settings)

- [ ] Buat `SuperAdminSettingsScreen` — konfigurasi umum platform
- [ ] Komponen: `PlatformFeeField` — field untuk mengatur besaran komisi platform (percentage fee)
- [ ] Komponen: `MaintenanceModeToggle` — switch mode pemeliharaan sistem dengan custom banner

---

## 🔧 Komponen Bersama (Shared)

> Dikerjakan bersama atau oleh siapa pun yang paling duluan butuh

- [ ] `LoadingOverlay` — overlay loading saat proses API
- [ ] `ShimmerLoader` — skeleton loading untuk list/card
- [ ] `EmptyStateWidget` — ilustrasi + teks untuk halaman kosong
- [ ] `ErrorStateWidget` — ilustrasi + teks + tombol retry
- [ ] `ConfirmDialog` — dialog konfirmasi (ya/tidak) reusable
- [ ] `SnackBarHelper` — helper tampil snackbar sukses/error
- [ ] `SectionHeader` — judul seksi dengan optional tombol "Lihat Semua"
- [ ] `GradientContainer` — wrapper gradasi teal reusable
- [ ] Setup `AppTheme` — ThemeData light + dark lengkap (colors, typography, shapes)
- [ ] Setup `AppColors` & `AppTextStyles` — konstanta warna dan teks

---

## 📊 Progress Tracker

| Modul | Amir 🟦 | Ilham 🟩 | Rafif 🟧 | Super Admin 🟪 |
|-------|---------|---------|---------|----------------|
| Onboarding & Splash | ✅ | — | — | — |
| Autentikasi | ✅ | — | — | — |
| Profil & Pengaturan | ✅ | — | — | — |
| Notifikasi (User) | ✅ | — | — | — |
| Layout & Navigasi | — | ✅ | — | — |
| Home Screen | — | ✅ | — | — |
| Toko (List & Detail) | — | ✅ | — | — |
| Order Flow (Upload & Konfigurasi) | — | ✅ | — | — |
| Order Flow (Harga & Bayar) | — | ⬜ | — | — |
| Template Dokumen | — | ⬜ | — | — |
| Tracking Pesanan (User) | — | — | ⬜ | — |
| Ulasan & Rating | — | — | ⬜ | — |
| Dashboard Admin | — | — | ✅ | — |
| Manajemen Pesanan Admin | — | — | ✅ | — |
| Manajemen Layanan & Toko Admin | — | — | ✅ | — |
| Laporan Admin | — | — | ✅ | — |
| Dashboard Global (Super Admin) | — | — | — | ⬜ |
| Manajemen Mitra Toko | — | — | — | ⬜ |
| Manajemen User | — | — | — | ⬜ |
| Verifikasi Payout / Withdrawal | — | — | — | ⬜ |
| Pengaturan Global Aplikasi | — | — | — | ⬜ |

> ⬜ Belum dimulai · 🟨 Sedang dikerjakan · ✅ Selesai

---

*GoPrint · Frontend Task List v1.0 · Mei 2026*
