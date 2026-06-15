import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../data/repositories/product_repository.dart';
import '../cart/bloc/cart_cubit.dart';
import '../cart/bloc/cart_state.dart';
import 'bloc/product_cubit.dart';
import 'bloc/product_state.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/product_search_bar.dart';
import 'widgets/product_grid_item.dart';
import '../../core/utils/refresh_notifier.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProductCubit(
        productRepository: ProductRepository(),
      )..loadProducts(),
      child: const _ProductsView(),
    );
  }
}

class _ProductsView extends StatefulWidget {
  const _ProductsView();

  @override
  State<_ProductsView> createState() => _ProductsViewState();
}

class _ProductsViewState extends State<_ProductsView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    globalRefreshNotifier.addListener(_onRefreshNeeded);
  }

  @override
  void dispose() {
    globalRefreshNotifier.removeListener(_onRefreshNeeded);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _onRefreshNeeded() {
    context.read<ProductCubit>().loadProducts();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<ProductCubit>().loadProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'MENU',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, cartState) {
              final count = cartState.totalItems;
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    iconSize: 42,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onPressed: () => context.push('/cart'),
                    icon: Icon(Icons.shopping_cart_rounded,
                        color: AppColors.textPrimary),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        constraints:
                            const BoxConstraints(minWidth: 24, minHeight: 24),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          border: Border.all(color: Colors.black, width: 2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state.status == ProductStatus.loading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state.status == ProductStatus.error) {
            return Center(
              child: Text(
                state.error ?? 'Error loading products',
                style: GoogleFonts.inter(color: AppColors.error),
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CategoryFilterBar(
                categories: state.categories,
                selectedId: state.selectedCategoryId,
                onSelect: (id) {
                  context.read<ProductCubit>().filterByCategory(id);
                },
              ),
              ProductSearchBar(
                onChanged: (query) {
                  context.read<ProductCubit>().searchProducts(query);
                },
              ),
              const SizedBox(height: 4),
              Expanded(
                child: state.filteredProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 48,
                                color:
                                    AppColors.textSecondary.withOpacity(0.5)),
                            const SizedBox(height: 12),
                            Text(
                              'No products found',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          await context.read<ProductCubit>().loadProducts();
                        },
                        color: AppColors.primary,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final crossAxisCount = constraints.maxWidth > 800
                                ? 4
                                : constraints.maxWidth > 600
                                    ? 3
                                    : 2;
                            return GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                childAspectRatio: 0.78,
                              ),
                              itemCount: state.filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = state.filteredProducts[index];
                                return ProductGridItem(
                                  product: product,
                                  onTap: () {
                                    context.read<CartCubit>().addItem(product);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${product.name} added to cart',
                                          style: GoogleFonts.inter(
                                              color: AppColors.textPrimary),
                                        ),
                                        backgroundColor: AppColors.surface,
                                        duration:
                                            const Duration(milliseconds: 800),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
