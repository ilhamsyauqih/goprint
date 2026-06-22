/// Model data untuk template dokumen kampus.
/// Sesuai schema PRD tabel `templates`.
class TemplateItem {
  final String id;
  final String name;
  final String category; // 'Surat Izin', 'Cover', 'Daftar Pustaka', 'Proposal', 'Abstrak', 'Berita Acara'
  final String description;
  final String fileUrl;
  final String thumbnailUrl;
  final int downloadCount;
  final double rating;
  final bool isActive;
  final String createdAt;

  const TemplateItem({
    required this.id,
    required this.name,
    required this.category,
    required this.description,
    required this.fileUrl,
    required this.thumbnailUrl,
    required this.downloadCount,
    required this.rating,
    this.isActive = true,
    required this.createdAt,
  });
}

/// Sumber data dummy untuk visualisasi UI Template.
class MockTemplates {
  MockTemplates._();

  /// Semua kategori yang tersedia (termasuk 'Semua' sebagai opsi pertama).
  static const List<String> categories = [
    'Semua',
    'Surat Izin',
    'Cover',
    'Daftar Pustaka',
    'Proposal',
    'Abstrak',
    'Berita Acara',
  ];

  static const List<TemplateItem> templates = [
    // ─── Surat Izin ───────────────────────────────────────────────────
    TemplateItem(
      id: 'tpl-001',
      name: 'Surat Izin Tidak Masuk Kuliah',
      category: 'Surat Izin',
      description:
          'Template surat izin tidak masuk kuliah yang formal dan sopan. '
          'Cocok untuk keperluan akademik sehari-hari. Format surat resmi '
          'sesuai tata naskah dinas universitas, dilengkapi kolom tanda tangan '
          'dan keterangan alasan.',
      fileUrl: 'https://example.com/files/surat-izin-kuliah.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1586281380349-632531db7ed4?w=400&fit=crop',
      downloadCount: 1243,
      rating: 4.7,
      createdAt: '2026-01-10',
    ),
    TemplateItem(
      id: 'tpl-002',
      name: 'Surat Permohonan Izin Kegiatan',
      category: 'Surat Izin',
      description:
          'Template surat permohonan izin kegiatan mahasiswa kepada dekan '
          'atau pimpinan universitas. Mencakup kolom nama kegiatan, waktu, '
          'tempat, dan penanggung jawab kegiatan.',
      fileUrl: 'https://example.com/files/surat-izin-kegiatan.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1450101499163-c8848c66ca85?w=400&fit=crop',
      downloadCount: 876,
      rating: 4.5,
      createdAt: '2026-01-15',
    ),
    TemplateItem(
      id: 'tpl-003',
      name: 'Surat Keterangan Mahasiswa Aktif',
      category: 'Surat Izin',
      description:
          'Template surat keterangan sebagai mahasiswa aktif yang biasa '
          'diperlukan untuk keperluan beasiswa, KPR, atau kebutuhan administratif '
          'lainnya. Sudah sesuai format resmi institusi.',
      fileUrl: 'https://example.com/files/surat-ket-mahasiswa.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400&fit=crop',
      downloadCount: 562,
      rating: 4.3,
      createdAt: '2026-02-01',
    ),

    // ─── Cover ────────────────────────────────────────────────────────
    TemplateItem(
      id: 'tpl-004',
      name: 'Cover Laporan Praktikum',
      category: 'Cover',
      description:
          'Template cover laporan praktikum yang bersih dan profesional. '
          'Tersedia layout lengkap dengan logo universitas (placeholder), '
          'nama mata kuliah, nama mahasiswa, NIM, program studi, dan tahun ajaran.',
      fileUrl: 'https://example.com/files/cover-laporan-praktikum.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1532094349884-543bc11b234d?w=400&fit=crop',
      downloadCount: 3421,
      rating: 4.9,
      createdAt: '2026-01-05',
    ),
    TemplateItem(
      id: 'tpl-005',
      name: 'Cover Skripsi / Tugas Akhir',
      category: 'Cover',
      description:
          'Template cover skripsi sesuai standar tata naskah akademik. '
          'Format resmi dengan layout judul, nama penyusun, NIM, logo kampus, '
          'dan keterangan program studi serta tahun. Mendukung Arial/Times New Roman.',
      fileUrl: 'https://example.com/files/cover-skripsi.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=400&fit=crop',
      downloadCount: 5102,
      rating: 4.8,
      createdAt: '2026-01-03',
    ),
    TemplateItem(
      id: 'tpl-006',
      name: 'Cover Laporan KKN / PKL',
      category: 'Cover',
      description:
          'Template cover laporan Kuliah Kerja Nyata (KKN) dan Praktik Kerja '
          'Lapangan (PKL). Dilengkapi kolom institusi tujuan, lokasi penempatan, '
          'dan periode kegiatan.',
      fileUrl: 'https://example.com/files/cover-kkn-pkl.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1517048676732-d65bc937f952?w=400&fit=crop',
      downloadCount: 2150,
      rating: 4.6,
      createdAt: '2026-01-08',
    ),

    // ─── Daftar Pustaka ───────────────────────────────────────────────
    TemplateItem(
      id: 'tpl-007',
      name: 'Format Daftar Pustaka APA 7th Edition',
      category: 'Daftar Pustaka',
      description:
          'Template daftar pustaka format APA edisi ke-7 (terbaru). Berisi '
          'contoh referensi untuk buku, jurnal, artikel online, skripsi, '
          'dan sumber lain sesuai panduan American Psychological Association.',
      fileUrl: 'https://example.com/files/daftar-pustaka-apa.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400&fit=crop',
      downloadCount: 981,
      rating: 4.4,
      createdAt: '2026-01-20',
    ),
    TemplateItem(
      id: 'tpl-008',
      name: 'Format Daftar Pustaka IEEE',
      category: 'Daftar Pustaka',
      description:
          'Template daftar pustaka standar IEEE untuk jurnal teknik dan '
          'konferensi ilmiah. Cocok untuk mahasiswa teknik, informatika, dan '
          'ilmu komputer.',
      fileUrl: 'https://example.com/files/daftar-pustaka-ieee.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=400&fit=crop',
      downloadCount: 723,
      rating: 4.2,
      createdAt: '2026-02-05',
    ),

    // ─── Proposal ─────────────────────────────────────────────────────
    TemplateItem(
      id: 'tpl-009',
      name: 'Proposal Penelitian Skripsi',
      category: 'Proposal',
      description:
          'Template proposal penelitian skripsi yang lengkap mencakup: '
          'latar belakang, rumusan masalah, tujuan penelitian, tinjauan pustaka, '
          'metodologi, jadwal penelitian, dan daftar pustaka. Siap pakai untuk '
          'seminar proposal.',
      fileUrl: 'https://example.com/files/proposal-penelitian.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400&fit=crop',
      downloadCount: 2087,
      rating: 4.7,
      createdAt: '2026-01-12',
    ),
    TemplateItem(
      id: 'tpl-010',
      name: 'Proposal Kegiatan Organisasi',
      category: 'Proposal',
      description:
          'Template proposal kegiatan untuk UKM atau organisasi kemahasiswaan. '
          'Mencakup latar belakang kegiatan, nama dan tema, sasaran peserta, '
          'susunan acara, rencana anggaran biaya (RAB), dan lembar pengesahan.',
      fileUrl: 'https://example.com/files/proposal-kegiatan.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1515162816999-a0c47dc192f7?w=400&fit=crop',
      downloadCount: 1456,
      rating: 4.5,
      createdAt: '2026-01-18',
    ),

    // ─── Abstrak ──────────────────────────────────────────────────────
    TemplateItem(
      id: 'tpl-011',
      name: 'Abstrak Skripsi (Bahasa Indonesia)',
      category: 'Abstrak',
      description:
          'Template abstrak skripsi dalam Bahasa Indonesia sesuai standar '
          'akademik. Memuat panduan penulisan judul, nama penulis, kata kunci, '
          'dan isi abstrak maksimal 250 kata. Sudah termasuk contoh yang dapat '
          'langsung dimodifikasi.',
      fileUrl: 'https://example.com/files/abstrak-skripsi-id.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1455390582262-044cdead27d8?w=400&fit=crop',
      downloadCount: 1832,
      rating: 4.6,
      createdAt: '2026-01-22',
    ),
    TemplateItem(
      id: 'tpl-012',
      name: 'Abstract Skripsi (English)',
      category: 'Abstrak',
      description:
          'Template abstract for thesis in English. Includes guidelines for '
          'writing the title, author name, keywords (max 5), and abstract body '
          '(max 250 words). Compatible with international journal format.',
      fileUrl: 'https://example.com/files/abstract-skripsi-en.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1555099962-4199c345e5dd?w=400&fit=crop',
      downloadCount: 994,
      rating: 4.3,
      createdAt: '2026-02-10',
    ),

    // ─── Berita Acara ─────────────────────────────────────────────────
    TemplateItem(
      id: 'tpl-013',
      name: 'Berita Acara Rapat Organisasi',
      category: 'Berita Acara',
      description:
          'Template berita acara rapat resmi untuk organisasi atau UKM kampus. '
          'Mencakup kolom: hari/tanggal, tempat, agenda, peserta hadir, hasil '
          'keputusan, dan tanda tangan pimpinan rapat beserta notulen.',
      fileUrl: 'https://example.com/files/berita-acara-rapat.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1573164713988-8665fc963095?w=400&fit=crop',
      downloadCount: 643,
      rating: 4.4,
      createdAt: '2026-02-15',
    ),
    TemplateItem(
      id: 'tpl-014',
      name: 'Berita Acara Serah Terima Dokumen',
      category: 'Berita Acara',
      description:
          'Template berita acara serah terima dokumen atau barang secara resmi. '
          'Digunakan untuk keperluan administrasi kampus, serah terima jabatan, '
          'maupun penyerahan hasil kerja magang/PKL.',
      fileUrl: 'https://example.com/files/berita-acara-serah-terima.docx',
      thumbnailUrl:
          'https://images.unsplash.com/photo-1578574577315-3fbeb0cecdc2?w=400&fit=crop',
      downloadCount: 412,
      rating: 4.2,
      createdAt: '2026-02-20',
    ),
  ];

  /// Memformat jumlah download menjadi string yang mudah dibaca (e.g., 1.2k).
  static String formatDownloadCount(int count) {
    if (count >= 1000) {
      final double k = count / 1000;
      return '${k.toStringAsFixed(k.truncateToDouble() == k ? 0 : 1)}k';
    }
    return count.toString();
  }
}
