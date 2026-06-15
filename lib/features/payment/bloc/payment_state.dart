import 'package:equatable/equatable.dart';

enum PaymentStatus { initial, processing, success, error }

enum PaymentMethod { cash, qris, eWallet, card }

class PaymentState extends Equatable {
  final PaymentStatus status;
  final PaymentMethod selectedMethod;
  final double rawTotalAmount;
  final bool roundUpEnabled;
  final double? amountPaid;
  final double changeAmount;
  final int? transactionId;
  final String? error;

  const PaymentState({
    this.status = PaymentStatus.initial,
    this.selectedMethod = PaymentMethod.cash,
    this.rawTotalAmount = 0,
    this.roundUpEnabled = false,
    this.amountPaid,
    this.changeAmount = 0,
    this.transactionId,
    this.error,
  });

  double get totalAmount {
    if (selectedMethod == PaymentMethod.cash && roundUpEnabled) {
      return (rawTotalAmount / 500).ceil() * 500.0;
    }
    return rawTotalAmount;
  }

  double get roundUpAmount {
    return totalAmount - rawTotalAmount;
  }

  bool get isPaymentValid {
    switch (selectedMethod) {
      case PaymentMethod.cash:
        return amountPaid != null && amountPaid! >= totalAmount;
      case PaymentMethod.qris:
      case PaymentMethod.eWallet:
      case PaymentMethod.card:
        return true;
    }
  }

  String get methodLabel {
    switch (selectedMethod) {
      case PaymentMethod.cash:
        return 'cash';
      case PaymentMethod.qris:
        return 'qris';
      case PaymentMethod.eWallet:
        return 'e_wallet';
      case PaymentMethod.card:
        return 'card';
    }
  }

  PaymentState copyWith({
    PaymentStatus? status,
    PaymentMethod? selectedMethod,
    double? rawTotalAmount,
    bool? roundUpEnabled,
    double? amountPaid,
    bool clearAmountPaid = false,
    double? changeAmount,
    int? transactionId,
    String? error,
    bool clearError = false,
  }) {
    return PaymentState(
      status: status ?? this.status,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      rawTotalAmount: rawTotalAmount ?? this.rawTotalAmount,
      roundUpEnabled: roundUpEnabled ?? this.roundUpEnabled,
      amountPaid: clearAmountPaid ? null : (amountPaid ?? this.amountPaid),
      changeAmount: changeAmount ?? this.changeAmount,
      transactionId: transactionId ?? this.transactionId,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        status,
        selectedMethod,
        rawTotalAmount,
        roundUpEnabled,
        amountPaid,
        changeAmount,
        transactionId,
        error,
      ];
}

