import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/widgets/brutal_button.dart';
import 'bloc/cart_cubit.dart';
import 'bloc/cart_state.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/cart_summary.dart';
import 'widgets/coupon_input.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => context.pop(),
            ),
            title: Row(
              children: [
                Text(
                  AppLocalizations.of(context).cart.toUpperCase(),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (!state.isEmpty) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                    ),
                    child: Text(
                      '${state.totalItems}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (!state.isEmpty)
                IconButton(
                  icon: Icon(
                    Icons.delete_sweep_outlined,
                    color: AppColors.error,
                    size: 26,
                  ),
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                ),
            ],
          ),
          body: state.isEmpty ? _buildEmptyState() : _buildCartContent(context, state),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.4),
          ),
          const SizedBox(height: 24),
          Text(
            'Your cart is empty',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add products from the POS screen',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(BuildContext context, CartState state) {
    final cartCubit = context.read<CartCubit>();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isLandscape = constraints.maxWidth > 600;

        if (isLandscape) {
          return Row(
            children: [
              Expanded(
                flex: 3,
                child: ListView.builder(
                  itemCount: state.items.length,
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return CartItemTile(
                      item: item,
                      onIncrement: () =>
                          cartCubit.incrementQuantity(item.product.id!),
                      onDecrement: () =>
                          cartCubit.decrementQuantity(item.product.id!),
                      onRemove: () => cartCubit.removeItem(item.product.id!),
                    );
                  },
                ),
              ),
              Container(width: 3, color: AppColors.border),
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            CouponInput(
                              couponError: state.couponError,
                              couponSuccess: state.couponSuccess,
                              appliedCoupon: state.appliedCoupon,
                              discountAmount: state.discountAmount,
                              onApply: (code) => cartCubit.applyCoupon(code),
                              onRemove: () => cartCubit.removeCoupon(),
                            ),
                            CartSummary(state: state),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: BrutalButton(
                          text: AppLocalizations.of(context).proceedToPayment.toUpperCase(),
                          icon: Icons.payment,
                          height: 56,
                          onPressed: state.isEmpty
                              ? null
                              : () {
                                  context.push('/payment');
                                },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: state.items.length,
                padding: EdgeInsets.zero,
                itemBuilder: (context, index) {
                  final item = state.items[index];
                  return CartItemTile(
                    item: item,
                    onIncrement: () =>
                        cartCubit.incrementQuantity(item.product.id!),
                    onDecrement: () =>
                        cartCubit.decrementQuantity(item.product.id!),
                    onRemove: () => cartCubit.removeItem(item.product.id!),
                  );
                },
              ),
            ),
            CouponInput(
              couponError: state.couponError,
              couponSuccess: state.couponSuccess,
              appliedCoupon: state.appliedCoupon,
              discountAmount: state.discountAmount,
              onApply: (code) => cartCubit.applyCoupon(code),
              onRemove: () => cartCubit.removeCoupon(),
            ),
            CartSummary(state: state),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BrutalButton(
                  text: AppLocalizations.of(context).proceedToPayment.toUpperCase(),
                  icon: Icons.payment,
                  height: 56,
                  onPressed: state.isEmpty
                      ? null
                      : () {
                          context.push('/payment');
                        },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: AppColors.border, width: 3),
          ),
          title: Text(
            AppLocalizations.of(context).clearCart.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          content: Text(
            'Remove all items from your cart?',
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'CANCEL',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<CartCubit>().clearCart();
                Navigator.of(dialogContext).pop();
              },
              child: Text(
                'CLEAR',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

