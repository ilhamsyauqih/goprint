class OrderTimelineEvent {
  final String status;
  final String title;
  final String description;
  final DateTime? timestamp;

  OrderTimelineEvent({
    required this.status,
    required this.title,
    this.description = '',
    this.timestamp,
  });
}

class OrderItem {
  final String fileName;
  final String fileSize;
  final int pages;
  final int copies;
  final List<String> configuration;
  final double subtotal;

  OrderItem({
    required this.fileName,
    required this.fileSize,
    required this.pages,
    required this.copies,
    required this.configuration,
    required this.subtotal,
  });
}

class Order {
  final String id;
  final String orderNumber;
  final String shopName;
  final String shopAddress;
  String status;
  final double totalPrice;
  final DateTime date;
  final List<OrderItem> items;
  final String paymentMethod;
  final bool isPaymentVerified;
  final List<OrderTimelineEvent> timeline;
  final String deliveryType;
  final String? deliveryAddress;

  Order({
    required this.id,
    required this.orderNumber,
    required this.shopName,
    required this.shopAddress,
    required this.status,
    required this.totalPrice,
    required this.date,
    required this.items,
    required this.paymentMethod,
    required this.isPaymentVerified,
    required this.timeline,
    required this.deliveryType,
    this.deliveryAddress,
  });

  // Simple copyWith to simulate cancellation/updates
  Order copyWith({
    String? status,
    List<OrderTimelineEvent>? timeline,
  }) {
    return Order(
      id: id,
      orderNumber: orderNumber,
      shopName: shopName,
      shopAddress: shopAddress,
      status: status ?? this.status,
      totalPrice: totalPrice,
      date: date,
      items: items,
      paymentMethod: paymentMethod,
      isPaymentVerified: isPaymentVerified,
      timeline: timeline ?? this.timeline,
      deliveryType: deliveryType,
      deliveryAddress: deliveryAddress,
    );
  }
}

