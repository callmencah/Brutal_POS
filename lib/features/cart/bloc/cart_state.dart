import 'package:equatable/equatable.dart';

import '../../../data/models/cart_item.dart';
import '../../../data/models/coupon.dart';
import '../../../data/models/customer.dart';

class CartState extends Equatable {
  final List<CartItem> items;
  final Coupon? appliedCoupon;
  final double discountAmount;
  final double taxPercent;
  final bool roundUpEnabled;
  final bool serviceChargeEnabled;
  final double serviceChargePercent;
  final Customer? selectedCustomer;
  final String? couponError;
  final String? couponSuccess;

  const CartState({
    this.items = const [],
    this.appliedCoupon,
    this.discountAmount = 0,
    this.taxPercent = 11,
    this.roundUpEnabled = false,
    this.serviceChargeEnabled = false,
    this.serviceChargePercent = 5.0,
    this.selectedCustomer,
    this.couponError,
    this.couponSuccess,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  double get taxAmount => (subtotal - discountAmount) * (taxPercent / 100);

  double get serviceChargeAmount => serviceChargeEnabled ? (subtotal - discountAmount) * (serviceChargePercent / 100) : 0.0;

  double get grandTotal => subtotal - discountAmount + taxAmount + serviceChargeAmount;

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({
    List<CartItem>? items,
    Coupon? appliedCoupon,
    bool clearCoupon = false,
    double? discountAmount,
    double? taxPercent,
    bool? roundUpEnabled,
    bool? serviceChargeEnabled,
    double? serviceChargePercent,
    Customer? selectedCustomer,
    bool clearCustomer = false,
    String? couponError,
    bool clearCouponError = false,
    String? couponSuccess,
    bool clearCouponSuccess = false,
  }) {
    return CartState(
      items: items ?? this.items,
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
      discountAmount: discountAmount ?? this.discountAmount,
      taxPercent: taxPercent ?? this.taxPercent,
      roundUpEnabled: roundUpEnabled ?? this.roundUpEnabled,
      serviceChargeEnabled: serviceChargeEnabled ?? this.serviceChargeEnabled,
      serviceChargePercent: serviceChargePercent ?? this.serviceChargePercent,
      selectedCustomer:
          clearCustomer ? null : (selectedCustomer ?? this.selectedCustomer),
      couponError:
          clearCouponError ? null : (couponError ?? this.couponError),
      couponSuccess:
          clearCouponSuccess ? null : (couponSuccess ?? this.couponSuccess),
    );
  }

  @override
  List<Object?> get props => [
        items,
        appliedCoupon,
        discountAmount,
        taxPercent,
        roundUpEnabled,
        serviceChargeEnabled,
        serviceChargePercent,
        selectedCustomer,
        couponError,
        couponSuccess,
      ];
}

