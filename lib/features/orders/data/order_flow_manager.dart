import '../../shop/data/mock_shops.dart';

/// Model data berkas yang diunggah oleh pengguna beserta konfigurasi cetaknya.
class UploadedFile {
  UploadedFile({
    required this.id,
    required this.name,
    required this.size,
    required this.pageCount,
    this.copies = 1,
    this.colorMode = 'Hitam Putih',
    this.paperSize = 'A4',
    this.paperType = 'HVS 70g',
    this.doubleSide = false,
    this.finishing = 'Tanpa Jilid',
  });

  final String id;
  final String name;
  final String size;
  final int pageCount;

  // Konfigurasi print per file
  int copies;
  String colorMode; // 'Hitam Putih' | 'Warna'
  String paperSize; // 'A4' | 'F4' | 'A3'
  String paperType; // 'HVS 70g' | 'HVS 80g' | 'Art Paper'
  bool doubleSide;  // true (Duplex bolak-balik) | false
  String finishing; // 'Tanpa Jilid' | 'Jilid Lakban' | 'Jilid Spiral'

  // Membuat salinan objek dengan nilai baru jika diperlukan
  UploadedFile copyWith({
    String? id,
    String? name,
    String? size,
    int? pageCount,
    int? copies,
    String? colorMode,
    String? paperSize,
    String? paperType,
    bool? doubleSide,
    String? finishing,
  }) {
    return UploadedFile(
      id: id ?? this.id,
      name: name ?? this.name,
      size: size ?? this.size,
      pageCount: pageCount ?? this.pageCount,
      copies: copies ?? this.copies,
      colorMode: colorMode ?? this.colorMode,
      paperSize: paperSize ?? this.paperSize,
      paperType: paperType ?? this.paperType,
      doubleSide: doubleSide ?? this.doubleSide,
      finishing: finishing ?? this.finishing,
    );
  }
}

/// Singleton Manager untuk menyimpan state alur pemesanan (Order Flow).
class OrderFlowManager {
  // Private constructor
  OrderFlowManager._();

  // Singleton instance
  static final OrderFlowManager instance = OrderFlowManager._();

  // State pesanan aktif
  Shop? selectedShop;
  final List<ServiceItem> selectedServices = [];
  final List<UploadedFile> uploadedFiles = [];

  // Delivery & Pickup State
  String deliveryType = 'pickup'; // 'pickup' | 'delivery'
  String? deliveryAddress;
  int deliveryFee = 0;

  // Payment State
  String? paymentMethod;
  String? paymentProofPath;
  String? orderNumber;

  /// Menyetel toko terpilih dan mengosongkan pilihan sebelumnya
  void selectShop(Shop shop) {
    if (selectedShop?.id != shop.id) {
      clear();
      selectedShop = shop;
    }
  }

  /// Menambah atau menghapus layanan dalam pilihan
  void toggleService(ServiceItem service) {
    final exists = selectedServices.any((s) => s.name == service.name);
    if (exists) {
      selectedServices.removeWhere((s) => s.name == service.name);
    } else {
      selectedServices.add(service);
    }
  }

  /// Menghitung subtotal untuk satu berkas terunggah berdasarkan konfigurasi
  int getFileSubtotal(UploadedFile file) {
    int basePricePerPage = file.colorMode == 'Warna' ? 1500 : 500;
    int paperTypeFeePerPage = 0;
    if (file.paperType == 'HVS 80g') {
      paperTypeFeePerPage = 200;
    } else if (file.paperType == 'Art Paper') {
      paperTypeFeePerPage = 1000;
    }

    int finishingFee = 0;
    if (file.finishing == 'Jilid Lakban' || file.finishing == 'Jilid Lakban Biasa') {
      finishingFee = 5000;
    } else if (file.finishing == 'Jilid Spiral' || file.finishing == 'Jilid Spiral Kawat') {
      finishingFee = 15000;
    }

    // Subtotal = ((pages * printPrice) + (pages * paperTypeFee)) * copies + (finishingFee * copies)
    int pageCost = (file.pageCount * basePricePerPage) + (file.pageCount * paperTypeFeePerPage);
    int fileSubtotal = (pageCost * file.copies) + (finishingFee * file.copies);
    return fileSubtotal;
  }

  /// Menghitung total harga semua berkas
  int get itemSubtotal {
    int sum = 0;
    for (var f in uploadedFiles) {
      sum += getFileSubtotal(f);
    }
    return sum;
  }

  /// Menghitung total harga keseluruhan termasuk ongkos kirim
  int get totalFee {
    return itemSubtotal + (deliveryType == 'delivery' ? deliveryFee : 0);
  }

  /// Menghasilkan nomor pesanan secara acak dengan format DOC-YYYYMMDD-XXXX
  void generateOrderNumber() {
    final now = DateTime.now();
    final dateStr = "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";
    final randomDigits = (now.millisecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    orderNumber = "DOC-$dateStr-$randomDigits";
  }

  /// Menghapus semua data sesi pemesanan
  void clear() {
    selectedShop = null;
    selectedServices.clear();
    uploadedFiles.clear();
    deliveryType = 'pickup';
    deliveryAddress = null;
    deliveryFee = 0;
    paymentMethod = null;
    paymentProofPath = null;
    orderNumber = null;
  }

  /// Menambahkan berkas tiruan untuk pengujian UI
  void addMockFile(String name, String size, int pageCount) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    uploadedFiles.add(
      UploadedFile(
        id: id,
        name: name,
        size: size,
        pageCount: pageCount,
      ),
    );
  }

  /// Menghapus berkas berdasarkan ID
  void removeFile(String id) {
    uploadedFiles.removeWhere((f) => f.id == id);
  }
}
