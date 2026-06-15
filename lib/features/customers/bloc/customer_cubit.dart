import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/customer.dart';
import '../../../data/repositories/customer_repository.dart';
import 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final CustomerRepository repository;

  CustomerCubit({required this.repository}) : super(const CustomerState());

  Future<void> loadCustomers() async {
    emit(state.copyWith(isLoading: true));
    try {
      final customers = await repository.getAllCustomers();
      final filtered = _applySearch(customers, state.searchQuery);
      emit(state.copyWith(
        customers: customers,
        filteredCustomers: filtered,
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: () => e.toString(),
      ));
    }
  }

  Future<void> addCustomer(String name, String? phone) async {
    try {
      final customer = Customer(
        name: name,
        phone: phone,
        createdAt: DateTime.now(),
      );
      await repository.addCustomer(customer);
      await loadCustomers();
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  Future<void> updateCustomer(int id, String name, String? phone) async {
    try {
      final existing = await repository.getCustomerById(id);
      if (existing == null) return;
      final updated = existing.copyWith(name: name, phone: phone);
      await repository.updateCustomer(updated);
      await loadCustomers();
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await repository.deleteCustomer(id);
      await loadCustomers();
    } catch (e) {
      emit(state.copyWith(error: () => e.toString()));
    }
  }

  void searchCustomers(String query) {
    final trimmed = query.trim().toLowerCase();
    final filtered = _applySearch(state.customers, trimmed);
    emit(state.copyWith(
      searchQuery: trimmed,
      filteredCustomers: filtered,
    ));
  }

  List<Customer> _applySearch(List<Customer> customers, String query) {
    if (query.isEmpty) return customers;
    return customers.where((c) {
      final nameLower = c.name.toLowerCase();
      final phoneLower = (c.phone ?? '').toLowerCase();
      return nameLower.contains(query) || phoneLower.contains(query);
    }).toList();
  }
}

