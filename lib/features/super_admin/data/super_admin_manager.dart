import 'package:flutter/material.dart';
import '../../shop/data/mock_shops.dart';

/// Model untuk pengajuan penarikan dana (Payout Request)
class PayoutRequest {
  final String id;
  final String shopId;
  final String shopName;
  final String bankName;
  final String accountNumber;
  final String accountHolderName;
  final int amount;
  final String requestDate;
  final String status; // 'pending' | 'processing' | 'success' | 'rejected'
  final String? transferProof;
  final String? rejectReason;

  const PayoutRequest({
    required this.id,
    required this.shopId,
    required this.shopName,
    required this.bankName,
    required this.accountNumber,
    required this.accountHolderName,
    required this.amount,
    required this.requestDate,
    required this.status,
    this.transferProof,
    this.rejectReason,
  });

  PayoutRequest copyWith({
    String? id,
    String? shopId,
    String? shopName,
    String? bankName,
    String? accountNumber,
    String? accountHolderName,
    int? amount,
    String? requestDate,
    String? status,
    String? transferProof,
    String? rejectReason,
  }) {
    return PayoutRequest(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      shopName: shopName ?? this.shopName,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      amount: amount ?? this.amount,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      transferProof: transferProof ?? this.transferProof,
      rejectReason: rejectReason ?? this.rejectReason,
    );
  }
}

/// Model untuk data Pengguna secara global
class SuperAdminUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'Customer' | 'Admin Toko' | 'Super Admin'
  final String status; // 'Active' | 'Banned'
  final String registeredDate;

  const SuperAdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.registeredDate,
  });

  SuperAdminUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? status,
    String? registeredDate,
  }) {
    return SuperAdminUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      registeredDate: registeredDate ?? this.registeredDate,
    );
  }
}

/// Model untuk konfigurasi sistem global
class SystemConfig {
  final double platformFee; // persentase fee, misal 10.0 (10%)
  final bool isMaintenance;
  final String maintenanceMessage;

  const SystemConfig({
    required this.platformFee,
    required this.isMaintenance,
    required this.maintenanceMessage,
  });

  SystemConfig copyWith({
    double? platformFee,
    bool? isMaintenance,
    String? maintenanceMessage,
  }) {
    return SystemConfig(
      platformFee: platformFee ?? this.platformFee,
      isMaintenance: isMaintenance ?? this.isMaintenance,
      maintenanceMessage: maintenanceMessage ?? this.maintenanceMessage,
    );
  }
}

/// Singleton State Manager untuk mengelola seluruh data & logika in-memory Super Admin.
class SuperAdminManager extends ChangeNotifier {
  SuperAdminManager._();

  static final SuperAdminManager instance = SuperAdminManager._();

  // 1. Data Payout Requests
  final List<PayoutRequest> _payouts = [
    const PayoutRequest(
      id: 'PO-1001',
      shopId: '1',
      shopName: 'Fotokopi Surya Gemilang',
      bankName: 'Bank Central Asia (BCA)',
      accountNumber: '8220194881',
      accountHolderName: 'Surya Gemilang',
      amount: 450000,
      requestDate: '03 Juni 2026',
      status: 'pending',
    ),
    const PayoutRequest(
      id: 'PO-1002',
      shopId: '2',
      shopName: 'Prima Print Center',
      bankName: 'Bank Mandiri',
      accountNumber: '1370019284729',
      accountHolderName: 'Prima Printing CV',
      amount: 1200000,
      requestDate: '04 Juni 2026',
      status: 'processing',
    ),
    const PayoutRequest(
      id: 'PO-1003',
      shopId: '1',
      shopName: 'Fotokopi Surya Gemilang',
      bankName: 'Bank Central Asia (BCA)',
      accountNumber: '8220194881',
      accountHolderName: 'Surya Gemilang',
      amount: 850000,
      requestDate: '28 Mei 2026',
      status: 'success',
      transferProof: 'https://images.unsplash.com/photo-1554224155-8d04cb21cd6c?w=400',
    ),
    const PayoutRequest(
      id: 'PO-1004',
      shopId: '3',
      shopName: 'Jaya Abadi Fotokopi',
      bankName: 'Bank Rakyat Indonesia (BRI)',
      accountNumber: '034101928374829',
      accountHolderName: 'Jaya Abadi Toko',
      amount: 320000,
      requestDate: '15 Mei 2026',
      status: 'rejected',
      rejectReason: 'Nomor rekening tidak valid / nama tidak sesuai berkas.',
    ),
  ];

