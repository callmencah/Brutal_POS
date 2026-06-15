import 'package:equatable/equatable.dart';
import '../../../data/models/product.dart';
import '../../../data/models/category.dart';

enum ProductStatus { initial, loading, loaded, error }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<Category> categories;
  final int? selectedCategoryId;
  final String searchQuery;
  final String? error;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.filteredProducts = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.error,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    List<Product>? filteredProducts,
    List<Category>? categories,
    int? Function()? selectedCategoryId,
    String? searchQuery,
    String? Function()? error,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId != null
          ? selectedCategoryId()
          : this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      error: error != null ? error() : this.error,
    );
  }

  @override
  List<Object?> get props => [
        status,
        products,
        filteredProducts,
        categories,
        selectedCategoryId,
        searchQuery,
        error,
      ];
}

