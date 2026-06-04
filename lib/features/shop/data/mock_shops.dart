/// Model untuk representasi data layanan toko.
class ServiceItem {
  final String name;
  final double priceStartingFrom;
  final String estimateTime;
  final String category; // 'Print', 'Jilid', 'Laminating', 'Scan', 'Fotokopi', 'Template'

  const ServiceItem({
    required this.name,
    required this.priceStartingFrom,
    required this.estimateTime,
    required this.category,
  });
}

/// Model untuk representasi ulasan pembeli toko.
class ReviewItem {
  final String name;
  final double rating;
  final String comment;
  final String date;
  final String avatarUrl;
  final List<String> reviewPhotos;

  const ReviewItem({
    required this.name,
    required this.rating,
    required this.comment,
    required this.date,
    required this.avatarUrl,
    this.reviewPhotos = const [],
  });
}

/// Model untuk jam operasional per hari.
class OperatingHour {
  final String day;
  final String hours;
  final bool isClosed;

  const OperatingHour({
    required this.day,
    required this.hours,
    required this.isClosed,
  });
}

/// Model data utama untuk Toko (Shop).
class Shop {
  final String id;
  final String name;
  final String imageUrl;
  final double rating;
  final String distance;
  final bool isOpen;
  final String description;
  final String address;
  final String phone;
  final List<ServiceItem> services;
  final List<ReviewItem> reviews;
  final List<OperatingHour> operatingHours;

  const Shop({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.distance,
    required this.isOpen,
    required this.description,
    required this.address,
    required this.phone,
    required this.services,
    required this.reviews,
    required this.operatingHours,
  });
}

/// Sumber data dummy untuk visualisasi UI Toko.
class MockShops {
  MockShops._();

