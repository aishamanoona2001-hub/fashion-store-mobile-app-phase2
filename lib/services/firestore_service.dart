/// fashion_store/lib/services/firestore_service.dart
///
/// A thin, stateless service that handles all data operations for
/// the Fashion Store application — without Firebase/Firestore.
///
/// Responsibilities:
///   ─ Product catalogue  : fetch all, by category, and featured products.
///   ─ User profile       : create, read, and update a customer's profile.
///   ─ Orders             : write a new order and query the user's order history.
///
/// TODO: Replace all mock implementations with your real backend API calls.

import 'package:fashion_store/models/cart_item_model.dart';
import 'package:fashion_store/models/order_model.dart';
import 'package:fashion_store/models/product_model.dart';
import 'package:fashion_store/models/user_model.dart';
import 'package:fashion_store/utils/app_constants.dart';

class FirestoreService {
  // ══════════════════════════════════════════════════════════════════════════
  // SECTION 1 — Product Catalogue
  // ══════════════════════════════════════════════════════════════════════════

  /// Fetches all products.
  ///
  /// TODO: Replace with your real API call.
  /// Example:
  ///   final response = await http.get(Uri.parse('https://your-api.com/products'));
  ///   final list = jsonDecode(response.body) as List;
  ///   return list.map((e) => ProductModel.fromJson(e, id: e['id'])).toList();
  Future<List<ProductModel>> fetchAllProducts() async {
    // Mock: simulate a network delay and return an empty list.
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  /// Fetches only featured products.
  ///
  /// TODO: Replace with your real API call.
  Future<List<ProductModel>> fetchFeaturedProducts() async {
    // Mock: simulate a network delay and return an empty list.
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }

  /// Fetches products filtered by [category].
  ///
  /// Pass "All" to retrieve every product without a category filter.
  ///
  /// TODO: Replace with your real API call.
  Future<List<ProductModel>> fetchProductsByCategory(String category) async {
    // Mock: simulate a network delay and return an empty list.
    await Future.delayed(const Duration(milliseconds: 500));

    // "All" is a UI-only concept — fetch everything when selected.
    if (category == 'All') return fetchAllProducts();

    return [];
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECTION 2 — User Profile
  // ══════════════════════════════════════════════════════════════════════════

  /// Creates a new user profile.
  ///
  /// TODO: Replace with your real API call.
  /// Example:
  ///   await http.post(
  ///     Uri.parse('https://your-api.com/users'),
  ///     body: jsonEncode(user.toJson()),
  ///   );
  Future<void> createUserProfile(UserModel user) async {
    // Mock: simulate a network delay.
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Fetches the profile for [userId].
  ///
  /// Returns `null` if the profile does not exist.
  ///
  /// TODO: Replace with your real API call.
  /// Example:
  ///   final response = await http.get(
  ///     Uri.parse('https://your-api.com/users/$userId'),
  ///   );
  ///   if (response.statusCode == 404) return null;
  ///   return UserModel.fromJson(jsonDecode(response.body), id: userId);
  Future<UserModel?> fetchUserProfile(String userId) async {
    // Mock: simulate a network delay and return null.
    await Future.delayed(const Duration(milliseconds: 300));
    return null;
  }

  /// Updates selected fields of the user profile for [userId].
  ///
  /// TODO: Replace with your real API call.
  /// Example:
  ///   await http.patch(
  ///     Uri.parse('https://your-api.com/users/$userId'),
  ///     body: jsonEncode(data),
  ///   );
  Future<void> updateUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    // Mock: simulate a network delay.
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ══════════════════════════════════════════════════════════════════════════
  // SECTION 3 — Orders
  // ══════════════════════════════════════════════════════════════════════════

  /// Saves a completed order.
  ///
  /// TODO: Replace with your real API call.
  /// Example:
  ///   await http.post(
  ///     Uri.parse('https://your-api.com/orders'),
  ///     body: jsonEncode(order.toJson()),
  ///   );
  Future<void> placeOrder({
    required String userId,
    required List<CartItemModel> items,
    required double totalAmount,
    required String deliveryAddress,
    required String phone,
  }) async {
    // Mock: simulate a network delay.
    await Future.delayed(const Duration(seconds: 1));

    // Generate a simple local order ID until backend is connected.
    final orderId = DateTime.now().millisecondsSinceEpoch.toString();

    final order = OrderModel(
      orderId: orderId,
      userId: userId,
      items: items,
      totalAmount: totalAmount,
      deliveryAddress: deliveryAddress,
      phone: phone,
      orderDate: DateTime.now(),
      status: AppConstants.orderStatusPending,
    );

    // TODO: Send order to your backend.
    // For now just print it for debugging.
    // ignore: avoid_print
    print('Order placed: ${order.toJson()}');
  }

  /// Fetches all orders placed by [userId], sorted newest-first.
  ///
  /// TODO: Replace with your real API call.
  /// Example:
  ///   final response = await http.get(
  ///     Uri.parse('https://your-api.com/orders?userId=$userId'),
  ///   );
  ///   final list = jsonDecode(response.body) as List;
  ///   return list.map((e) => OrderModel.fromJson(e, id: e['id'])).toList();
  Future<List<OrderModel>> fetchOrdersForUser(String userId) async {
    // Mock: simulate a network delay and return an empty list.
    await Future.delayed(const Duration(milliseconds: 500));
    return [];
  }
}