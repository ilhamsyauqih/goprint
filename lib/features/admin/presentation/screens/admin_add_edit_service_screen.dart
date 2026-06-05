import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import '../../../shop/data/mock_shops.dart';

class AdminAddEditServiceScreen extends StatefulWidget {
  final ServiceItem? service;

  const AdminAddEditServiceScreen({this.service, super.key});

  @override
  State<AdminAddEditServiceScreen> createState() => _AdminAddEditServiceScreenState();
}

class _AdminAddEditServiceScreenState extends State<AdminAddEditServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _estimateController;
  String _selectedCategory = 'Print';

  // State untuk harga jenis kertas (add-on fee)
  final Map<String, double> _paperPrices = {
    'HVS 70g': 0,
    'HVS 80g': 200,
    'Art Paper': 1000,
  };

  // State untuk harga finishing (add-on fee)
  final Map<String, double> _finishingPrices = {
    'Tanpa Jilid': 0,
    'Jilid Lakban Biasa': 5000,
    'Jilid Spiral Kawat': 15000,
  };

  final List<String> _categories = [
    'Print',
    'Jilid',
    'Laminating',
    'Scan',
    'Fotokopi',
    'Template'
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameController = TextEditingController(text: s?.name ?? '');
    _priceController = TextEditingController(
      text: s != null ? s.priceStartingFrom.toInt().toString() : '',
    );
    _estimateController = TextEditingController(text: s?.estimateTime ?? '15 menit');
    _selectedCategory = s?.category ?? 'Print';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _estimateController.dispose();
    super.dispose();
  }

  void _saveService() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final price = double.parse(_priceController.text.trim());
      final estimate = _estimateController.text.trim();
      final category = _selectedCategory;

      final updatedItem = ServiceItem(
        name: name,
        priceStartingFrom: price,
        estimateTime: estimate,
        category: category,
        isActive: widget.service?.isActive ?? true,
      );

      final shop = MockShops.shops[0]; // Surya Gemilang

      if (widget.service != null) {
        // Edit mode
        final index = shop.services.indexWhere((s) => s.name == widget.service!.name);
        if (index != -1) {
          shop.services[index] = updatedItem;
        }
      } else {
        // Add mode
        shop.services.add(updatedItem);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.service != null
                ? 'Layanan "$name" berhasil diperbarui'
                : 'Layanan "$name" berhasil ditambahkan',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isEdit = widget.service != null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: CustomAppBar(
        title: isEdit ? 'Edit Layanan' : 'Tambah Layanan Baru',
        showBackButton: true,
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
                    // Form Card
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
                            'Informasi Dasar',
                            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          // Name
                          _buildTextField(
                            label: 'Nama Layanan',
                            controller: _nameController,
                            hint: 'Misal: Print Warna High Quality',
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Nama layanan wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Category
                          DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                            decoration: InputDecoration(
                              labelText: 'Kategori Layanan',
                              labelStyle: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.teal300 : AppColors.teal700,
                                fontWeight: FontWeight.bold,
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
                            items: _categories.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat,
                                child: Text(cat, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedCategory = val;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Price
                          _buildTextField(
                            label: 'Harga Dasar (Rp)',
                            controller: _priceController,
                            hint: 'Misal: 500',
                            keyboardType: TextInputType.number,
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Harga dasar wajib diisi';
                              }
                              final numVal = double.tryParse(val);
                              if (numVal == null || numVal <= 0) {
                                return 'Harga dasar harus berupa angka positif';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Estimate Time
                          _buildTextField(
                            label: 'Estimasi Waktu',
                            controller: _estimateController,
                            hint: 'Misal: 5-10 menit, 1 jam',
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Estimasi waktu wajib diisi';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // PaperTypePriceList Component (Opsi Kertas)
                    _buildPaperTypePriceList(isDark, theme),
                    const SizedBox(height: 20),

                    // FinishingOptionList Component (Opsi Finishing)
                    _buildFinishingOptionList(isDark, theme),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Sticky Button Save
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
                  onPressed: _saveService,
                  icon: const Icon(Icons.save_rounded),
                  label: Text(
                    isEdit ? 'Simpan Perubahan' : 'Tambah Layanan',
                    style: const TextStyle(fontWeight: FontWeight.bold),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
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

  Widget _buildPaperTypePriceList(bool isDark, ThemeData theme) {
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
                Icons.description_outlined,
                size: 18,
                color: isDark ? AppColors.teal300 : AppColors.teal700,
              ),
              const SizedBox(width: 8),
              Text(
                'Konfigurasi Biaya Tambahan Kertas (Per Lembar)',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Biaya tambahan ini akan diakumulasikan ke harga per halaman sesuai pilihan kertas pelanggan.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
            ),
          ),
          const SizedBox(height: 16),
          ..._paperPrices.keys.map((paperType) {
            final double value = _paperPrices[paperType]!;
            final controller = TextEditingController(text: value.toInt().toString());
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      paperType,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final parseVal = double.tryParse(val) ?? 0.0;
                        _paperPrices[paperType] = parseVal;
                      },
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
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
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFinishingOptionList(bool isDark, ThemeData theme) {
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
                Icons.layers_outlined,
                size: 18,
                color: isDark ? AppColors.teal300 : AppColors.teal700,
              ),
              const SizedBox(width: 8),
              Text(
                'Konfigurasi Biaya Finishing / Jilid',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Biaya tetap yang ditambahkan per berkas jika opsi finishing dipilih.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkMutedText : AppColors.lightSubtleText,
            ),
          ),
          const SizedBox(height: 16),
          ..._finishingPrices.keys.map((option) {
            final double value = _finishingPrices[option]!;
            final controller = TextEditingController(text: value.toInt().toString());
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      option,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: controller,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        final parseVal = double.tryParse(val) ?? 0.0;
                        _finishingPrices[option] = parseVal;
                      },
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
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
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
