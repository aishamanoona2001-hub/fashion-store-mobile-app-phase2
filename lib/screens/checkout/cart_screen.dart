/// fashion_store/lib/screens/checkout/cart_screen.dart
///
/// Displays the customer's shopping cart and allows them to:
///   • Increment / decrement the quantity of each item.
///   • Swipe-to-delete any line item.
///   • See the running grand total.
///   • Navigate to [CheckoutScreen] via "Proceed to Checkout".
///
/// Data flow:
///   • Reads [CartProvider.itemList] for the list.
///   • Reads [CartProvider.totalAmount] for the grand total.
///   • Calls [CartProvider.incrementQuantity], [decrementQuantity],
///     and [removeItem] for mutations — all auto-persist to SharedPreferences.
///
/// Edge cases handled:
///   • Empty cart → shows an illustrated empty-state with a "Shop Now" button.
///   • Cart loading (first launch) → shows a centered spinner.

import 'package:fashion_store/models/cart_item_model.dart';
import 'package:fashion_store/providers/cart_provider.dart';
import 'package:fashion_store/screens/checkout/checkout_screen.dart';
import 'package:fashion_store/utils/app_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    // While SharedPreferences is being read on first launch.
    if (cart.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Cart'),
        automaticallyImplyLeading: false, // Tab screen — no back arrow needed.
        actions: [
          // Only show "Clear All" when the cart has items.
          if (cart.itemCount > 0)
            TextButton.icon(
              onPressed: () => _confirmClearCart(context),
              icon: const Icon(Icons.delete_sweep_outlined, size: 18),
              label: const Text('Clear'),
            ),
        ],
      ),
      body: cart.itemList.isEmpty
          ? _buildEmptyState(context)
          : _buildCartContent(context, cart),
    );
  }

  // ─── Empty State ──────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 96,
              color: AppTheme.dividerColor,
            ),
            const SizedBox(height: 20),
            Text(
              'Your cart is empty',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Browse the store and add items\nyou love to your cart.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Cart Content ─────────────────────────────────────────────────────────

  Widget _buildCartContent(BuildContext context, CartProvider cart) {
    return Column(
      children: [
        // ── Item List ──────────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: cart.itemList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = cart.itemList[index];
              return _CartItemTile(item: item);
            },
          ),
        ),

        // ── Order Summary + Checkout Button ────────────────────────────────
        _buildCheckoutPanel(context, cart),
      ],
    );
  }

  // ─── Checkout Panel ───────────────────────────────────────────────────────

  Widget _buildCheckoutPanel(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
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
      child: Column(
        children: [
          // ── Subtotal Row ─────────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${cart.totalQuantity} item${cart.totalQuantity == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                '\$${cart.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),

          const Divider(height: 24),

          // ── Grand Total Row ──────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '\$${cart.totalAmount.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppTheme.accentColor,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Proceed to Checkout ──────────────────────────────────────
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CheckoutScreen()),
            ),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Proceed to Checkout'),
          ),
        ],
      ),
    );
  }

  // ─── Confirm Clear Dialog ─────────────────────────────────────────────────

  void _confirmClearCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text(
          'This will remove all items from your cart. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            onPressed: () {
              context.read<CartProvider>().clearCart();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

// ─── Cart Item Tile ────────────────────────────────────────────────────────────

/// Individual dismissible cart row.
///
/// Swipe left → red delete background → removes the item.
/// "+" / "−" buttons update quantity in-place.
class _CartItemTile extends StatelessWidget {
  final CartItemModel item;

  const _CartItemTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      // Each key must be unique — use the product ID.
      key: ValueKey(item.productId),
      direction: DismissDirection.endToStart,
      // Red delete background revealed while swiping.
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.accentColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
      ),
      onDismissed: (_) {
        context.read<CartProvider>().removeItem(item.productId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.title} removed from cart.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // ── Product Thumbnail ────────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppTheme.dividerColor,
                  width: 72,
                  height: 72,
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppTheme.dividerColor,
                  width: 72,
                  height: 72,
                  child: const Icon(
                    Icons.broken_image_outlined,
                    color: AppTheme.textSecondaryColor,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // ── Title & Subtotal ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  if (item.quantity > 1)
                    Text(
                      '\$${item.price.toStringAsFixed(2)} each',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(fontSize: 11),
                    ),
                ],
              ),
            ),

            // ── Quantity Controls ────────────────────────────────────
            _QuantityControls(productId: item.productId, quantity: item.quantity),
          ],
        ),
      ),
    );
  }
}

// ─── Quantity Controls ─────────────────────────────────────────────────────────

/// Compact "−  N  +" row for adjusting quantity inside a cart tile.
class _QuantityControls extends StatelessWidget {
  final String productId;
  final int quantity;

  const _QuantityControls({
    required this.productId,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.dividerColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrement — removes item if quantity reaches 0.
          _iconBtn(
            icon: Icons.remove,
            onTap: () => cart.decrementQuantity(productId),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          _iconBtn(
            icon: Icons.add,
            onTap: () => cart.incrementQuantity(productId),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Icon(icon, size: 16, color: AppTheme.primaryColor),
      ),
    );
  }
}
