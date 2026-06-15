import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/product_repository.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository productRepository;

  ProductCubit({required this.productRepository})
      : super(const ProductState());

  Future<void> loadProducts() async {
    emit(state.copyWith(status: ProductStatus.loading));
    try {
      final products = await productRepository.getAllProducts();
      final categories = await productRepository.getAllCategories();
      emit(state.copyWith(
        status: ProductStatus.loaded,
        products: products,
        filteredProducts: products,
        categories: categories,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductStatus.error,
        error: () => e.toString(),
      ));
    }
  }

  void filterByCategory(int? categoryId) {
    emit(state.copyWith(
      selectedCategoryId: () => categoryId,
    ));
    _applyFilters();
  }

  void searchProducts(String query) {
    emit(state.copyWith(searchQuery: query));
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = List.of(state.products);

    if (state.selectedCategoryId != null) {
      filtered = filtered
          .where((p) => p.categoryId == state.selectedCategoryId)
          .toList();
    }

    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    }

    emit(state.copyWith(filteredProducts: filtered));
  }
}

