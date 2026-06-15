import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/coupon.dart';
import '../../../data/repositories/coupon_repository.dart';
import 'coupon_state.dart';

class CouponManageCubit extends Cubit<CouponManageState> {
  final CouponRepository repository;

  CouponManageCubit({required this.repository})
      : super(const CouponManageState());

  Future<void> loadCoupons() async {
    emit(state.copyWith(isLoading: true));
    try {
      final coupons = await repository.getAllCoupons();
      emit(state.copyWith(
        coupons: coupons,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      ));
    }
  }

  Future<void> addCoupon(Coupon coupon) async {
    try {
      await repository.addCoupon(coupon);
      emit(state.copyWith(successMessage: () => 'Coupon added successfully'));
      await loadCoupons();
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  Future<void> toggleCouponStatus(int id, bool isActive) async {
    try {
      final coupon = state.coupons.firstWhere((c) => c.id == id);
      final updated = coupon.copyWith(isActive: isActive);
      await repository.updateCoupon(updated);
      await loadCoupons();
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  Future<void> deleteCoupon(int id) async {
    try {
      await repository.deactivateCoupon(id);
      await loadCoupons();
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }
}

