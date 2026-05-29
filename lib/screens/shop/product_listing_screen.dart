/// fashion_store/lib/screens/shop/product_listing_screen.dart
///
/// Displays all products for a selected category in a 2-column grid.
///
/// Receives [initialCategory] from [HomeScreen]'s category chip tap.
/// The user can change the active category using the horizontal chip row
/// at the top without navigating away — the grid updates in place.
///
/// Data flow:
///   • On mount, calls [ProductProvider.selectCategory(initialCategory)].
///   • Watches [ProductProvider.filteredProducts] and rebuilds the grid
///     whenever the category changes or data refreshes.
///   • Pull-to-refresh triggers [ProductProvider.refreshProducts()].

import 'package:fashion_store/providers/product_provider.dart';
import 'package:fashion_store/utils/app_constants.dart';
import 'package:fashion_store/utils/app_theme.dart';
import 'package:fashion_store/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductListingScreen extends StatefulWidget {
  /// The category that should be active when this screen opens.
  final String initialCategory;

  const ProductListingScreen({
    super.key,
    required this.initialCategory,
  });

  @override
  State<ProductListingScreen> createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  @override
  void initState() {
    super.initState();
    // Apply the initial category filter after the first frame to avoid
    // calling notifyListeners during a build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().selectCategory(widget.initialCategory);
    });
  }

  Future<void> _onRefresh() async {
    await context.read<ProductProvider>().refreshProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Category Chip Row ──────────────────────────────────────────
          _buildCategoryRow(context),

          // ── Product Grid ───────────────────────────────────────────────
          Expanded(
            child: _buildGrid(context),
          ),
        ],
      ),
    );
  }

  // ─── Category Chip Row ────────────────────────────────────────────────────

  Widget _buildCategoryRow(BuildContext context) {
    // Watch selectedCategory to highlight the active chip.
    final selectedCategory = context.select<ProductProvider, String>(
      (p) => p.selectedCategory,
    );

    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: AppConstants.productCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = AppConstants.productCategories[index];
          final isSelected = category == selectedCategory;

          return ChoiceChip(
            label: Text(category),
            selected: isSelected,
            selectedColor: AppTheme.primaryColor,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textPrimaryColor,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            side: BorderSide(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.dividerColor,
            ),
            onSelected: (_) {
              context.read<ProductProvider>().selectCategory(category);
            },
          );
        },
      ),
    );
  }

  // ─── Product Grid ─────────────────────────────────────────────────────────

  Widget _buildGrid(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    // Show a spinner while data is being fetched for the first time.
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show an error message if the fetch failed.
    if (provider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.textSecondaryColor,
              ),
              const SizedBox(height: 12),
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    final products = provider.filteredProducts;

    // Show an empty-state illustration if there are no products in the category.
    if (products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'No products in this category yet.',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppTheme.primaryColor,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemBuilder: (context, index) => ProductCard(product: products[index]),
      ),
    );
  }
}
