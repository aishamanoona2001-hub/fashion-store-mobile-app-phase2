/// fashion_store/lib/screens/checkout/checkout_screen.dart
///
/// The final step before placing an order.
/// Saves the order to Firestore, clears the cart, shows a success dialog.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_store/providers/auth_provider.dart';
import 'package:fashion_store/providers/cart_provider.dart';
import 'package:fashion_store/providers/navigation_provider.dart';
import 'package:fashion_store/utils/app_constants.dart';
import 'package:fashion_store/utils/app_theme.dart';
import 'package:fashion_store/widgets/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // ─── Form State ───────────────────────────────────────────────────────────

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;

  bool _isPlacingOrder = false;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final userModel = context.read<AppAuthProvider>().userModel;
    _addressController =
        TextEditingController(text: userModel?.address ?? '');
    _phoneController =
        TextEditingController(text: userModel?.phone ?? '');
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ─── Place Order ──────────────────────────────────────────────────────────

  Future<void> _placeOrder() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacingOrder = true);

    try {
      final authProvider = context.read<AppAuthProvider>();
      final cartProvider = context.read<CartProvider>();
      final userId = authProvider.userModel?.id ?? '';

      // ── Build the order items list ───────────────────────────────────
      final orderItems = cartProvider.itemList
          .map((item) => item.toJson())
          .toList();

      // ── Save order to Firestore ──────────────────────────────────────
      await FirebaseFirestore.instance.collection('orders').add({
        'userId': userId,
        'items': orderItems,
        'totalAmount': cartProvider.totalAmount,
        'deliveryAddress': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'orderDate': DateTime.now().toIso8601String(),
        'status': AppConstants.orderStatusPending,
      });

      // Clear the cart after successful order.
      cartProvider.clearCart();

      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Failed to place order. Please try again.'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  // ─── Success Dialog ───────────────────────────────────────────────────────

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Order Placed!',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Your order has been received and is being processed.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.read<NavigationProvider>().setIndex(0);
                Navigator.of(ctx).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Back to Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Delivery Details ───────────────────────────────────────
              _buildSectionTitle(context, 'Delivery Details'),
              const SizedBox(height: 12),
              _buildDeliveryForm(),

              const SizedBox(height: 28),

              // ── Order Summary ──────────────────────────────────────────
              _buildSectionTitle(context, 'Order Summary'),
              const SizedBox(height: 12),
              _buildOrderSummary(context, cart),

              const SizedBox(height: 28),

              // ── Grand Total ────────────────────────────────────────────
              _buildTotalRow(context, cart),

              const SizedBox(height: 24),

              // ── Place Order Button ─────────────────────────────────────
              LoadingButton(
                label: 'Place Order',
                isLoading: _isPlacingOrder,
                onPressed: _placeOrder,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sub-Widgets ──────────────────────────────────────────────────────────

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _buildDeliveryForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── Delivery Address ─────────────────────────────────────────
            TextFormField(
              controller: _addressController,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.next,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Delivery Address',
                prefixIcon: Icon(Icons.location_on_outlined),
                alignLabelWithHint: true,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a delivery address.';
                }
                if (value.trim().length < 10) {
                  return 'Please enter a complete address.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Phone Number ─────────────────────────────────────────────
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a phone number.';
                }
                final phoneRegex = RegExp(r'^\+?[\d\s\-]{7,15}$');
                if (!phoneRegex.hasMatch(value.trim())) {
                  return 'Please enter a valid phone number.';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary(BuildContext context, CartProvider cart) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cart.itemList.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final item = cart.itemList[index];
          return ListTile(
            dense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            title: Text(
              item.title,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              'Qty: ${item.quantity}  ×  \$${item.price.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            trailing: Text(
              '\$${item.subtotal.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalRow(BuildContext context, CartProvider cart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Grand Total',
              style: Theme.of(context).textTheme.titleLarge),
          Text(
            '\$${cart.totalAmount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.accentColor,
                ),
          ),
        ],
      ),
    );
  }
}