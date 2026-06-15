import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/transaction.dart' as model;
import '../../data/repositories/product_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../core/utils/refresh_notifier.dart';
import '../../core/services/telegram_service.dart';

class TransactionDetailScreen extends StatefulWidget {
  final String transactionId;

  const TransactionDetailScreen({super.key, required this.transactionId});

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  final TransactionRepository _repo = TransactionRepository();
  final ProductRepository _productRepo = ProductRepository();
  model.Transaction? _transaction;
  bool _isLoading = true;
  bool _isVoiding = false;

  @override
  void initState() {
    super.initState();
    _loadTransaction();
  }

  Future<void> _loadTransaction() async {
    try {
      final id = int.parse(widget.transactionId);
      final tx = await _repo.getTransactionById(id);
      if (mounted) {
        setState(() {
          _transaction = tx;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showVoidDialog() async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: AppColors.error, width: 3),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VOID TRANSACTION',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.error,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'This action cannot be undone. The transaction will be marked as voided and stock will be restored.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'REASON (OPTIONAL)',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.border, width: 3),
                  ),
                  child: TextField(
                    controller: reasonController,
                    maxLines: 3,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter void reason...',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(false),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            border:
                                Border.all(color: AppColors.border, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(dialogContext).pop(true),
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            border: Border.all(color: AppColors.shadow, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'VOID',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmed == true && _transaction != null) {
      setState(() => _isVoiding = true);
      try {
        final reason = reasonController.text.trim().isEmpty
            ? 'No reason provided'
            : reasonController.text.trim();

        await _repo.voidTransaction(_transaction!.id!, reason);

        // Send telegram notification
        TelegramService.sendVoidNotification(_transaction!.id!, reason, _transaction!.total);

        // Restore stock for items in the voided transaction
        if (_transaction!.items != null) {
          for (final item in _transaction!.items!) {
            await _productRepo.restoreStock(item.productId, item.quantity);
          }
        }

        // Reload transaction
        await _loadTransaction();
        triggerGlobalRefresh();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Transaction voided successfully',
                style: GoogleFonts.inter(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to void transaction: ${e.toString()}',
                style: GoogleFonts.inter(color: AppColors.textPrimary),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isVoiding = false);
        }
      }
    }
    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'TXN #${widget.transactionId.padLeft(4, '0')}',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : _transaction == null
              ? Center(
                  child: Text('Transaction not found',
                      style:
                          GoogleFonts.inter(color: AppColors.textSecondary)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status + date
                      _buildStatusCard(),
                      const SizedBox(height: 16),

                      // Void info (if voided)
                      if (_transaction!.status == 'voided')
                        _buildVoidInfoCard(),
                      if (_transaction!.status == 'voided')
                        const SizedBox(height: 16),

                      // Items
                      Text(
                        'ITEMS',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.shadow,
                                offset: Offset(4, 4),
                                blurRadius: 0),
                          ],
                        ),
                        child: Column(
                          children: [
                            if (_transaction!.items != null)
                              ...(_transaction!.items!.map((item) => Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: AppColors.border, width: 2),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item.productName,
                                                style: GoogleFonts.inter(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AppColors.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${item.quantity}x ${AppConstants.formatCurrency(item.unitPrice)}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 13,
                                                  color:
                                                      AppColors.textSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          AppConstants.formatCurrency(
                                              item.subtotal),
                                          style: GoogleFonts.spaceGrotesk(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Summary
                      Text(
                        'SUMMARY',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border.all(color: AppColors.border, width: 3),
                          boxShadow: [
                            BoxShadow(
                                color: AppColors.shadow,
                                offset: Offset(4, 4),
                                blurRadius: 0),
                          ],
                        ),
                        child: Column(
                          children: [
                            _SummaryRow(
                                label: 'Subtotal',
                                value: AppConstants.formatCurrency(
                                    _transaction!.subtotal)),
                            if (_transaction!.discountAmount > 0) ...[
                              const SizedBox(height: 8),
                              _SummaryRow(
                                label:
                                    'Discount${_transaction!.couponCode != null ? ' (${_transaction!.couponCode})' : ''}',
                                value:
                                    '-${AppConstants.formatCurrency(_transaction!.discountAmount)}',
                                valueColor: AppColors.success,
                              ),
                            ],
                            const SizedBox(height: 8),
                            _SummaryRow(
                              label:
                                  'Tax (${_transaction!.taxPercent.toStringAsFixed(0)}%)',
                              value: AppConstants.formatCurrency(
                                  _transaction!.taxAmount),
                            ),
                            if (_transaction!.serviceChargeAmount > 0) ...[
                              const SizedBox(height: 8),
                              _SummaryRow(
                                label: 'Service Charge',
                                value: AppConstants.formatCurrency(_transaction!.serviceChargeAmount),
                              ),
                            ],
                            if (_transaction!.roundUpAmount > 0) ...[
                              const SizedBox(height: 8),
                              _SummaryRow(
                                label: 'Round Up',
                                value: AppConstants.formatCurrency(_transaction!.roundUpAmount),
                              ),
                            ],
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              height: 3,
                              color: AppColors.border,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'GRAND TOTAL',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  AppConstants.formatCurrency(
                                      _transaction!.total),
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: _transaction!.status == 'voided'
                                        ? AppColors.textSecondary
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            if (_transaction!.paymentMethod.toLowerCase() ==
                                'cash') ...[
                              const SizedBox(height: 12),
                              _SummaryRow(
                                label: 'Amount Paid',
                                value: AppConstants.formatCurrency(
                                    _transaction!.amountPaid ?? 0),
                              ),
                              const SizedBox(height: 8),
                              _SummaryRow(
                                label: 'Change',
                                value: AppConstants.formatCurrency(
                                    _transaction!.changeAmount),
                                valueColor: AppColors.secondary,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Void button (only for completed transactions)
                      if (_transaction!.status == 'completed')
                        _buildVoidButton(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatusCard() {
    final isVoided = _transaction!.status == 'voided';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border, width: 3),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              offset: Offset(4, 4),
              blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isVoided ? AppColors.error : AppColors.success,
                  border: Border.all(color: AppColors.shadow, width: 2),
                ),
                child: Text(
                  isVoided ? 'VOIDED' : 'COMPLETED',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: isVoided ? AppColors.textPrimary : Colors.black,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _transaction!.paymentMethod.toUpperCase(),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppConstants.formatDateTime(_transaction!.createdAt),
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoidInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.08),
        border: Border.all(color: AppColors.error, width: 3),
        boxShadow: [
          BoxShadow(
              color: AppColors.shadow,
              offset: Offset(4, 4),
              blurRadius: 0),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VOID DETAILS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          if (_transaction!.voidedAt != null) ...[
            Row(
              children: [
                Icon(Icons.access_time,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Voided at: ${AppConstants.formatDateTime(_transaction!.voidedAt!)}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
          if (_transaction!.voidReason != null &&
              _transaction!.voidReason!.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.notes,
                    size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Reason: ${_transaction!.voidReason}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildVoidButton() {
    return GestureDetector(
      onTap: _isVoiding ? null : _showVoidDialog,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _isVoiding
              ? AppColors.error.withOpacity(0.5)
              : AppColors.error,
          border: Border.all(color: AppColors.shadow, width: 3),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              offset: Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isVoiding) ...[
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: AppColors.textPrimary,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 12),
            ] else ...[
              Icon(Icons.block, color: AppColors.textPrimary, size: 22),
              const SizedBox(width: 12),
            ],
            Text(
              _isVoiding ? 'VOIDING...' : 'VOID TRANSACTION',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

