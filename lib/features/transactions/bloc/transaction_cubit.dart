import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction.dart' as model;
import '../../../data/repositories/transaction_repository.dart';
import 'transaction_state.dart';

class TransactionCubit extends Cubit<TransactionListState> {
  final TransactionRepository repository;

  TransactionCubit({required this.repository})
      : super(const TransactionListState());

  Future<void> loadTransactions() async {
    emit(state.copyWith(status: TransactionListStatus.loading));
    try {
      final transactions = await _fetchByFilter(state.filter);
      emit(state.copyWith(
        status: TransactionListStatus.loaded,
        transactions: transactions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionListStatus.error,
        error: () => e.toString(),
      ));
    }
  }

  Future<void> setFilter(TransactionFilter filter) async {
    emit(state.copyWith(
      filter: filter,
      status: TransactionListStatus.loading,
    ));
    try {
      final transactions = await _fetchByFilter(filter);
      emit(state.copyWith(
        status: TransactionListStatus.loaded,
        transactions: transactions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionListStatus.error,
        error: () => e.toString(),
      ));
    }
  }

  Future<void> refresh() async {
    await loadTransactions();
  }

  Future<List<model.Transaction>> _fetchByFilter(TransactionFilter filter) async {
    switch (filter) {
      case TransactionFilter.today:
        return await repository.getTransactionsToday();
      case TransactionFilter.thisWeek:
        return await repository.getTransactionsThisWeek();
      case TransactionFilter.thisMonth:
        return await repository.getTransactionsThisMonth();
      case TransactionFilter.all:
        return await repository.getAllTransactions();
    }
  }
}

