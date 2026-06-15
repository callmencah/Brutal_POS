import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/coupon.dart';
import '../../data/repositories/coupon_repository.dart';
import 'bloc/coupon_cubit.dart';
import 'bloc/coupon_state.dart';

class CouponManageScreen extends StatelessWidget {
  const CouponManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          CouponManageCubit(repository: CouponRepository())..loadCoupons(),
      child: const _CouponManageView(),
    );
  }
}

class _CouponManageView extends StatelessWidget {
  const _CouponManageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/more');
            }
          },
        ),
        title: Text(
          'COUPONS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => _showAddCouponSheet(context),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                border: Border.all(color: AppColors.shadow, width: 2),
              ),
              child: Text(
                '+ ADD',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<CouponManageCubit, CouponManageState>(
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (state.coupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_offer_rounded,
                      size: 56,
                      color: AppColors.textSecondary.withOpacity(0.4)),
                  const SizedBox(height: 16),
                  Text(
                    'No coupons yet',
                    style: GoogleFonts.inter(
                        fontSize: 18, color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.coupons.length,
            itemBuilder: (context, index) {
              final coupon = state.coupons[index];
              return _CouponCard(coupon: coupon);
            },
          );
        },
      ),
    );
  }

  void _showAddCouponSheet(BuildContext context) {
    final codeCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final valueCtrl = TextEditingController();
    final minPurchaseCtrl = TextEditingController();
    final maxDiscountCtrl = TextEditingController();
    final usageLimitCtrl = TextEditingController(text: '0');
    String discountType = 'percentage';

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
                    Container(
                        width: 60, height: 3, color: AppColors.primary),
                    const SizedBox(height: 16),
                    Text('ADD COUPON',
                        style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary)),
                    const SizedBox(height: 20),
                    _buildInput('Code', codeCtrl, 'e.g. SAVE10'),
                    _buildInput('Description', descCtrl, 'optional'),
                    const SizedBox(height: 8),
                    Text('Discount Type',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _TypeToggle(
                          label: '%',
                          isSelected: discountType == 'percentage',
                          onTap: () => setSheetState(
                              () => discountType = 'percentage'),
                        ),
                        const SizedBox(width: 8),
                        _TypeToggle(
                          label: 'FIXED',
                          isSelected: discountType == 'fixed',
                          onTap: () =>
                              setSheetState(() => discountType = 'fixed'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInput('Discount Value', valueCtrl, '10',
                        isNumber: true),
                    _buildInput(
                        'Min Purchase', minPurchaseCtrl, '50000',
                        isNumber: true),
                    if (discountType == 'percentage')
                      _buildInput(
                          'Max Discount', maxDiscountCtrl, '20000',
                          isNumber: true),
                    _buildInput('Usage Limit (0=unlimited)',
                        usageLimitCtrl, '0',
                        isNumber: true),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        if (codeCtrl.text.isEmpty ||
                            valueCtrl.text.isEmpty) {
                          return;
                        }
                        final coupon = Coupon(
                          code: codeCtrl.text.toUpperCase(),
                          description: descCtrl.text.isEmpty
                              ? null
                              : descCtrl.text,
                          discountType: discountType,
                          discountValue:
                              double.tryParse(valueCtrl.text) ?? 0,
                          minPurchase:
                              double.tryParse(minPurchaseCtrl.text) ?? 0,
                          maxDiscount: discountType == 'percentage'
                              ? double.tryParse(maxDiscountCtrl.text)
                              : null,
                          isActive: true,
                          usageLimit:
                              int.tryParse(usageLimitCtrl.text) ?? 0,
                          usageCount: 0,
                        );
                        context
                            .read<CouponManageCubit>()
                            .addCoupon(coupon);
                        Navigator.pop(sheetCtx);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          border:
                              Border.all(color: AppColors.shadow, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.shadow,
                                offset: Offset(4, 4),
                                blurRadius: 0),
                          ],
                        ),
                        child: Center(
                          child: Text('SAVE COUPON',
                              style: GoogleFonts.spaceGrotesk(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary)),
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

  Widget _buildInput(
      String label, TextEditingController ctrl, String hint,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, width: 3),
        ),
        child: TextField(
          controller: ctrl,
          keyboardType:
              isNumber ? TextInputType.number : TextInputType.text,
          textCapitalization: isNumber
              ? TextCapitalization.none
              : TextCapitalization.characters,
          style:
              GoogleFonts.inter(fontSize: 16, color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary),
            hintText: hint,
            hintStyle: GoogleFonts.inter(
                fontSize: 14, color: AppColors.textSecondary.withOpacity(0.5)),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeToggle(
      {required this.label,
      required this.isSelected,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.card,
          border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: 3),
        ),
        child: Text(label,
            style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary)),
      ),
    );
  }
}

class _CouponCard extends StatelessWidget {
  final Coupon coupon;

  const _CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow, offset: Offset(4, 4), blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  coupon.code,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: coupon.discountType == 'percentage'
                      ? AppColors.secondary
                      : AppColors.primary,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: Text(
                  coupon.discountType == 'percentage' ? '%' : 'Rp',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: coupon.discountType == 'percentage'
                        ? AppColors.textOnSecondary
                        : AppColors.textOnPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: coupon.isActive
                      ? AppColors.success.withOpacity(0.2)
                      : AppColors.error.withOpacity(0.2),
                  border: Border.all(
                      color:
                          coupon.isActive ? AppColors.success : AppColors.error,
                      width: 2),
                ),
                child: Text(
                  coupon.isActive ? 'ACTIVE' : 'INACTIVE',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color:
                        coupon.isActive ? AppColors.success : AppColors.error,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            coupon.discountType == 'percentage'
                ? '${coupon.discountValue.toStringAsFixed(0)}% off'
                : AppConstants.formatCurrency(coupon.discountValue),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _DetailTag(
                  'Min: ${AppConstants.formatCurrency(coupon.minPurchase)}'),
              if (coupon.maxDiscount != null)
                _DetailTag(
                    'Max: ${AppConstants.formatCurrency(coupon.maxDiscount!)}'),
              _DetailTag(
                  'Used: ${coupon.usageCount}/${coupon.usageLimit == 0 ? '∞' : coupon.usageLimit}'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  context
                      .read<CouponManageCubit>()
                      .toggleCouponStatus(coupon.id!, !coupon.isActive);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: coupon.isActive ? AppColors.error : AppColors.success,
                    border: Border.all(color: AppColors.shadow, width: 2),
                  ),
                  child: Text(
                    coupon.isActive ? 'DEACTIVATE' : 'ACTIVATE',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailTag extends StatelessWidget {
  final String text;
  const _DetailTag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, width: 2),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

