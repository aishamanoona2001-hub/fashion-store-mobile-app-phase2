/// fashion_store/lib/screens/cart/cart_screen.dart
///
/// Displays all items currently in the shopping cart.
///
/// Layout (top → bottom):
///   • AppBar with item count badge.
///   • Scrollable list of cart items — each with image, title, price,
///     quantity selector (− / +), and a remove button.
///   • Sticky bottom bar showing the grand total + "Proceed to Checkout".
///
/// Cart operations:
///   • Increment / decrement quantity via [CartProvider].
///   • Swipe-to-dismiss or tap the trash icon to remove an item.
///   • "Proceed to Checkout" navigates to [CheckoutScreen].

import 'package:cached_network_image/cached_network_image.dart';
import 'package:fashion_store/providers/cart_provider.dart';
import 'package:fashion_store/screens/checkout/checkout_screen.dart';
import 'package:fashion_store/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('My Cart (${cart.totalQuantity})'),
        automaticallyImplyLeading: false,
      ),
      body: cart.itemList.isEmpty
          ? _buildEmptyState(context)
          : Column(
              children: [
                // ── Item List ────────────────────────────────────────────
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.itemList.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.itemList[index];
                      return _CartItemCard(
                        key: ValueKey(item.productId),
                        productId: item.productId,
                        title: item.title,
                        price: item.price,
                        imageUrl: item.imageUrl,
                        quantity: item.quantity,
                        subtotal: item.subtotal,
                      );
                    },
                  ),
                ),

                // ── Bottom Bar ───────────────────────────────────────────
                _buildBottomBar(context, cart),
              ],
            ),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppTheme.dividerColor,
          ),
          const SizedBox(height: 20),
          Text(
            'Your cart is empty',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Add some products to get started.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  // ─── Bottom Bar ───────────────────────────────────────────────────────────

  Widget _buildBottomBar(BuildContext context, CartProvider cart) {
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
          // ── Total ──────────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '\$${cart.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.accentColor,
                    ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          // ── Checkout Button ────────────────────────────────────────────
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CheckoutScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Cart Item Card ────────────────────────────────────────────────────────────

class _CartItemCard extends StatelessWidget {
  final String productId;
  final String title;
  final double price;
  final String imageUrl;
  final int quantity;
  final double subtotal;

  const _CartItemCard({
    super.key,
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.quantity,
    required this.subtotal,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // ── Product Image ────────────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.dividerColor,
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  color: AppTheme.dividerColor,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ── Title + Price + Controls ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Remove button
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w600),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Remove button
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: AppTheme.accentColor,
                          size: 20,
                        ),
                        onPressed: () => cart.removeItem(productId),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Unit price
                  Text(
                    '\$${price.toStringAsFixed(2)} each',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  const SizedBox(height: 8),

                  // Quantity selector + subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // ── − / qty / + ──────────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.dividerColor),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            _QtyButton(
                              icon: Icons.remove,
                              onTap: () => cart.decrementQuantity(productId),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                '$quantity',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            _QtyButton(
                              icon: Icons.add,
                              onTap: () => cart.incrementQuantity(productId),
                            ),
                          ],
                        ),
                      ),

                      // ── Subtotal ─────────────────────────────────────
                      Text(
                        '\$${subtotal.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quantity Button ───────────────────────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 16, color: AppTheme.primaryColor),
      ),
    );
  }
}