import 'package:equatable/equatable.dart';
import '../../../data/models/customer.dart';

class CustomerState extends Equatable {
  final List<Customer> customers;
  final bool isLoading;
  final String? error;
  final String searchQuery;
  final List<Customer> filteredCustomers;

  const CustomerState({
    this.customers = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
    this.filteredCustomers = const [],
  });

  CustomerState copyWith({
    List<Customer>? customers,
    bool? isLoading,
    String? Function()? error,
    String? searchQuery,
    List<Customer>? filteredCustomers,
  }) {
    return CustomerState(
      customers: customers ?? this.customers,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
      searchQuery: searchQuery ?? this.searchQuery,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
    );
  }

  /// Returns filtered customers if a search query is active, otherwise all customers.
  List<Customer> get displayedCustomers {
    if (searchQuery.isEmpty) return customers;
    return filteredCustomers;
  }

  @override
  List<Object?> get props =>
      [customers, isLoading, error, searchQuery, filteredCustomers];
}

