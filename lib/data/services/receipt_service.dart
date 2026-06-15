import '../models/transaction_item.dart';
import '../../core/constants/app_constants.dart';

class ReceiptService {
  static String generateReceipt({
    required int transactionId,
    required DateTime date,
    required List<TransactionItem> items,
    required double subtotal,
    required double taxPercent,
    required double taxAmount,
    required double discountAmount,
    String? couponCode,
    required double total,
    double serviceChargeAmount = 0,
    double roundUpAmount = 0,
    required String paymentMethod,
    double? amountPaid,
    required double changeAmount,
    String? customerName,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('================================');
    buffer.writeln('        BRUTAL POS');
    buffer.writeln('================================');
    buffer.writeln('TXN #${transactionId.toString().padLeft(4, '0')}');
    buffer.writeln('Date: ${AppConstants.formatDateTime(date)}');
    if (customerName != null) {
      buffer.writeln('Customer: $customerName');
    }
    buffer.writeln('--------------------------------');

    for (final item in items) {
      buffer.writeln(item.productName);
      buffer.writeln(
          '  ${item.quantity}x ${_formatRp(item.unitPrice)}  ${_formatRp(item.subtotal)}');
    }

    buffer.writeln('--------------------------------');
    buffer.writeln('Subtotal:      ${_formatRp(subtotal)}');
    if (discountAmount > 0) {
      buffer.writeln(
          'Discount${couponCode != null ? ' ($couponCode)' : ''}:  -${_formatRp(discountAmount)}');
    }
    buffer.writeln(
        'Tax (${taxPercent.toStringAsFixed(0)}%):       ${_formatRp(taxAmount)}');
    if (serviceChargeAmount > 0) {
      buffer.writeln('Service Charge:  ${_formatRp(serviceChargeAmount)}');
    }
    if (roundUpAmount > 0) {
      buffer.writeln('Round Up:        ${_formatRp(roundUpAmount)}');
    }
    buffer.writeln('================================');
    buffer.writeln('TOTAL:         ${_formatRp(total)}');
    buffer.writeln('================================');
    buffer.writeln('Payment:       ${paymentMethod.toUpperCase()}');
    if (amountPaid != null) {
      buffer.writeln('Paid:          ${_formatRp(amountPaid)}');
      buffer.writeln('Change:        ${_formatRp(changeAmount)}');
    }
    buffer.writeln('');
    buffer.writeln('     Thank you for your');
    buffer.writeln('        purchase!');
    buffer.writeln('================================');

    return buffer.toString();
  }

  static String _formatRp(double amount) {
    return AppConstants.formatCurrency(amount);
  }
}
