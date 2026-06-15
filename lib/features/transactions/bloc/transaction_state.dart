import 'package:equatable/equatable.dart';
import '../../../data/models/transaction.dart' as model;

enum TransactionListStatus { initial, loading, loaded, error }

enum TransactionFilter { today, thisWeek, thisMonth, all }

class TransactionListState extends Equatable {
  final TransactionListStatus status;
  final List<model.Transaction> transactions;
  final TransactionFilter filter;
  final String? error;

  const TransactionListState({
    this.status = TransactionListStatus.initial,
    this.transactions = const [],
    this.filter = TransactionFilter.today,
    this.error,
  });

  TransactionListState copyWith({
    TransactionListStatus? status,
    List<model.Transaction>? transactions,
    TransactionFilter? filter,
    String? Function()? error,
  }) {
    return TransactionListState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      filter: filter ?? this.filter,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [status, transactions, filter, error];
}

