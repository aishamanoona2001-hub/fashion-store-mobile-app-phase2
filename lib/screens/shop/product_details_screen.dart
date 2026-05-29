/// fashion_store/lib/screens/shop/product_details_screen.dart
///
/// Full-screen detail view for a single [ProductModel].
///
/// Layout (top → bottom):
///   • Hero-animated product image (links to the same tag used in ProductCard).
///   • Product title, price, and category badge.
///   • Scrollable description text.
///   • Sticky bottom bar with quantity selector and "Add to Cart" button.
///
/// Cart integration:
///   • Reads [CartProvider] to show whether the item is already in the cart.
///   • "Add to Cart" calls [CartProvider.addItem] and shows a confirmation
///     [SnackBar] with a shortcut to the cart tab.
///
/// The [product] is passed directly from [ProductCard] so no additional
/// Firestore fetch is needed on this screen.

import 'package:fashion_store/models/product_model.dart';
import 'package:fashion_store/providers/cart_provider.dart';
import 'package:fashion_store/providers/navigation_provider.dart';
import 'package:fashion_store/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  /// The quantity the user wants to add (default 1).
  int _quantity = 1;

  ProductModel get _product => widget.product;

  // ─── Actions ──────────────────────────────────────────────────────────────

  void _addToCart() {
    context.read<CartProvider>().addItem(_product, quantity: _quantity);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_product.title} added to cart!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryColor,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: Colors.white,
          onPressed: () {
            // Switch to the Cart tab (index 1), then pop back to the root.
            context.read<NavigationProvider>().setIndex(1);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _buildCircleBackButton(context),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Product Image ──────────────────────────────────────
                  _buildProductImage(),

                  const SizedBox(height: 20),

                  // ── Product Info ───────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryBadge(context),
                        const SizedBox(height: 8),
                        _buildTitleAndPrice(context),
                        const SizedBox(height: 16),
                        _buildDivider(),
                        const SizedBox(height: 16),
                        _buildDescription(context),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Sticky Bottom Bar ──────────────────────────────────────────
          _buildBottomBar(context),
        ],
      ),
    );
  }

  // ─── Sub-Widgets ──────────────────────────────────────────────────────────

  Widget _buildCircleBackButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 20,
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.primaryColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// Full-width product image using Image.network (web compatible).
  Widget _buildProductImage() {
    return SizedBox(
      width: double.infinity,
      height: 320,
      child: Image.network(
        _product.imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppTheme.dividerColor,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
                strokeWidth: 2,
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => Container(
          color: AppTheme.dividerColor,
          child: const Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 64,
              color: AppTheme.textSecondaryColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _product.category,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildTitleAndPrice(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            _product.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 22,
                ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '\$${_product.price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.accentColor,
                fontSize: 22,
              ),
        ),
      ],
    );
  }

  Widget _buildDivider() => const Divider(color: AppTheme.dividerColor);

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          _product.description,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.6,
                color: AppTheme.textSecondaryColor,
              ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final isInCart = context.select<CartProvider, bool>(
      (cart) => cart.containsProduct(_product.id),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Quantity Selector ──────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildQtyButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    '$_quantity',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                _buildQtyButton(
                  icon: Icons.add,
                  onTap: () => setState(() => _quantity++),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // ── Add to Cart Button ─────────────────────────────────────────
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _addToCart,
              icon: Icon(
                isInCart
                    ? Icons.shopping_cart
                    : Icons.shopping_cart_outlined,
              ),
              label: Text(isInCart ? 'Add More' : 'Add to Cart'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Icon(icon, size: 18, color: AppTheme.primaryColor),
      ),
    );
  }
}