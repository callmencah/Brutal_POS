import 'package:equatable/equatable.dart';
import '../../../data/models/coupon.dart';

class CouponManageState extends Equatable {
  final List<Coupon> coupons;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  const CouponManageState({
    this.coupons = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  CouponManageState copyWith({
    List<Coupon>? coupons,
    bool? isLoading,
    String? Function()? error,
    String? Function()? successMessage,
  }) {
    return CouponManageState(
      coupons: coupons ?? this.coupons,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      successMessage:
          successMessage != null ? successMessage() : this.successMessage,
    );
  }

  @override
  List<Object?> get props => [coupons, isLoading, error, successMessage];
}

