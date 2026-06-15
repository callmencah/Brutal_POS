import 'package:equatable/equatable.dart';

import 'transaction_item.dart';

class Transaction extends Equatable {
  final int? id;
  final int? customerId;
  final double subtotal;
  final double taxPercent;
  final double taxAmount;
  final double discountAmount;
  final String? couponCode;
  final double total;
  final double serviceChargeAmount;
  final double roundUpAmount;
  final String paymentMethod;
  final double? amountPaid;
  final double changeAmount;
  final DateTime createdAt;
  final List<TransactionItem>? items;
  final String status;
  final DateTime? voidedAt;
  final String? voidReason;

  const Transaction({
    this.id,
    this.customerId,
    required this.subtotal,
    required this.taxPercent,
    required this.taxAmount,
    this.discountAmount = 0.0,
    this.couponCode,
    required this.total,
    this.serviceChargeAmount = 0.0,
    this.roundUpAmount = 0.0,
    required this.paymentMethod,
    this.amountPaid,
    this.changeAmount = 0.0,
    required this.createdAt,
    this.items,
    this.status = 'completed',
    this.voidedAt,
    this.voidReason,
  });

  factory Transaction.fromMap(Map<String, dynamic> map,
      {List<TransactionItem>? items}) {
    return Transaction(
      id: map['id'] as int?,
      customerId: map['customer_id'] as int?,
      subtotal: (map['subtotal'] as num).toDouble(),
      taxPercent: (map['tax_percent'] as num).toDouble(),
      taxAmount: (map['tax_amount'] as num).toDouble(),
      discountAmount: (map['discount_amount'] as num?)?.toDouble() ?? 0.0,
      couponCode: map['coupon_code'] as String?,
      total: (map['total'] as num).toDouble(),
      serviceChargeAmount: (map['service_charge_amount'] as num?)?.toDouble() ?? 0.0,
      roundUpAmount: (map['round_up_amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: map['payment_method'] as String,
      amountPaid: (map['amount_paid'] as num?)?.toDouble(),
      changeAmount: (map['change_amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(map['created_at'] as String),
      items: items,
      status: map['status'] as String? ?? 'completed',
      voidedAt: map['voided_at'] != null
          ? DateTime.parse(map['voided_at'] as String)
          : null,
      voidReason: map['void_reason'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'customer_id': customerId,
      'subtotal': subtotal,
      'tax_percent': taxPercent,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'coupon_code': couponCode,
      'total': total,
      'service_charge_amount': serviceChargeAmount,
      'round_up_amount': roundUpAmount,
      'payment_method': paymentMethod,
      'amount_paid': amountPaid,
      'change_amount': changeAmount,
      'created_at': createdAt.toIso8601String(),
      'status': status,
      'voided_at': voidedAt?.toIso8601String(),
      'void_reason': voidReason,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Transaction copyWith({
    int? id,
    int? customerId,
    double? subtotal,
    double? taxPercent,
    double? taxAmount,
    double? discountAmount,
    String? couponCode,
    double? total,
    double? serviceChargeAmount,
    double? roundUpAmount,
    String? paymentMethod,
    double? amountPaid,
    double? changeAmount,
    DateTime? createdAt,
    List<TransactionItem>? items,
    String? status,
    DateTime? voidedAt,
    String? voidReason,
  }) {
    return Transaction(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      subtotal: subtotal ?? this.subtotal,
      taxPercent: taxPercent ?? this.taxPercent,
      taxAmount: taxAmount ?? this.taxAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      couponCode: couponCode ?? this.couponCode,
      total: total ?? this.total,
      serviceChargeAmount: serviceChargeAmount ?? this.serviceChargeAmount,
      roundUpAmount: roundUpAmount ?? this.roundUpAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      changeAmount: changeAmount ?? this.changeAmount,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      status: status ?? this.status,
      voidedAt: voidedAt ?? this.voidedAt,
      voidReason: voidReason ?? this.voidReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        subtotal,
        taxPercent,
        taxAmount,
        discountAmount,
        couponCode,
        total,
        serviceChargeAmount,
        roundUpAmount,
        paymentMethod,
        amountPaid,
        changeAmount,
        createdAt,
        items,
        status,
        voidedAt,
        voidReason,
      ];
}

