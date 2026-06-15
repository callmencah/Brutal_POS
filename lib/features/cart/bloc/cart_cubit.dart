import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/cart_item.dart';
import '../../../data/models/customer.dart';
import '../../../data/models/product.dart';
import '../../../data/repositories/coupon_repository.dart';
import '../../../data/repositories/settings_repository.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final CouponRepository couponRepository;
  final SettingsRepository settingsRepository;

  CartCubit({
    required this.couponRepository,
    required this.settingsRepository,
  }) : super(const CartState());

  Future<void> init() async {
    final taxPercent = await settingsRepository.getTaxPercent();
    final roundUp = await settingsRepository.getRoundUp();
    final serviceChargeEnabled = await settingsRepository.getServiceChargeEnabled();
    final serviceChargePercent = await settingsRepository.getServiceChargePercent();
    emit(state.copyWith(
      taxPercent: taxPercent, 
      roundUpEnabled: roundUp,
      serviceChargeEnabled: serviceChargeEnabled,
      serviceChargePercent: serviceChargePercent,
    ));
  }

  void addItem(Product product) {
    final existingIndex =
        state.items.indexWhere((item) => item.product.id == product.id);

    List<CartItem> updatedItems;

    if (existingIndex >= 0) {
      updatedItems = List<CartItem>.from(state.items);
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] =
          existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updatedItems = [...state.items, CartItem(product: product)];
    }

    emit(state.copyWith(
      items: updatedItems,
      clearCouponError: true,
      clearCouponSuccess: true,
    ));
    _recalculateDiscount();
  }

  void removeItem(int productId) {
    final updatedItems =
        state.items.where((item) => item.product.id != productId).toList();
    emit(state.copyWith(
      items: updatedItems,
      clearCouponError: true,
      clearCouponSuccess: true,
    ));
    _recalculateDiscount();
  }

  void incrementQuantity(int productId) {
    final updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));
    _recalculateDiscount();
  }

  void decrementQuantity(int productId) {
    final List<CartItem> updatedItems = [];

    for (final item in state.items) {
      if (item.product.id == productId) {
        if (item.quantity > 1) {
          updatedItems.add(item.copyWith(quantity: item.quantity - 1));
        }
        // If quantity is 1, don't add it (effectively removes)
      } else {
        updatedItems.add(item);
      }
    }

    emit(state.copyWith(items: updatedItems));
    _recalculateDiscount();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));
    _recalculateDiscount();
  }

  void clearCart() {
    emit(const CartState().copyWith(
      taxPercent: state.taxPercent,
      roundUpEnabled: state.roundUpEnabled,
      serviceChargeEnabled: state.serviceChargeEnabled,
      serviceChargePercent: state.serviceChargePercent,
    ));
  }

  void updateRoundUp(bool enabled) {
    emit(state.copyWith(roundUpEnabled: enabled));
  }

  Future<void> applyCoupon(String code) async {
    if (code.trim().isEmpty) {
      emit(state.copyWith(
        couponError: 'Please enter a coupon code',
        clearCouponSuccess: true,
      ));
      return;
    }

    final coupon = await couponRepository.getCouponByCode(code.trim());

    if (coupon == null) {
      emit(state.copyWith(
        couponError: 'Coupon not found',
        clearCouponSuccess: true,
      ));
      return;
    }

    if (!coupon.isValid) {
      emit(state.copyWith(
        couponError: 'Coupon is expired or has reached its usage limit',
        clearCouponSuccess: true,
      ));
      return;
    }

    final discount = coupon.calculateDiscount(state.subtotal);

    if (discount <= 0) {
      emit(state.copyWith(
        couponError:
            'Minimum purchase of Rp ${coupon.minPurchase.toStringAsFixed(0)} required',
        clearCouponSuccess: true,
      ));
      return;
    }

    emit(state.copyWith(
      appliedCoupon: coupon,
      discountAmount: discount,
      couponSuccess: 'Coupon applied! You save ${_formatDiscount(coupon)}',
      clearCouponError: true,
    ));
  }

  String _formatDiscount(dynamic coupon) {
    if (coupon.discountType == 'percentage') {
      return '${coupon.discountValue.toStringAsFixed(0)}%';
    }
    return 'Rp ${coupon.discountValue.toStringAsFixed(0)}';
  }

  void removeCoupon() {
    emit(state.copyWith(
      clearCoupon: true,
      discountAmount: 0,
      clearCouponError: true,
      clearCouponSuccess: true,
    ));
  }

  void setCustomer(Customer? customer) {
    if (customer == null) {
      emit(state.copyWith(clearCustomer: true));
    } else {
      emit(state.copyWith(selectedCustomer: customer));
    }
  }

  void _recalculateDiscount() {
    if (state.appliedCoupon != null) {
      final discount =
          state.appliedCoupon!.calculateDiscount(state.subtotal);
      emit(state.copyWith(discountAmount: discount));
    }
  }
}

