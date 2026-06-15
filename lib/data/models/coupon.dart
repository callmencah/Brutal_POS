import 'package:equatable/equatable.dart';

class Coupon extends Equatable {
  final int? id;
  final String code;
  final String? description;
  final String discountType;
  final double discountValue;
  final double minPurchase;
  final double? maxDiscount;
  final bool isActive;
  final DateTime? validUntil;
  final int usageLimit;
  final int usageCount;

  const Coupon({
    this.id,
    required this.code,
    this.description,
    required this.discountType,
    required this.discountValue,
    this.minPurchase = 0,
    this.maxDiscount,
    this.isActive = true,
    this.validUntil,
    this.usageLimit = 0,
    this.usageCount = 0,
  });

  bool get isValid =>
      isActive &&
      (validUntil == null || validUntil!.isAfter(DateTime.now())) &&
      (usageLimit == 0 || usageCount < usageLimit);

  double calculateDiscount(double subtotal) {
    if (subtotal < minPurchase) return 0;
    if (discountType == 'percentage') {
      double disc = subtotal * (discountValue / 100);
      if (maxDiscount != null) disc = disc.clamp(0, maxDiscount!);
      return disc;
    }
    return discountValue;
  }

  factory Coupon.fromMap(Map<String, dynamic> map) {
    return Coupon(
      id: map['id'] as int?,
      code: map['code'] as String,
      description: map['description'] as String?,
      discountType: map['discount_type'] as String,
      discountValue: (map['discount_value'] as num).toDouble(),
      minPurchase: (map['min_purchase'] as num?)?.toDouble() ?? 0,
      maxDiscount: (map['max_discount'] as num?)?.toDouble(),
      isActive: (map['is_active'] as int? ?? 1) == 1,
      validUntil: map['valid_until'] != null
          ? DateTime.parse(map['valid_until'] as String)
          : null,
      usageLimit: map['usage_limit'] as int? ?? 0,
      usageCount: map['usage_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'code': code,
      'description': description,
      'discount_type': discountType,
      'discount_value': discountValue,
      'min_purchase': minPurchase,
      'max_discount': maxDiscount,
      'is_active': isActive ? 1 : 0,
      'valid_until': validUntil?.toIso8601String(),
      'usage_limit': usageLimit,
      'usage_count': usageCount,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Coupon copyWith({
    int? id,
    String? code,
    String? description,
    String? discountType,
    double? discountValue,
    double? minPurchase,
    double? maxDiscount,
    bool? isActive,
    DateTime? validUntil,
    int? usageLimit,
    int? usageCount,
  }) {
    return Coupon(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minPurchase: minPurchase ?? this.minPurchase,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      isActive: isActive ?? this.isActive,
      validUntil: validUntil ?? this.validUntil,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        description,
        discountType,
        discountValue,
        minPurchase,
        maxDiscount,
        isActive,
        validUntil,
        usageLimit,
        usageCount,
      ];
}