  static const List<Shop> shops = [
    Shop(
      id: '1',
      name: 'Fotokopi Surya Gemilang',
      imageUrl: 'https://images.unsplash.com/photo-1585776245991-cf89dd7fc73a?q=80&w=600&auto=format&fit=crop',
      rating: 4.8,
      distance: '0.5 km',
      isOpen: true,
      description: 'Menerima jasa print dokumen harian, skripsi, jilid hard/soft cover kilat, laminating ukuran A4 s/d A3. Pelayanan cepat dengan mesin berkecepatan tinggi.',
      address: 'Jl. Kaliurang KM 5.2, Gang Sunan Giri No. 12, Sleman, DI Yogyakarta',
      phone: '0812-3456-7890',
      services: [
        ServiceItem(
          name: 'Print Dokumen A4 (Hitam Putih)',
          priceStartingFrom: 500,
          estimateTime: '5-10 menit',
          category: 'Print',
        ),
        ServiceItem(
          name: 'Print Warna A4 (High Quality)',
          priceStartingFrom: 1500,
          estimateTime: '5-10 menit',
          category: 'Print',
        ),
        ServiceItem(
          name: 'Jilid Lakban Biasa',
          priceStartingFrom: 5000,
          estimateTime: '15 menit',
          category: 'Jilid',
        ),
        ServiceItem(
          name: 'Jilid Spiral Kawat',
          priceStartingFrom: 15000,
          estimateTime: '30 menit',
          category: 'Jilid',
        ),
        ServiceItem(
          name: 'Laminating A4 (Glossy/Doff)',
          priceStartingFrom: 3000,
          estimateTime: '10 menit',
          category: 'Laminating',
        ),
        ServiceItem(
          name: 'Scan Dokumen Warna (PDF)',
          priceStartingFrom: 1000,
          estimateTime: '5 menit',
          category: 'Scan',
        ),
        ServiceItem(
          name: 'Fotokopi F4 / A4',
          priceStartingFrom: 250,
          estimateTime: '5 menit',
          category: 'Fotokopi',
        ),
      ],
      reviews: [
        ReviewItem(
          name: 'Andi Wijaya',
          rating: 5.0,
          comment: 'Hasil print sangat tajam dan pengerjaan cepat. Bisa ditunggu untuk jilid lakban. Rekomendasi banget buat mahasiswa!',
          date: '2 hari lalu',
          avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100',
        ),
        ReviewItem(
          name: 'Rina Astuti',
          rating: 4.0,
          comment: 'Tempatnya ramai kalau sore, tapi pelayanannya tetap ramah. Harga bersahabat.',
          date: '1 minggu lalu',
          avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100',
        ),
      ],
      operatingHours: [
        OperatingHour(day: 'Senin', hours: '08:00 - 21:00', isClosed: false),
        OperatingHour(day: 'Selasa', hours: '08:00 - 21:00', isClosed: false),
        OperatingHour(day: 'Rabu', hours: '08:00 - 21:00', isClosed: false),
        OperatingHour(day: 'Kamis', hours: '08:00 - 21:00', isClosed: false),
        OperatingHour(day: 'Jumat', hours: '08:00 - 21:00', isClosed: false),
        OperatingHour(day: 'Sabtu', hours: '08:00 - 17:00', isClosed: false),
        OperatingHour(day: 'Minggu', hours: 'Tutup', isClosed: true),
      ],
    ),
    Shop(
      id: '2',
      name: 'Prima Print Center',
      imageUrl: 'https://images.unsplash.com/photo-1506784983877-45594efa4cbe?q=80&w=600&auto=format&fit=crop',
      rating: 4.5,
      distance: '1.2 km',
      isOpen: true,
      description: 'Pusat cetak dokumen dan percetakan cepat. Menyediakan cetak brosur, poster, print warna laser jet kualitas tinggi, jilid softcover lem panas, laminasi doff/glossy.',
      address: 'Jl. Pandega Marta No. 8B, Sleman, DI Yogyakarta',
      phone: '0821-9876-5432',
      services: [
        ServiceItem(
          name: 'Print Warna A4 (Laser)',
          priceStartingFrom: 2000,
          estimateTime: '10 menit',
          category: 'Print',
        ),
        ServiceItem(
          name: 'Jilid Softcover Lem Panas',
          priceStartingFrom: 25000,
          estimateTime: '2 jam',
          category: 'Jilid',
        ),
        ServiceItem(
          name: 'Laminating A3',
          priceStartingFrom: 6000,
          estimateTime: '15 menit',
          category: 'Laminating',
        ),
        ServiceItem(
          name: 'Scan Buku A4 (Per Bab)',
          priceStartingFrom: 500,
          estimateTime: '15 menit',
          category: 'Scan',
        ),
        ServiceItem(
          name: 'Fotokopi F4 Bolak-Balik',
          priceStartingFrom: 400,
          estimateTime: '10 menit',
          category: 'Fotokopi',
        ),
      ],
      reviews: [
        ReviewItem(
          name: 'Bagus Pratama',
          rating: 4.5,
          comment: 'Kualitas cetak warna laser mantap sekali untuk poster tugas. Pengerjaan jilid softcover rapi dan lem kuat.',
          date: '3 hari lalu',
          avatarUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=100',
        ),
      ],
      operatingHours: [
        OperatingHour(day: 'Senin', hours: '07:30 - 22:00', isClosed: false),
        OperatingHour(day: 'Selasa', hours: '07:30 - 22:00', isClosed: false),
        OperatingHour(day: 'Rabu', hours: '07:30 - 22:00', isClosed: false),
        OperatingHour(day: 'Kamis', hours: '07:30 - 22:00', isClosed: false),
        OperatingHour(day: 'Jumat', hours: '07:30 - 22:00', isClosed: false),
        OperatingHour(day: 'Sabtu', hours: '08:00 - 20:00', isClosed: false),
        OperatingHour(day: 'Minggu', hours: '09:00 - 17:00', isClosed: false),
      ],
    ),
    Shop(
      id: '3',
      name: 'Jaya Abadi Fotokopi',
      imageUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?q=80&w=600&auto=format&fit=crop',
      rating: 4.2,
      distance: '2.1 km',
      isOpen: false,
      description: 'Melayani fotokopi eceran dan grosir, cetak dokumen PDF/Word via WhatsApp atau Flashdisk, laminating presisi tinggi, scan dokumen legalisasi.',
      address: 'Jl. Selokan Mataram No. 45, Caturtunggal, Depok, Sleman, DI Yogyakarta',
      phone: '0877-5555-1234',
      services: [
        ServiceItem(
          name: 'Print Dokumen B/W',
          priceStartingFrom: 400,
          estimateTime: '5 menit',
          category: 'Print',
        ),
        ServiceItem(
          name: 'Jilid Ring Kawat',
          priceStartingFrom: 10000,
          estimateTime: '20 menit',
          category: 'Jilid',
        ),
        ServiceItem(
          name: 'Laminating KTP/Kartu',
          priceStartingFrom: 2000,
          estimateTime: '5 menit',
          category: 'Laminating',
        ),
        ServiceItem(
          name: 'Fotokopi A4 Eceran',
          priceStartingFrom: 200,
          estimateTime: '5 menit',
          category: 'Fotokopi',
        ),
      ],
      reviews: [
        ReviewItem(
          name: 'Fajar Siddiq',
          rating: 4.0,
          comment: 'Harganya paling murah dibanding yang lain di sekitar sini. Antreannya agak panjang kalau pagi hari.',
          date: '2 minggu lalu',
          avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
        ),
      ],
      operatingHours: [
        OperatingHour(day: 'Senin', hours: '08:00 - 18:00', isClosed: false),
        OperatingHour(day: 'Selasa', hours: '08:00 - 18:00', isClosed: false),
        OperatingHour(day: 'Rabu', hours: '08:00 - 18:00', isClosed: false),
        OperatingHour(day: 'Kamis', hours: '08:00 - 18:00', isClosed: false),
        OperatingHour(day: 'Jumat', hours: '08:00 - 18:00', isClosed: false),
        OperatingHour(day: 'Sabtu', hours: 'Tutup', isClosed: true),
        OperatingHour(day: 'Minggu', hours: 'Tutup', isClosed: true),
      ],
    ),
  ];
}
