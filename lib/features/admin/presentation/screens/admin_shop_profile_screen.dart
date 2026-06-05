import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../shop/data/mock_shops.dart';
import '../widgets/admin_drawer.dart';

class AdminShopProfileScreen extends StatefulWidget {
  const AdminShopProfileScreen({super.key});

  @override
  State<AdminShopProfileScreen> createState() => _AdminShopProfileScreenState();
}

class _AdminShopProfileScreenState extends State<AdminShopProfileScreen> {
  final Shop _shop = MockShops.shops[0]; // Surya Gemilang
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;

  late bool _isOpen;
  late List<String> _galleryPhotos;
  late List<OperatingHour> _operatingHours;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _shop.name);
    _descController = TextEditingController(text: _shop.description);
    _addressController = TextEditingController(text: _shop.address);
    _phoneController = TextEditingController(text: _shop.phone);
    _isOpen = _shop.isOpen;

    // Initialize mock photo gallery (max 5 photos)
    _galleryPhotos = [
      _shop.imageUrl,
      'https://images.unsplash.com/photo-1562654305-6512271ac4c6?q=80&w=600&auto=format&fit=crop',
      'https://images.unsplash.com/photo-1586075010923-2dd4570fb338?q=80&w=600&auto=format&fit=crop',
    ];

    // Initialize operating hours list
    _operatingHours = _shop.operatingHours.map((oh) => OperatingHour(
      day: oh.day,
      hours: oh.hours,
      isClosed: oh.isClosed,
    )).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _toggleShopStatus(bool value) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(value ? 'Buka Toko?' : 'Tutup Toko Sementara?'),
        content: Text(
          value
              ? 'Toko Anda akan kembali aktif dan siap menerima pesanan masuk dari pelanggan.'
              : 'Toko Anda akan ditandai sebagai tutup. Pelanggan tidak akan bisa membuat pesanan baru hingga toko dibuka kembali.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              setState(() {
                _isOpen = value;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(value ? 'Toko berhasil DIBUKA' : 'Toko berhasil DITUTUP'),
                  backgroundColor: value ? AppColors.success : AppColors.error,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: value 
                  ? (Theme.of(context).brightness == Brightness.dark ? AppColors.teal300 : AppColors.teal700)
                  : AppColors.error,
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );
  }

  void _addGalleryPhoto() {
    if (_galleryPhotos.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Galeri foto maksimal 5 foto.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Tambah Foto Toko'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'Masukkan URL gambar unsplash atau url web...',
            labelText: 'URL Foto',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              final url = urlController.text.trim();
              if (url.isNotEmpty) {
                setState(() {
                  _galleryPhotos.add(url);
                });
                Navigator.of(dialogContext).pop();
              }
            },
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _deleteGalleryPhoto(int index) {
    if (_galleryPhotos.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Toko harus memiliki minimal 1 foto utama.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _galleryPhotos.removeAt(index);
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Perbarui objek in-memory
      final updatedShop = _shop.copyWith(
        name: _nameController.text.trim(),
        description: _descController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        isOpen: _isOpen,
        imageUrl: _galleryPhotos.isNotEmpty ? _galleryPhotos.first : _shop.imageUrl,
        operatingHours: _operatingHours,
      );

      // Reassign di list statis MockShops
      final idx = MockShops.shops.indexWhere((s) => s.id == _shop.id);
      if (idx != -1) {
        MockShops.shops[idx] = updatedShop;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil toko Surya Gemilang berhasil diperbarui!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      drawer: const AdminDrawer(currentRoute: '/admin/shop-profile'),
      appBar: CustomAppBar(
        title: 'Profil Toko',
        showBackButton: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ShopStatusToggle Component (Buka/Tutup Toko)
                    _buildShopStatusToggle(isDark, theme),
                    const SizedBox(height: 20),

                    // Photo Gallery Component
                    _buildShopPhotoGallery(isDark, theme),
                    const SizedBox(height: 20),

                    // General Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Umum',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Nama Toko',
                            controller: _nameController,
                            hint: 'Masukkan nama toko...',
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Nama toko wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Deskripsi Toko',
                            controller: _descController,
                            hint: 'Masukkan deskripsi layanan...',
                            maxLines: 4,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Deskripsi wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Alamat Toko',
                            controller: _addressController,
                            hint: 'Masukkan alamat lengkap...',
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Alamat wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            label: 'Nomor Telepon / WhatsApp',
                            controller: _phoneController,
                            hint: 'Misal: 0812-3456-7890',
                            keyboardType: TextInputType.phone,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Nomor HP wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // OperatingHoursEditor Component (Jam Operasional)
                    _buildOperatingHoursEditor(isDark, theme),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Save button
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text(
                    'Simpan Perubahan',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                    foregroundColor: isDark ? AppColors.teal900 : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopStatusToggle(bool isDark, ThemeData theme) {
    final statusColor = _isOpen
        ? (isDark ? AppColors.successDark : AppColors.success)
        : AppColors.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status Operasional Toko',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _isOpen ? 'Toko Sedang BUKA' : 'Toko Sedang TUTUP',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch(
            value: _isOpen,
            onChanged: _toggleShopStatus,
            activeColor: isDark ? AppColors.teal300 : AppColors.teal700,
          ),
        ],
      ),
    );
  }

  Widget _buildShopPhotoGallery(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Galeri Foto Toko (${_galleryPhotos.length}/5)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (_galleryPhotos.length < 5)
                TextButton.icon(
                  onPressed: _addGalleryPhoto,
                  icon: const Icon(Icons.add_a_photo_rounded, size: 16),
                  label: const Text('Tambah'),
                  style: TextButton.styleFrom(
                    foregroundColor: isDark ? AppColors.teal300 : AppColors.teal700,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _galleryPhotos.length,
              itemBuilder: (context, index) {
                final photo = _galleryPhotos[index];
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: photo.startsWith('http')
                              ? Image.network(photo, fit: BoxFit.cover)
                              : Image.asset(photo, fit: BoxFit.cover),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _deleteGalleryPhoto(index),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.black.withValues(alpha: 0.6),
                            child: const Icon(
                              Icons.close_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatingHoursEditor(bool isDark, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 18,
                color: isDark ? AppColors.teal300 : AppColors.teal700,
              ),
              const SizedBox(width: 8),
              Text(
                'Jam Operasional Mingguan',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(_operatingHours.length, (index) {
            final oh = _operatingHours[index];
            final controller = TextEditingController(text: oh.isClosed ? 'Tutup' : oh.hours);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      oh.day,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: controller,
                      enabled: !oh.isClosed,
                      onChanged: (val) {
                        _operatingHours[index] = OperatingHour(
                          day: oh.day,
                          hours: val,
                          isClosed: oh.isClosed,
                        );
                      },
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: oh.isClosed,
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _operatingHours[index] = OperatingHour(
                                day: oh.day,
                                hours: val ? 'Tutup' : '08:00 - 21:00',
                                isClosed: val,
                              );
                            });
                          }
                        },
                        activeColor: isDark ? AppColors.teal300 : AppColors.teal700,
                      ),
                      Text(
                        'Libur',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontSize: 12,
                          color: oh.isClosed
                              ? (isDark ? AppColors.errorDark : AppColors.error)
                              : (isDark ? AppColors.darkMutedText : AppColors.lightSubtleText),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.teal300 : AppColors.teal700,
          fontWeight: FontWeight.bold,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
        ),
        filled: true,
        fillColor: isDark ? AppColors.darkElevated : Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.teal300 : AppColors.teal700,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
