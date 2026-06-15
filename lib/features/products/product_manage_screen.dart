import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../data/models/product.dart';
import '../../data/models/category.dart';
import '../../data/repositories/product_repository.dart';
import '../../core/utils/refresh_notifier.dart';

class ProductManageScreen extends StatefulWidget {
  const ProductManageScreen({super.key});

  @override
  State<ProductManageScreen> createState() => _ProductManageScreenState();
}

class _ProductManageScreenState extends State<ProductManageScreen> {
  final ProductRepository _repo = ProductRepository();
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = true;

  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  List<Product> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final products = await _repo.getAllProducts();
      final categories = await _repo.getAllCategories();
      if (mounted) {
        setState(() {
          _products = products;
          _categories = categories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context).error}: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: context.canPop()
            ? IconButton(
                icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              )
            : null,
        title: Text(
          l10n.products.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _showProductForm(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                border: Border.all(color: AppColors.shadow, width: 2),
              ),
              child: Text(
                '+ ${l10n.addProduct.toUpperCase()}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: Border.all(color: AppColors.border, width: 3),
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: GoogleFonts.inter(
                          fontSize: 16, color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: l10n.searchProducts,
                        hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.textSecondary.withOpacity(0.5)),
                        prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.close, color: AppColors.error),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: _filteredProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 56,
                                  color: AppColors.textSecondary.withOpacity(0.4)),
                              const SizedBox(height: 16),
                              Text(
                                l10n.noProducts,
                                style: GoogleFonts.inter(
                                    fontSize: 18, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final product = _filteredProducts[index];
                    final cat = _categories.where(
                        (c) => c.id == product.categoryId);
                    final catName = cat.isNotEmpty
                        ? (l10n.locale == 'id' ? cat.first.nameId : cat.first.nameEn)
                        : '';
                    return _ProductManageCard(
                      product: product,
                      categoryName: catName,
                      onEdit: () => _showProductForm(context, product: product),
                      onDelete: () => _confirmDelete(context, product),
                      onToggleAvailability: () =>
                          _toggleAvailability(product),
                    );
                  },
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _toggleAvailability(Product product) async {
    final updated = product.copyWith(isAvailable: !product.isAvailable);
    await _repo.updateProduct(updated);
    triggerGlobalRefresh();
    await _loadData();
  }

  void _confirmDelete(BuildContext context, Product product) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: AppColors.border, width: 3),
        ),
        title: Text(
          l10n.deleteProduct.toUpperCase(),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          '${l10n.get('deleteConfirm')}\n"${product.name}"',
          style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _repo.deleteProduct(product.id!);
              triggerGlobalRefresh();
              await _loadData();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(l10n.productDeleted,
                    style: GoogleFonts.inter(color: AppColors.textPrimary)),
                backgroundColor: AppColors.error,
              ));
            },
            child: Text(l10n.delete.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showProductForm(BuildContext context, {Product? product}) {
    final l10n = AppLocalizations.of(context);
    final isEdit = product != null;
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final priceCtrl = TextEditingController(
        text: product != null ? product.price.toStringAsFixed(0) : '');
    final iconCtrl = TextEditingController(text: product?.imageIcon ?? '');
    String? imagePath = product?.imagePath;
    int selectedCategoryId = product?.categoryId ?? (_categories.isNotEmpty ? _categories.first.id! : 1);
    bool isAvailable = product?.isAvailable ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 60, height: 3, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text(
                      isEdit
                          ? l10n.editProduct.toUpperCase()
                          : l10n.addProduct.toUpperCase(),
                      style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 20),

                    // Name
                    _FormField(label: l10n.productName, controller: nameCtrl),

                    // Price
                    _FormField(
                        label: l10n.productPrice,
                        controller: priceCtrl,
                        isNumber: true),

                    // Upload Image
                    const SizedBox(height: 4),
                    Text('Product Image',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border, width: 3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imagePath != null && imagePath!.isNotEmpty)
                            Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.border, width: 2),
                              ),
                              child: Image.file(File(imagePath!), fit: BoxFit.contain),
                            ),
                          GestureDetector(
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(source: ImageSource.gallery);
                              if (pickedFile != null) {
                                setSheetState(() {
                                  imagePath = pickedFile.path;
                                  iconCtrl.text = ''; // clear emoji if image is selected
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                border: Border.all(color: AppColors.shadow, width: 2),
                              ),
                              child: Text(
                                imagePath != null ? 'Ganti Foto' : 'Pilih dari Galeri',
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                          if (imagePath != null)
                            GestureDetector(
                              onTap: () {
                                setSheetState(() {
                                  imagePath = null;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text('Hapus Foto', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Emoji icon fallback
                    Text('Atau Gunakan Emoji',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textSecondary)),
                    Text('Emoji Icon',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border, width: 3),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Selected icon preview
                          Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  border: Border.all(color: AppColors.border, width: 2),
                                ),
                                child: Center(
                                  child: Text(
                                    iconCtrl.text.isEmpty ? '🍔' : iconCtrl.text,
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                iconCtrl.text.isEmpty ? 'Pilih Emoji dari Grid Bawah' : 'Emoji Terpilih',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Pilih Icon (Emoji)',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Emoji grid
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              '☕', '🍵', '🧃', '🥤', '🍶', '🍺', '🍹', '🥛',
                              '🍔', '🍕', '🌭', '🌮', '🌯', '🥪', '🥙', '🧆',
                              '🍗', '🍖', '🥩', '🍳', '🥚', '🧇', '🥞', '🍲',
                              '🍜', '🍝', '🍣', '🍱', '🥗', '🍙', '🍚', '🍛',
                              '🍰', '🧁', '🍩', '🍪', '🍫', '🍿', '🥐', '🍞',
                              '🍦', '🧋', '🫗', '🥑', '🍋', '🍎', '🥕', '🌽',
                            ].map((emoji) {
                              final isSelected = iconCtrl.text == emoji;
                              return GestureDetector(
                                onTap: () {
                                  setSheetState(() {
                                    iconCtrl.text = emoji;
                                  });
                                },
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.2)
                                        : AppColors.card,
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: isSelected ? 3 : 1,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(emoji,
                                        style: const TextStyle(fontSize: 22)),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category
                    const SizedBox(height: 4),
                    Text(l10n.category,
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _categories.map((cat) {
                        final isSel = cat.id == selectedCategoryId;
                        final name = l10n.locale == 'id' ? cat.nameId : cat.nameEn;
                        return GestureDetector(
                          onTap: () =>
                              setSheetState(() => selectedCategoryId = cat.id!),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  isSel ? AppColors.primary : AppColors.card,
                              border: Border.all(
                                  color: isSel
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: 3),
                            ),
                            child: Text(
                              '${cat.icon} $name',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Availability toggle
                    GestureDetector(
                      onTap: () =>
                          setSheetState(() => isAvailable = !isAvailable),
                      child: Row(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? AppColors.success
                                  : AppColors.error,
                              border:
                                  Border.all(color: AppColors.shadow, width: 2),
                            ),
                            child: Icon(
                              isAvailable ? Icons.check : Icons.close,
                              size: 16,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isAvailable
                                ? l10n.get('available')
                                : l10n.get('unavailable'),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isAvailable
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save button
                    GestureDetector(
                      onTap: () async {
                        if (nameCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
                          return;
                        }
                        final newProduct = Product(
                          id: product?.id,
                          name: nameCtrl.text.trim(),
                          categoryId: selectedCategoryId,
                          price: double.tryParse(priceCtrl.text) ?? 0,
                          imageIcon: iconCtrl.text.isEmpty ? null : iconCtrl.text,
                          imagePath: imagePath,
                          isAvailable: isAvailable,
                        );
                        if (isEdit) {
                          await _repo.updateProduct(newProduct);
                        } else {
                          await _repo.addProduct(newProduct);
                        }
                        triggerGlobalRefresh();
                        if (!context.mounted) return;
                        Navigator.pop(sheetCtx);
                        await _loadData();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              isEdit
                                  ? l10n.productUpdated
                                  : l10n.productAdded,
                              style:
                                  GoogleFonts.inter(color: AppColors.textPrimary)),
                          backgroundColor: AppColors.success,
                        ));
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          border: Border.all(color: AppColors.shadow, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.shadow,
                                offset: Offset(4, 4),
                                blurRadius: 0),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            isEdit
                                ? l10n.save.toUpperCase()
                                : l10n.addProduct.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isNumber;
  final String? hint;

  const _FormField({
    super.key,
    required this.label,
    required this.controller,
    this.isNumber = false,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 3),
        ),
        child: TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          inputFormatters:
              isNumber ? [FilteringTextInputFormatter.digitsOnly] : null,
          style: GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            labelStyle:
                GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary),
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.5)),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _ProductManageCard extends StatelessWidget {
  final Product product;
  final String categoryName;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggleAvailability;

  const _ProductManageCard({
    required this.product,
    required this.categoryName,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleAvailability,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow, offset: Offset(3, 3), blurRadius: 0),
        ],
      ),
      child: Row(
        children: [
          // Emoji or Image
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: product.imagePath != null && product.imagePath!.isNotEmpty
                ? Image.file(File(product.imagePath!), fit: BoxFit.contain)
                : Center(
                    child: Text(
                      product.imageIcon ?? '🍽️',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
          ),
          const SizedBox(width: 14),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      categoryName,
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: product.isAvailable
                            ? AppColors.success.withOpacity(0.15)
                            : AppColors.error.withOpacity(0.15),
                        border: Border.all(
                            color: product.isAvailable
                                ? AppColors.success
                                : AppColors.error,
                            width: 1),
                      ),
                      child: Text(
                        product.isAvailable ? '✓' : '✗',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: product.isAvailable
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  AppConstants.formatCurrency(product.price),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          // Actions
          Column(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Icon(Icons.edit, color: AppColors.primary, size: 18),
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onDelete,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    border: Border.all(color: AppColors.error, width: 2),
                  ),
                  child: Icon(Icons.delete, color: AppColors.error, size: 18),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

