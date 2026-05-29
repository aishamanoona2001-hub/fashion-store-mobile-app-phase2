/// fashion_store/lib/screens/profile/order_history_screen.dart
///
/// Displays a chronological list of all orders placed by the current user.
/// Fetches live data from the Firestore `orders` collection.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_store/models/order_model.dart';
import 'package:fashion_store/providers/auth_provider.dart';
import 'package:fashion_store/utils/app_constants.dart';
import 'package:fashion_store/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  // ─── State ────────────────────────────────────────────────────────────────

  late Future<List<OrderModel>> _ordersFuture;
  late String _userId;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _userId = context.read<AppAuthProvider>().userModel?.id ?? '';
    _ordersFuture = _fetchOrders();
  }

  /// Fetches all orders for the current user from Firestore,
  /// ordered by date descending (newest first).
  Future<List<OrderModel>> _fetchOrders() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: _userId)
        .orderBy('orderDate', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      return OrderModel.fromJson(doc.data(), id: doc.id);
    }).toList();
  }

  /// Re-fetches orders — triggered by pull-to-refresh.
  void _onRefresh() {
    setState(() {
      _ordersFuture = _fetchOrders();
    });
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Order History')),
      body: RefreshIndicator(
        onRefresh: () async => _onRefresh(),
        color: AppTheme.primaryColor,
        child: FutureBuilder<List<OrderModel>>(
          future: _ordersFuture,
          builder: (context, snapshot) {
            // ── Loading ────────────────────────────────────────────────
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // ── Error ──────────────────────────────────────────────────
            if (snapshot.hasError) {
              return _buildErrorState(context);
            }

            final orders = snapshot.data ?? [];

            // ── Empty ──────────────────────────────────────────────────
            if (orders.isEmpty) {
              return _buildEmptyState(context);
            }

            // ── Order List ─────────────────────────────────────────────
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _OrderCard(order: orders[index]),
            );
          },
        ),
      ),
    );
  }

  // ─── State Widgets ────────────────────────────────────────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.receipt_long_outlined,
                  size: 80,
                  color: AppTheme.dividerColor,
                ),
                const SizedBox(height: 20),
                Text('No orders yet',
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Your completed orders will appear here.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded,
                size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            Text('Could not load orders.',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Pull down to retry.',
                style: TextStyle(color: AppTheme.textSecondaryColor)),
          ],
        ),
      ),
    );
  }
}

// ─── Order Card ────────────────────────────────────────────────────────────────

class _OrderCard extends StatefulWidget {
  final OrderModel order;
  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard> {
  bool _expanded = false;

  OrderModel get _order => widget.order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Collapsed Header ───────────────────────────────────────────
          InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Order ID + status badge + expand icon
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${_order.orderId.substring(0, 8).toUpperCase()}',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      _StatusBadge(status: _order.status),
                      const SizedBox(width: 8),
                      Icon(
                        _expanded
                            ? Icons.expand_less
                            : Icons.expand_more,
                        color: AppTheme.textSecondaryColor,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Row 2: Date + item count + total
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 13,
                        color: AppTheme.textSecondaryColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a')
                            .format(_order.orderDate),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Text(
                        '${_order.totalItemCount} item${_order.totalItemCount == 1 ? '' : 's'}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '\$${_order.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.accentColor,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded Details ───────────────────────────────────────────
          if (_expanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildItemList(context),
            _buildDeliveryInfo(context),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildItemList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Items',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ..._order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.title}  ×  ${item.quantity}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${item.subtotal.toStringAsFixed(2)}',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 16),
          Text(
            'Delivery Details',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _order.deliveryAddress,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.phone_outlined,
                  size: 16, color: AppTheme.textSecondaryColor),
              const SizedBox(width: 6),
              Text(
                _order.phone,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Status Badge ──────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  Color get _badgeColor {
    switch (status) {
      case AppConstants.orderStatusPending:
        return Colors.amber.shade700;
      case AppConstants.orderStatusProcessing:
        return Colors.blue.shade600;
      case AppConstants.orderStatusShipped:
        return Colors.indigo.shade600;
      case AppConstants.orderStatusDelivered:
        return Colors.green.shade600;
      case AppConstants.orderStatusCancelled:
        return AppTheme.accentColor;
      default:
        return AppTheme.textSecondaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _badgeColor.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _badgeColor,
        ),
      ),
    );
  }
}