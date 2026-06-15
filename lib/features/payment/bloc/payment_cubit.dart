import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/transaction.dart';
import '../../../data/models/transaction_item.dart';
import '../../../data/repositories/coupon_repository.dart';
import '../../../data/repositories/product_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../cart/bloc/cart_state.dart';
import '../../../core/utils/refresh_notifier.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final TransactionRepository transactionRepository;
  final CouponRepository couponRepository;
  final ProductRepository productRepository;

  PaymentCubit({
    required this.transactionRepository,
    required this.couponRepository,
    required this.productRepository,
    required double rawTotalAmount,
    required bool roundUpEnabled,
  }) : super(PaymentState(
          rawTotalAmount: rawTotalAmount,
          roundUpEnabled: roundUpEnabled,
        ));

  void selectMethod(PaymentMethod method) {
    // When switching method, amountPaid should be cleared, and change re-calculated
    emit(state.copyWith(
      selectedMethod: method,
      clearAmountPaid: true,
      changeAmount: 0,
      clearError: true,
    ));
  }

  void setAmountPaid(double amount) {
    final change = amount - state.totalAmount;
    emit(state.copyWith(
      amountPaid: amount,
      changeAmount: change > 0 ? change : 0,
      clearError: true,
    ));
  }

  Future<void> processPayment({required CartState cartState}) async {
    if (!state.isPaymentValid) {
      emit(state.copyWith(error: 'Invalid payment amount'));
      return;
    }

    emit(state.copyWith(status: PaymentStatus.processing, clearError: true));

    try {
      final now = DateTime.now();

      // Determine amount paid for non-cash methods
      final double effectiveAmountPaid;
      final double effectiveChange;

      if (state.selectedMethod == PaymentMethod.cash) {
        effectiveAmountPaid = state.amountPaid ?? cartState.grandTotal;
        effectiveChange = state.changeAmount;
      } else {
        effectiveAmountPaid = cartState.grandTotal;
        effectiveChange = 0;
      }

      // Create Transaction
      final transaction = Transaction(
        customerId: cartState.selectedCustomer?.id,
        subtotal: cartState.subtotal,
        taxPercent: cartState.taxPercent,
        taxAmount: cartState.taxAmount,
        discountAmount: cartState.discountAmount,
        couponCode: cartState.appliedCoupon?.code,
        total: state.totalAmount,
        serviceChargeAmount: cartState.serviceChargeAmount,
        roundUpAmount: state.roundUpAmount,
        paymentMethod: state.methodLabel,
        amountPaid: effectiveAmountPaid,
        changeAmount: effectiveChange,
        createdAt: now,
      );

      // Create TransactionItems from cart
      final transactionItems = cartState.items.map((cartItem) {
        return TransactionItem(
          transactionId: 0, // Will be set by repo
          productId: cartItem.product.id!,
          productName: cartItem.product.name,
          quantity: cartItem.quantity,
          unitPrice: cartItem.product.price,
          subtotal: cartItem.subtotal,
        );
      }).toList();

      // Save to database
      final transactionId = await transactionRepository.saveTransaction(
        transaction,
        transactionItems,
      );

      // Decrement stock for products that have stock tracking
      for (final item in cartState.items) {
        if (item.product.stock != null) {
          await productRepository.decrementStock(
            item.product.id!,
            item.quantity,
          );
        }
      }

      // Increment coupon usage if coupon was used
      if (cartState.appliedCoupon != null) {
        await couponRepository.incrementUsage(cartState.appliedCoupon!.code);
      }

      triggerGlobalRefresh();

      emit(state.copyWith(
        status: PaymentStatus.success,
        transactionId: transactionId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PaymentStatus.error,
        error: 'Payment failed: ${e.toString()}',
      ));
    }
  }
}