  List<PayoutRequest> get payouts => List.unmodifiable(_payouts);

  // 2. Data Pengguna Global (Users)
  final List<SuperAdminUser> _users = [
    const SuperAdminUser(
      id: 'USR-001',
      name: 'Amir Suryaman',
      email: 'amir.suryaman@student.ui.ac.id',
      phone: '0812-3456-7890',
      role: 'Customer',
      status: 'Active',
      registeredDate: '10 Januari 2026',
    ),
    const SuperAdminUser(
      id: 'USR-002',
      name: 'Surya Gemilang (Admin Toko)',
      email: 'surya.gemilang@gmail.com',
      phone: '0812-3456-7890',
      role: 'Admin Toko',
      status: 'Active',
      registeredDate: '15 Januari 2026',
    ),
    const SuperAdminUser(
      id: 'USR-003',
      name: 'Rafif Hidayat (Super Admin)',
      email: 'rafif.superadmin@goprint.id',
      phone: '0857-9999-1111',
      role: 'Super Admin',
      status: 'Active',
      registeredDate: '01 Januari 2026',
    ),
    const SuperAdminUser(
      id: 'USR-004',
      name: 'Spam User',
      email: 'spam.junk@email.com',
      phone: '0899-2222-3333',
      role: 'Customer',
      status: 'Banned',
      registeredDate: '01 Mei 2026',
    ),
  ];

  List<SuperAdminUser> get users => List.unmodifiable(_users);

  // 3. Konfigurasi Sistem
  SystemConfig _config = const SystemConfig(
    platformFee: 10.0,
    isMaintenance: false,
    maintenanceMessage: 'Mohon maaf, GoPrint sedang dalam pemeliharaan sistem rutin hingga pukul 03:00 WIB.',
  );

  SystemConfig get config => _config;

  // 4. Operasi Aksi Mitra Toko (Menyetujui & Menangguhkan)
  void approveShop(String shopId) {
    final index = MockShops.shops.indexWhere((s) => s.id == shopId);
    if (index != -1) {
      MockShops.shops[index] = MockShops.shops[index].copyWith(
        verificationStatus: 'approved',
        suspensionReason: null,
      );
      notifyListeners();
    }
  }

  void suspendShop(String shopId, String reason) {
    final index = MockShops.shops.indexWhere((s) => s.id == shopId);
    if (index != -1) {
      MockShops.shops[index] = MockShops.shops[index].copyWith(
        verificationStatus: 'suspended',
        suspensionReason: reason,
      );
      notifyListeners();
    }
  }

  // 5. Operasi Aksi Pengguna (Ubah Role & Ubah Status)
  void updateUserRole(String userId, String role) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(role: role);
      notifyListeners();
    }
  }

  void updateUserStatus(String userId, String status) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(status: status);
      notifyListeners();
    }
  }

  // 6. Operasi Aksi Penarikan Dana (Approve & Reject Payout)
  void approvePayout(String payoutId, String proofImage) {
    final index = _payouts.indexWhere((p) => p.id == payoutId);
    if (index != -1) {
      _payouts[index] = _payouts[index].copyWith(
        status: 'success',
        transferProof: proofImage,
        rejectReason: null,
      );
      notifyListeners();
    }
  }

  void rejectPayout(String payoutId, String reason) {
    final index = _payouts.indexWhere((p) => p.id == payoutId);
    if (index != -1) {
      _payouts[index] = _payouts[index].copyWith(
        status: 'rejected',
        rejectReason: reason,
        transferProof: null,
      );
      notifyListeners();
    }
  }

  // 7. Update Konfigurasi Global
  void updateSystemConfig({
    double? platformFee,
    bool? isMaintenance,
    String? maintenanceMessage,
  }) {
    _config = _config.copyWith(
      platformFee: platformFee,
      isMaintenance: isMaintenance,
      maintenanceMessage: maintenanceMessage,
    );
    notifyListeners();
  }
}
