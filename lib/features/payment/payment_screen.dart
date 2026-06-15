import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/brutal_button.dart';
import '../../data/repositories/coupon_repository.dart';
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_item.dart';
import '../../data/services/receipt_service.dart';
import '../../core/utils/refresh_notifier.dart';
import '../../core/utils/receipt_printer.dart';
import '../../core/services/telegram_service.dart';
import '../../data/models/transaction.dart';
import 'package:share_plus/share_plus.dart';
import '../cart/bloc/cart_cubit.dart';
import '../cart/bloc/cart_state.dart';
import '../settings/bloc/settings_cubit.dart';
import 'bloc/payment_cubit.dart';
import 'bloc/payment_state.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _amountController = TextEditingController();
  late final PaymentCubit _paymentCubit;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final cartState = context.read<CartCubit>().state;
      _paymentCubit = PaymentCubit(
        transactionRepository: TransactionRepository(),
        couponRepository: CouponRepository(),
        productRepository: ProductRepository(),
        rawTotalAmount: cartState.grandTotal, // Note: cartState.grandTotal is raw now
        roundUpEnabled: cartState.roundUpEnabled,
      );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _paymentCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocProvider.value(
      value: _paymentCubit,
      child: BlocConsumer<PaymentCubit, PaymentState>(
        listener: (context, state) {
          if (state.status == PaymentStatus.success) {
            final cartState = context.read<CartCubit>().state;
            
            // Telegram Backup
            final receiptItems = cartState.items
                .map((item) => TransactionItem(
                      transactionId: state.transactionId ?? 0,
                      productId: item.product.id!,
                      productName: item.product.name,
                      quantity: item.quantity,
                      unitPrice: item.product.price,
                      subtotal: item.subtotal,
                    ))
                .toList();

            final tx = Transaction(
              id: state.transactionId,
              subtotal: cartState.subtotal,
              taxPercent: cartState.taxPercent,
              taxAmount: cartState.taxAmount,
              discountAmount: cartState.discountAmount,
              total: state.totalAmount,
              paymentMethod: state.methodLabel,
              createdAt: DateTime.now(),
              items: receiptItems,
              amountPaid: state.amountPaid,
              changeAmount: state.changeAmount,
              serviceChargeAmount: cartState.serviceChargeAmount,
              roundUpAmount: state.roundUpAmount,
            );

            ReceiptPrinter.generateReceiptPdf(tx).then((pdfBytes) {
              TelegramService.sendReceiptBackup(pdfBytes, state.transactionId.toString());
            });

            if (state.selectedMethod != PaymentMethod.qris) {
              _showSuccessDialog(context, state, cartState);
            }
          }
          if (state.status == PaymentStatus.error && state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.error!,
                  style: GoogleFonts.inter(color: AppColors.textPrimary),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == PaymentStatus.success && state.selectedMethod == PaymentMethod.qris) {
            return _buildQrisSuccessView(context, state);
          }
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              leading: IconButton(
                icon: Icon(Icons.arrow_back,
                    color: AppColors.textPrimary),
                onPressed: () => context.pop(),
              ),
              title: Text(
                l10n.payment.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isLandscape = constraints.maxWidth > 600;

                if (isLandscape) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildTotalDisplay(context, state),
                              const SizedBox(height: 32),
                              Text(
                                l10n.paymentMethod.toUpperCase(),
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildMethodGrid(context, state),
                            ],
                          ),
                        ),
                        const SizedBox(width: 32),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (state.selectedMethod == PaymentMethod.cash) ...[
                                _buildCashInput(context, state),
                                const SizedBox(height: 24),
                              ],
                              const SizedBox(height: 32),
                              _buildPayButton(context, state),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      // Total amount display
                      _buildTotalDisplay(context, state),
                      const SizedBox(height: 32),
                      // Select method label
                      Text(
                        l10n.paymentMethod.toUpperCase(),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Payment method grid
                      _buildMethodGrid(context, state),
                      const SizedBox(height: 24),
                      // Method-specific UI
                      if (state.selectedMethod == PaymentMethod.cash)
                        _buildCashInput(context, state),
                      const SizedBox(height: 24),
                      // Pay now button
                      _buildPayButton(context, state),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalDisplay(BuildContext context, PaymentState state) {
    final l10n = AppLocalizations.of(context);
    final cartState = context.read<CartCubit>().state;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.subtotal,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                AppConstants.formatCurrency(cartState.subtotal),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (cartState.discountAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.discount,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '-${AppConstants.formatCurrency(cartState.discountAmount)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${l10n.tax} (${cartState.taxPercent.toStringAsFixed(1)}%)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                AppConstants.formatCurrency(cartState.taxAmount),
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          if (cartState.serviceChargeEnabled) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${l10n.serviceCharge} (${cartState.serviceChargePercent.toStringAsFixed(1)}%)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  AppConstants.formatCurrency(cartState.serviceChargeAmount),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ],
          if (state.roundUpAmount > 0) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.totalBeforeRounding,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  AppConstants.formatCurrency(cartState.grandTotal),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.rounding,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '+ ${AppConstants.formatCurrency(state.roundUpAmount)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 16),
          Divider(color: AppColors.border, thickness: 2),
          const SizedBox(height: 16),
          Center(
            child: Column(
              children: [
                Text(
                  l10n.total,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppConstants.formatCurrency(state.totalAmount),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodGrid(BuildContext context, PaymentState state) {
    final methods = [
      _MethodInfo(PaymentMethod.cash, Icons.payments, 'Cash'),
      _MethodInfo(PaymentMethod.qris, Icons.qr_code_2, 'QRIS'),
      _MethodInfo(PaymentMethod.eWallet, Icons.account_balance_wallet, 'E-Wallet'),
      _MethodInfo(PaymentMethod.card, Icons.credit_card, 'Card'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.6,
      ),
      itemCount: methods.length,
      itemBuilder: (context, index) {
        final method = methods[index];
        final isSelected = state.selectedMethod == method.method;

        return GestureDetector(
          onTap: () =>
              context.read<PaymentCubit>().selectMethod(method.method),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.surface : AppColors.card,
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.border,
                width: isSelected ? 4 : 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  method.icon,
                  size: 32,
                  color:
                      isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
                const SizedBox(height: 8),
                Text(
                  method.label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color:
                        isSelected ? AppColors.primary : AppColors.textPrimary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCashInput(BuildContext context, PaymentState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'AMOUNT PAID',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 12),

        // Amount text field
        Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            border: Border.all(color: AppColors.border, width: 3),
          ),
          child: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: GoogleFonts.spaceGrotesk(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: GoogleFonts.spaceGrotesk(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
              prefixText: 'Rp ',
              prefixStyle: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 20,
              ),
            ),
            onChanged: (value) {
              final amount = double.tryParse(value) ?? 0;
              context.read<PaymentCubit>().setAmountPaid(amount);
            },
          ),
        ),
        const SizedBox(height: 12),

        // Quick amount buttons
        _buildQuickAmountButtons(context, state),
        const SizedBox(height: 16),

        // Change display
        if (state.amountPaid != null && state.amountPaid! > 0)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: state.changeAmount > 0
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              border: Border.all(
                color: state.changeAmount > 0
                    ? AppColors.success
                    : AppColors.error,
                width: 3,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'CHANGE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppConstants.formatCurrency(state.changeAmount),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: state.changeAmount > 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQrisSuccessScreen(BuildContext context, PaymentState state) {
    final settingsCubit = context.read<SettingsCubit>();
    final qrisPath = settingsCubit.state.qrisImagePath;
    
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'SCAN TO PAY',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              AppConstants.formatCurrency(state.totalAmount),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border.all(color: AppColors.border, width: 4),
                boxShadow: [
                  BoxShadow(color: AppColors.shadow, offset: const Offset(8, 8), blurRadius: 0),
                ],
              ),
              child: (qrisPath != null && qrisPath.isNotEmpty && File(qrisPath).existsSync())
                  ? Image.file(
                      File(qrisPath),
                      height: 300,
                      fit: BoxFit.contain,
                    )
                  : Container(
                      height: 300,
                      width: 300,
                      color: AppColors.background,
                      child: Center(
                        child: Text(
                          'No QRIS Image uploaded.\nPlease upload it in Settings.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 300,
              child: BrutalButton(
                text: 'DONE / HOME',
                icon: Icons.home,
                height: 64,
                fontSize: 20,
                onPressed: () {
                  context.read<CartCubit>().clearCart();
                  triggerGlobalRefresh();
                  context.go('/home');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountButtons(BuildContext context, PaymentState state) {
    final l10n = AppLocalizations.of(context);
    final quickAmounts = <_QuickAmount>[
      _QuickAmount(l10n.exact, state.totalAmount),
      _QuickAmount('50K', 50000),
      _QuickAmount('100K', 100000),
      _QuickAmount('150K', 150000),
      _QuickAmount('200K', 200000),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: quickAmounts.map((qa) {
        return GestureDetector(
          onTap: () {
            _amountController.text = qa.amount.toStringAsFixed(0);
            context.read<PaymentCubit>().setAmountPaid(qa.amount);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.border, width: 3),
            ),
            child: Text(
              qa.label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPayButton(BuildContext context, PaymentState state) {
    final isValid = state.isPaymentValid;
    final isProcessing = state.status == PaymentStatus.processing;

    return BrutalButton(
      text: isProcessing ? 'PROCESSING...' : 'PAY NOW',
      icon: Icons.check_circle_outline,
      height: 64,
      fontSize: 20,
      isLoading: isProcessing,
      onPressed: (isValid && !isProcessing)
          ? () {
              final cartState = context.read<CartCubit>().state;
              context
                  .read<PaymentCubit>()
                  .processPayment(cartState: cartState);
            }
          : null,
    );
  }

  void _showSuccessDialog(
      BuildContext context, PaymentState state, CartState cartState) {
    final l10n = AppLocalizations.of(context);

    // Convert cart items to TransactionItems for receipt generation
    final receiptItems = cartState.items
        .map((item) => TransactionItem(
              transactionId: state.transactionId ?? 0,
              productId: item.product.id!,
              productName: item.product.name,
              quantity: item.quantity,
              unitPrice: item.product.price,
              subtotal: item.subtotal,
            ))
        .toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: AppColors.primary, width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success checkmark
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.15),
                    border: Border.all(
                      color: AppColors.success,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    size: 48,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'PAYMENT SUCCESS',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  AppConstants.formatCurrency(state.totalAmount),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                if (state.selectedMethod == PaymentMethod.cash &&
                    state.changeAmount > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      border: Border.all(
                        color: AppColors.success,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'CHANGE',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                            letterSpacing: 2,
                          ),
                        ),
                        Text(
                          AppConstants.formatCurrency(state.changeAmount),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 8),
                Text(
                  'Transaction #${state.transactionId}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Copy receipt button
                GestureDetector(
                  onTap: () {
                    final receipt = ReceiptService.generateReceipt(
                      transactionId: state.transactionId ?? 0,
                      date: DateTime.now(),
                      items: receiptItems,
                      subtotal: cartState.subtotal,
                      taxPercent: cartState.taxPercent,
                      taxAmount: cartState.taxAmount,
                      discountAmount: cartState.discountAmount,
                      couponCode: cartState.appliedCoupon?.code,
                      total: state.totalAmount,
                      serviceChargeAmount: cartState.serviceChargeAmount,
                      roundUpAmount: state.roundUpAmount,
                      paymentMethod: state.methodLabel,
                      amountPaid: state.amountPaid,
                      changeAmount: state.changeAmount,
                      customerName: cartState.selectedCustomer?.name,
                    );
                    Clipboard.setData(ClipboardData(text: receipt));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n.receiptCopied,
                          style: GoogleFonts.inter(color: AppColors.textPrimary),
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border:
                          Border.all(color: AppColors.border, width: 3),
                      boxShadow: [
                        BoxShadow(
                            color: AppColors.shadow,
                            offset: Offset(3, 3),
                            blurRadius: 0),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long,
                              color: AppColors.textPrimary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            l10n.copyReceipt.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Print Receipt & Share Row
                Row(
                  children: [
                    Expanded(
                      child: BrutalButton(
                        text: l10n.printReceipt,
                        icon: Icons.print,
                        height: 50,
                        fontSize: 14,
                        onPressed: () async {
                          final tx = Transaction(
                            id: state.transactionId,
                            subtotal: cartState.subtotal,
                            taxPercent: cartState.taxPercent,
                            taxAmount: cartState.taxAmount,
                            discountAmount: cartState.discountAmount,
                            total: state.totalAmount,
                            paymentMethod: state.methodLabel,
                            createdAt: DateTime.now(),
                            items: receiptItems,
                            amountPaid: state.amountPaid,
                            changeAmount: state.changeAmount,
                            serviceChargeAmount: cartState.serviceChargeAmount,
                            roundUpAmount: state.roundUpAmount,
                          );
                          await ReceiptPrinter.printReceipt(tx);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BrutalButton(
                        text: 'SHARE/EMAIL',
                        icon: Icons.share,
                        height: 50,
                        fontSize: 14,
                        variant: BrutalButtonVariant.secondary,
                        onPressed: () async {
                          final tx = Transaction(
                            id: state.transactionId,
                            subtotal: cartState.subtotal,
                            taxPercent: cartState.taxPercent,
                            taxAmount: cartState.taxAmount,
                            discountAmount: cartState.discountAmount,
                            total: state.totalAmount,
                            paymentMethod: state.methodLabel,
                            createdAt: DateTime.now(),
                            items: receiptItems,
                            amountPaid: state.amountPaid,
                            changeAmount: state.changeAmount,
                            serviceChargeAmount: cartState.serviceChargeAmount,
                            roundUpAmount: state.roundUpAmount,
                          );
                          final pdfBytes = await ReceiptPrinter.generateReceiptPdf(tx);
                          final file = XFile.fromData(pdfBytes, mimeType: 'application/pdf', name: 'Receipt_${tx.id}.pdf');
                          await Share.shareXFiles([file], text: 'Here is your receipt from ${AppConstants.appName}.');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                BrutalButton(
                  text: 'DONE',
                  icon: Icons.home,
                  onPressed: () {
                    // Clear cart
                    context.read<CartCubit>().clearCart();
                    // Trigger global refresh so Home reloads recent transactions
                    triggerGlobalRefresh();
                    // Close dialog
                    Navigator.of(dialogContext).pop();
                    // Navigate to Home
                    context.go('/home');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQrisSuccessView(BuildContext context, PaymentState state) {
    final formatCurrency = NumberFormat.currency(
        locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final settingsState = context.read<SettingsCubit>().state;
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(40),
                  constraints: const BoxConstraints(maxWidth: 550),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.primary, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadow,
                        offset: const Offset(8, 8),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'SCAN TO PAY',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: 280,
                        height: 280,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          border: Border.all(color: AppColors.border, width: 2),
                        ),
                        child: settingsState.qrisImagePath != null && settingsState.qrisImagePath!.isNotEmpty && File(settingsState.qrisImagePath!).existsSync()
                            ? Image.file(
                                File(settingsState.qrisImagePath!),
                                fit: BoxFit.contain,
                              )
                            : Center(
                                child: Icon(Icons.qr_code_2, size: 200, color: AppColors.surface),
                              ),
                      ),
                      const SizedBox(height: 40),
                      Text(
                        'TOTAL AMOUNT',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatCurrency.format(state.totalAmount),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 260,
                      child: BrutalButton(
                        text: 'PRINT RECEIPT',
                        icon: Icons.print,
                        height: 64,
                        fontSize: 16,
                        onPressed: () async {
                          final cartState = context.read<CartCubit>().state;
                          final receiptItems = cartState.items
                              .map((item) => TransactionItem(
                                    transactionId: state.transactionId ?? 0,
                                    productId: item.product.id!,
                                    productName: item.product.name,
                                    quantity: item.quantity,
                                    unitPrice: item.product.price,
                                    subtotal: item.subtotal,
                                  ))
                              .toList();
                          final tx = Transaction(
                            id: state.transactionId,
                            subtotal: cartState.subtotal,
                            taxPercent: cartState.taxPercent,
                            taxAmount: cartState.taxAmount,
                            discountAmount: cartState.discountAmount,
                            total: state.totalAmount,
                            paymentMethod: 'QRIS',
                            createdAt: DateTime.now(),
                            items: receiptItems,
                            amountPaid: state.totalAmount,
                            changeAmount: 0,
                            serviceChargeAmount: cartState.serviceChargeAmount,
                            roundUpAmount: state.roundUpAmount,
                          );
                          await ReceiptPrinter.printReceipt(tx);
                        },
                      ),
                    ),
                    const SizedBox(width: 30),
                    SizedBox(
                      width: 260,
                      child: BrutalButton(
                        text: 'SHARE/EMAIL',
                        icon: Icons.share,
                        height: 64,
                        fontSize: 16,
                        variant: BrutalButtonVariant.secondary,
                        onPressed: () async {
                          final cartState = context.read<CartCubit>().state;
                          final receiptItems = cartState.items
                              .map((item) => TransactionItem(
                                    transactionId: state.transactionId ?? 0,
                                    productId: item.product.id!,
                                    productName: item.product.name,
                                    quantity: item.quantity,
                                    unitPrice: item.product.price,
                                    subtotal: item.subtotal,
                                  ))
                              .toList();
                          final tx = Transaction(
                            id: state.transactionId,
                            subtotal: cartState.subtotal,
                            taxPercent: cartState.taxPercent,
                            taxAmount: cartState.taxAmount,
                            discountAmount: cartState.discountAmount,
                            total: state.totalAmount,
                            paymentMethod: 'QRIS',
                            createdAt: DateTime.now(),
                            items: receiptItems,
                            amountPaid: state.totalAmount,
                            changeAmount: 0,
                            serviceChargeAmount: cartState.serviceChargeAmount,
                            roundUpAmount: state.roundUpAmount,
                          );
                          final pdfBytes = await ReceiptPrinter.generateReceiptPdf(tx);
                          final file = XFile.fromData(pdfBytes, mimeType: 'application/pdf', name: 'Receipt_${tx.id}.pdf');
                          await Share.shareXFiles([file], text: 'Here is your receipt from ${AppConstants.appName}.');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 550,
                  child: BrutalButton(
                    text: 'BACK TO HOME',
                    icon: Icons.home,
                    onPressed: () {
                      triggerGlobalRefresh();
                      context.read<CartCubit>().clearCart();
                      context.go('/home');
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodInfo {
  final PaymentMethod method;
  final IconData icon;
  final String label;

  _MethodInfo(this.method, this.icon, this.label);
}

class _QuickAmount {
  final String label;
  final double amount;

  _QuickAmount(this.label, this.amount);
}

