/// fashion_store/lib/providers/cart_provider.dart
///
/// Manages the shopping cart state and persists it across app launches
/// using [SharedPreferences].
///
/// State it owns:
///   • A map of `productId → CartItemModel` (O(1) add/remove/update).
///   • A loading flag while the cart is being loaded from local storage.
///
/// Persistence strategy:
///   • On every mutating operation, the cart is serialised to JSON and
///     written to [SharedPreferences] under [AppConstants.cartPrefsKey].
///   • On construction, [_loadCartFromPrefs] is called to rehydrate
///     the cart, so items survive app restarts.
///   • The cart is cleared from local storage after a successful order.
///
/// Why a Map (not a List)?
///   Using `productId` as the key gives O(1) operations for add/remove/
///   update and naturally prevents duplicate entries.

import 'dart:convert';

import 'package:fashion_store/models/cart_item_model.dart';
import 'package:fashion_store/models/product_model.dart';
import 'package:fashion_store/utils/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartProvider extends ChangeNotifier {
  // ─── State ────────────────────────────────────────────────────────────────

  /// Internal map: productId → CartItemModel.
  final Map<String, CartItemModel> _items = {};

  bool _isLoading = true;

  // ─── Constructor ──────────────────────────────────────────────────────────

  CartProvider() {
    // Restore the cart from disk as soon as the provider is created.
    _loadCartFromPrefs();
  }

  // ─── Public Getters ───────────────────────────────────────────────────────

  /// An unmodifiable view of the cart items map.
  Map<String, CartItemModel> get items => Map.unmodifiable(_items);

  /// A flat list of cart items, useful for building [ListView] widgets.
  List<CartItemModel> get itemList => _items.values.toList();

  /// True while the cart is being restored from [SharedPreferences].
  bool get isLoading => _isLoading;

  /// Total number of distinct product lines in the cart.
  int get itemCount => _items.length;

  /// Total number of individual units across all lines (shown on badge).
  int get totalQuantity =>
      _items.values.fold(0, (sum, item) => sum + item.quantity);

  /// Grand total price for all items in the cart.
  double get totalAmount =>
      _items.values.fold(0.0, (sum, item) => sum + item.subtotal);

  /// Returns `true` if the product with [productId] is already in the cart.
  bool containsProduct(String productId) => _items.containsKey(productId);

  /// Returns the [CartItemModel] for [productId], or null if not in cart.
  CartItemModel? getItem(String productId) => _items[productId];

  // ─── Cart Mutations ───────────────────────────────────────────────────────

  /// Adds [product] to the cart.
  ///
  /// • If the product is already in the cart, its quantity is incremented
  ///   by [quantity] (default: 1).
  /// • If it is new, a [CartItemModel] is created with [quantity] units.
  void addItem(ProductModel product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      // Increment existing quantity.
      final existing = _items[product.id]!;
      _items[product.id] = existing.copyWith(
        quantity: existing.quantity + quantity,
      );
    } else {
      // New line item.
      _items[product.id] = CartItemModel.fromProduct(product, quantity: quantity);
    }

    _persistCart();
    notifyListeners();
  }

  /// Removes the cart item for [productId] entirely, regardless of quantity.
  void removeItem(String productId) {
    _items.remove(productId);
    _persistCart();
    notifyListeners();
  }

  /// Increments the quantity of [productId] by 1.
  void incrementQuantity(String productId) {
    if (!_items.containsKey(productId)) return;
    final item = _items[productId]!;
    _items[productId] = item.copyWith(quantity: item.quantity + 1);
    _persistCart();
    notifyListeners();
  }

  /// Decrements the quantity of [productId] by 1.
  ///
  /// If the quantity reaches 0, the item is removed from the cart entirely.
  void decrementQuantity(String productId) {
    if (!_items.containsKey(productId)) return;

    final item = _items[productId]!;
    if (item.quantity <= 1) {
      // Remove the item rather than allowing a zero or negative quantity.
      _items.remove(productId);
    } else {
      _items[productId] = item.copyWith(quantity: item.quantity - 1);
    }

    _persistCart();
    notifyListeners();
  }

  /// Empties the entire cart and clears the persisted data.
  ///
  /// Called by [CheckoutScreen] after a successful order is placed.
  void clearCart() {
    _items.clear();
    _persistCart(); // Writes an empty map to SharedPreferences.
    notifyListeners();
  }

  // ─── Persistence ─────────────────────────────────────────────────────────

  /// Serialises the current cart to JSON and writes it to [SharedPreferences].
  Future<void> _persistCart() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert each CartItemModel to its JSON map, then encode the list.
    final jsonList = _items.values.map((item) => item.toJson()).toList();
    await prefs.setString(AppConstants.cartPrefsKey, jsonEncode(jsonList));
  }

  /// Reads the persisted cart from [SharedPreferences] and populates [_items].
  ///
  /// Called once in the constructor. Sets [_isLoading] to false when done.
  Future<void> _loadCartFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(AppConstants.cartPrefsKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;
        for (final itemJson in decoded) {
          final item = CartItemModel.fromJson(itemJson as Map<String, dynamic>);
          _items[item.productId] = item;
        }
      }
    } catch (e) {
      // If deserialisation fails (e.g. schema change), silently discard the
      // corrupt data rather than crashing the app on startup.
      debugPrint('CartProvider: failed to load persisted cart — $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
