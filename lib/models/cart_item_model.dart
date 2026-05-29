/// fashion_store/lib/models/cart_item_model.dart
///
/// Represents a single line-item inside the customer's shopping cart.
///
/// Design notes:
///   • A [CartItemModel] embeds a snapshot of the [ProductModel] fields
///     (title, price, imageUrl) rather than just the product ID. This means
///     the cart display never needs a secondary Firestore fetch and remains
///     correct even if the product document is updated mid-session.
///   • The cart is persisted locally via [SharedPreferences] as a JSON
///     string, so both [fromJson] and [toJson] are required.
///
/// JSON structure (as stored in SharedPreferences):
/// ```json
/// {
///   "productId"  : "abc123",
///   "title"      : "Classic White Tee",
///   "price"      : 29.99,
///   "imageUrl"   : "https://...",
///   "quantity"   : 2
/// }
/// ```

import 'package:fashion_store/models/product_model.dart';

class CartItemModel {
  // ─── Fields ───────────────────────────────────────────────────────────────

  /// The Firestore document ID of the underlying [ProductModel].
  final String productId;

  /// Snapshot of the product title at the time it was added to the cart.
  final String title;

  /// Snapshot of the product price at the time it was added to the cart.
  final double price;

  /// Snapshot of the product image URL at the time it was added to the cart.
  final String imageUrl;

  /// How many units of this product are in the cart.
  /// Always ≥ 1; removing the last unit removes the item entirely.
  final int quantity;

  // ─── Constructor ──────────────────────────────────────────────────────────

  const CartItemModel({
    required this.productId,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.quantity,
  });

  // ─── Factory — from ProductModel ──────────────────────────────────────────

  /// Convenience factory that creates a [CartItemModel] from a [ProductModel].
  /// [quantity] defaults to 1 when a product is first added to the cart.
  factory CartItemModel.fromProduct(ProductModel product, {int quantity = 1}) {
    return CartItemModel(
      productId: product.id,
      title: product.title,
      price: product.price,
      imageUrl: product.imageUrl,
      quantity: quantity,
    );
  }

  // ─── Factory — from JSON (SharedPreferences / Firestore) ──────────────────

  /// Deserialises a [CartItemModel] from a JSON map.
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: json['productId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 1,
    );
  }

  // ─── Serialise ────────────────────────────────────────────────────────────

  /// Serialises this item to a JSON map for local or remote persistence.
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  // ─── Computed Properties ──────────────────────────────────────────────────

  /// The total price for this line item (price × quantity).
  double get subtotal => price * quantity;

  // ─── copyWith ─────────────────────────────────────────────────────────────

  /// Returns a new [CartItemModel] with an updated [quantity].
  /// Used by [CartProvider] when the user taps "+" or "−".
  CartItemModel copyWith({int? quantity}) {
    return CartItemModel(
      productId: productId,
      title: title,
      price: price,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }

  // ─── Equality & Debug ─────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModel &&
          runtimeType == other.runtimeType &&
          productId == other.productId;

  @override
  int get hashCode => productId.hashCode;

  @override
  String toString() =>
      'CartItemModel(productId: $productId, title: $title, qty: $quantity, subtotal: $subtotal)';
}
