/// fashion_store/lib/models/order_model.dart
///
/// Represents a completed order saved after the customer confirms checkout.
///
/// Document structure:
/// ```
/// orders/{orderId}
///   ├── orderId         : String
///   ├── userId          : String  (your own user ID, not Firebase UID)
///   ├── items           : Array<Map>  (serialised CartItemModel objects)
///   ├── totalAmount     : Number
///   ├── deliveryAddress : String
///   ├── phone           : String
///   ├── orderDate       : String  (ISO 8601 format)
///   └── status          : String  (e.g. "Pending", "Shipped", "Delivered")
/// ```

import 'package:fashion_store/models/cart_item_model.dart';
import 'package:fashion_store/utils/app_constants.dart';

class OrderModel {
  // ─── Fields ───────────────────────────────────────────────────────────────

  /// The order document ID.
  final String orderId;

  /// The ID of the customer who placed this order.
  final String userId;

  /// Snapshot of all cart items at the time of purchase.
  final List<CartItemModel> items;

  /// The grand total for the order (sum of all item subtotals).
  final double totalAmount;

  /// The full delivery address entered on the [CheckoutScreen].
  final String deliveryAddress;

  /// The contact phone number entered on the [CheckoutScreen].
  final String phone;

  /// The UTC timestamp when the order was placed.
  final DateTime orderDate;

  /// Current fulfilment status. Defaults to [AppConstants.orderStatusPending].
  final String status;

  // ─── Constructor ──────────────────────────────────────────────────────────

  const OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.phone,
    required this.orderDate,
    required this.status,
  });

  // ─── Factory — from JSON ───────────────────────────────────────────────────

  /// Creates an [OrderModel] from a JSON map.
  ///
  /// [id] is the order ID, passed separately as a named parameter.
  /// The [orderDate] field is stored as an ISO 8601 string and
  /// converted to a Dart [DateTime] here for convenient use in the UI.
  factory OrderModel.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) {
    // Parse orderDate from ISO 8601 string
    final orderDate = json['orderDate'] != null
        ? DateTime.parse(json['orderDate'] as String)
        : DateTime.now();

    // Deserialise the embedded items array.
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return OrderModel(
      orderId: id,
      userId: json['userId'] as String? ?? '',
      items: items,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      deliveryAddress: json['deliveryAddress'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      orderDate: orderDate,
      status: json['status'] as String? ?? AppConstants.orderStatusPending,
    );
  }

  // ─── Serialise to JSON ─────────────────────────────────────────────────────

  /// Converts this model to a plain JSON-compatible Map.
  ///
  /// [orderDate] is written as an ISO 8601 string for easy storage
  /// and sorting.
  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      // Each CartItemModel is converted to its own JSON map.
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'phone': phone,
      'orderDate': orderDate.toIso8601String(),
      'status': status,
    };
  }

  // ─── Computed Properties ──────────────────────────────────────────────────

  /// Total number of individual units across all line items.
  int get totalItemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  // ─── Equality & Debug ─────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel &&
          runtimeType == other.runtimeType &&
          orderId == other.orderId;

  @override
  int get hashCode => orderId.hashCode;

  @override
  String toString() =>
      'OrderModel(orderId: $orderId, userId: $userId, total: $totalAmount, status: $status)';
}