// Generate Realistic Mock Data
List<Order> getMockOrders() {
  final now = DateTime.now();
  
  return [
    // 1. Pending Order (Active tab)
    Order(
      id: 'ord_1',
      orderNumber: 'GP-20260603-0001',
      shopName: 'Ganesha Digital Print & Photocopy',
      shopAddress: 'Jl. Dipati Ukur No. 45, Bandung',
      status: 'pending',
      totalPrice: 48000,
      date: now.subtract(const Duration(minutes: 15)),
      paymentMethod: 'QRIS (Gopay)',
      isPaymentVerified: false,
      deliveryType: 'Ambil Sendiri (Pickup)',
      timeline: [
        OrderTimelineEvent(
          status: 'pending',
          title: 'Pesanan Dibuat',
          description: 'Pesanan Anda telah berhasil dibuat dan menunggu pembayaran diverifikasi.',
          timestamp: now.subtract(const Duration(minutes: 15)),
        ),
      ],
      items: [
        OrderItem(
          fileName: 'Tugas_Akhir_Revisi_Final.pdf',
          fileSize: '4.8 MB',
          pages: 60,
          copies: 1,
          configuration: ['A4', 'Hitam Putih', 'Double-Sided', 'Jilid Spiral Plastik'],
          subtotal: 35000,
        ),
        OrderItem(
          fileName: 'Lampiran_Data_Kuesioner.pdf',
          fileSize: '1.2 MB',
          pages: 26,
          copies: 1,
          configuration: ['A4', 'Warna', 'Single-Sided', 'Tanpa Jilid'],
          subtotal: 13000,
        ),
      ],
    ),
    // 2. Confirmed Order (Active tab)
    Order(
      id: 'ord_2',
      orderNumber: 'GP-20260603-0002',
      shopName: 'MultiPrint Margonda',
      shopAddress: 'Jl. Margonda Raya No. 12, Depok',
      status: 'confirmed',
      totalPrice: 27500,
      date: now.subtract(const Duration(hours: 1)),
      paymentMethod: 'Transfer Bank (BCA)',
      isPaymentVerified: true,
      deliveryType: 'Kirim Kurir (Delivery)',
      deliveryAddress: 'Kost Orange Kamar 12, Gang H. Amat, Beji, Depok',
      timeline: [
        OrderTimelineEvent(
          status: 'pending',
          title: 'Pesanan Dibuat',
          description: 'Pesanan Anda telah berhasil dibuat.',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 10)),
        ),
        OrderTimelineEvent(
          status: 'confirmed',
          title: 'Pembayaran Diverifikasi',
          description: 'Pembayaran Anda telah dikonfirmasi oleh Admin. Menunggu antrean cetak.',
          timestamp: now.subtract(const Duration(hours: 1)),
        ),
      ],
      items: [
        OrderItem(
          fileName: 'Laporan_PKL_Rafif.pdf',
          fileSize: '3.2 MB',
          pages: 35,
          copies: 2,
          configuration: ['A4', 'Hitam Putih', 'Single-Sided', 'Jilid Lakban'],
          subtotal: 27500,
        ),
      ],
    ),
    // 3. Processing Order (Active tab)
    Order(
      id: 'ord_3',
      orderNumber: 'GP-20260603-0003',
      shopName: 'Jaya Baru Printing & Photocopy',
      shopAddress: 'Jl. Kaliurang KM 5.6, Yogyakarta',
      status: 'processing',
      totalPrice: 85000,
      date: now.subtract(const Duration(hours: 2)),
      paymentMethod: 'QRIS (Dana)',
      isPaymentVerified: true,
      deliveryType: 'Ambil Sendiri (Pickup)',
      timeline: [
        OrderTimelineEvent(
          status: 'pending',
          title: 'Pesanan Dibuat',
          description: 'Pesanan Anda telah berhasil dibuat.',
          timestamp: now.subtract(const Duration(hours: 2, minutes: 20)),
        ),
        OrderTimelineEvent(
          status: 'confirmed',
          title: 'Pembayaran Diverifikasi',
          description: 'Pembayaran Anda telah diverifikasi otomatis.',
          timestamp: now.subtract(const Duration(hours: 2, minutes: 15)),
        ),
        OrderTimelineEvent(
          status: 'processing',
          title: 'Sedang Dicetak',
          description: 'Dokumen sedang dalam proses cetak & finishing oleh operator.',
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
      ],
      items: [
        OrderItem(
          fileName: 'Modul_Pembelajaran_Matematika.pdf',
          fileSize: '12.4 MB',
          pages: 150,
          copies: 1,
          configuration: ['A4', 'Campuran (Warna & HP)', 'Double-Sided', 'Jilid Hardcover'],
          subtotal: 85000,
        ),
      ],
    ),
    // 4. Ready Order (Active tab)
    Order(
      id: 'ord_4',
      orderNumber: 'GP-20260603-0004',
      shopName: 'GoPrint Express Bendungan Hilir',
      shopAddress: 'Jl. Bendungan Hilir No. 80, Jakarta Pusat',
      status: 'ready',
      totalPrice: 15000,
      date: now.subtract(const Duration(hours: 4)),
      paymentMethod: 'OVO',
      isPaymentVerified: true,
      deliveryType: 'Ambil Sendiri (Pickup)',
      timeline: [
        OrderTimelineEvent(
          status: 'pending',
          title: 'Pesanan Dibuat',
          description: 'Pesanan Anda telah berhasil dibuat.',
          timestamp: now.subtract(const Duration(hours: 4, minutes: 40)),
        ),
        OrderTimelineEvent(
          status: 'confirmed',
          title: 'Pembayaran Diverifikasi',
          description: 'Pembayaran Anda telah diverifikasi.',
          timestamp: now.subtract(const Duration(hours: 4, minutes: 35)),
        ),
        OrderTimelineEvent(
          status: 'processing',
          title: 'Sedang Dicetak',
          description: 'Dokumen sedang dicetak.',
          timestamp: now.subtract(const Duration(hours: 4, minutes: 10)),
        ),
        OrderTimelineEvent(
          status: 'ready',
          title: 'Siap Diambil',
          description: 'Dokumen selesai dicetak dan siap diambil di toko. Silakan tunjukkan kode QR/nomor pesanan.',
          timestamp: now.subtract(const Duration(hours: 4)),
        ),
      ],
      items: [
        OrderItem(
          fileName: 'CV_Amir_2026.pdf',
          fileSize: '850 KB',
          pages: 2,
          copies: 10,
          configuration: ['A4', 'Full Warna (Premium)', 'Single-Sided', 'Tanpa Jilid'],
          subtotal: 15000,
        ),
      ],
    ),
    // 5. Completed Order (Completed tab)
    Order(
      id: 'ord_5',
      orderNumber: 'GP-20260602-0010',
      shopName: 'Ganesha Digital Print & Photocopy',
      shopAddress: 'Jl. Dipati Ukur No. 45, Bandung',
      status: 'completed',
      totalPrice: 19500,
      date: now.subtract(const Duration(days: 1)),
      paymentMethod: 'QRIS (ShopeePay)',
      isPaymentVerified: true,
      deliveryType: 'Ambil Sendiri (Pickup)',
      timeline: [
        OrderTimelineEvent(
          status: 'pending',
          title: 'Pesanan Dibuat',
          timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        ),
        OrderTimelineEvent(
          status: 'confirmed',
          title: 'Pembayaran Diverifikasi',
          timestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 55)),
        ),
        OrderTimelineEvent(
          status: 'processing',
          title: 'Sedang Dicetak',
          timestamp: now.subtract(const Duration(days: 1, hours: 1, minutes: 30)),
        ),
        OrderTimelineEvent(
          status: 'ready',
          title: 'Siap Diambil',
          timestamp: now.subtract(const Duration(days: 1, hours: 1)),
        ),
        OrderTimelineEvent(
          status: 'completed',
          title: 'Selesai',
          description: 'Pesanan telah diambil oleh pelanggan. Terima kasih telah menggunakan GoPrint!',
          timestamp: now.subtract(const Duration(days: 1)),
        ),
      ],
      items: [
        OrderItem(
          fileName: 'Printout_Slide_Kuliah_Pertemuan5.pdf',
          fileSize: '2.5 MB',
          pages: 15,
          copies: 3,
          configuration: ['A4', 'Hitam Putih', 'Double-Sided', 'Jilid Steples'],
          subtotal: 19500,
        ),
      ],
    ),
    // 6. Cancelled Order (Cancelled tab)
    Order(
      id: 'ord_6',
      orderNumber: 'GP-20260601-0024',
      shopName: 'Jaya Baru Printing & Photocopy',
      shopAddress: 'Jl. Kaliurang KM 5.6, Yogyakarta',
      status: 'cancelled',
      totalPrice: 32000,
      date: now.subtract(const Duration(days: 2)),
      paymentMethod: 'Transfer Bank (BCA)',
      isPaymentVerified: false,
      deliveryType: 'Kirim Kurir (Delivery)',
      deliveryAddress: 'Kost Asri No 4, Pogung Baru, Yogyakarta',
      timeline: [
        OrderTimelineEvent(
          status: 'pending',
          title: 'Pesanan Dibuat',
          timestamp: now.subtract(const Duration(days: 2, hours: 3)),
        ),
        OrderTimelineEvent(
          status: 'cancelled',
          title: 'Dibatalkan',
          description: 'Pesanan dibatalkan oleh pengguna.',
          timestamp: now.subtract(const Duration(days: 2, hours: 2, minutes: 45)),
        ),
      ],
      items: [
        OrderItem(
          fileName: 'Draf_Proposal_Skripsi.pdf',
          fileSize: '1.8 MB',
          pages: 32,
          copies: 1,
          configuration: ['A4', 'Hitam Putih', 'Single-Sided', 'Jilid Mika'],
          subtotal: 22000,
        ),
      ],
    ),
  ];
}
