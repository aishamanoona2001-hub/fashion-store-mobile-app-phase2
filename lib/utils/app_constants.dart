/// fashion_store/lib/utils/app_constants.dart
///
/// Application-wide constant values used across screens and services.
/// Centralising these prevents magic strings and makes future updates trivial.

class AppConstants {
  // Private constructor — this class should never be instantiated.
  AppConstants._();

  // ─── App Identity ─────────────────────────────────────────────────────────
  static const String appName = 'Fashion Store';
  static const String tagline = 'Style, Delivered.';

  // ─── Firestore Collection Names ───────────────────────────────────────────
  /// Top-level collection for user profiles.
  static const String usersCollection = 'users';

  /// Top-level collection for product catalogue.
  static const String productsCollection = 'products';

  /// Top-level collection for customer orders.
  static const String ordersCollection = 'orders';

  // ─── Product Categories ───────────────────────────────────────────────────
  /// The full list of product categories shown in the HomeScreen filter row.
  /// These must match the 'category' field values stored in Firestore.
  static const List<String> productCategories = [
    'All',
    'Men',
    'Women',
    'Kids',
    'Accessories',
    'Footwear',
  ];

  // ─── Order Status Values ──────────────────────────────────────────────────
  static const String orderStatusPending = 'Pending';
  static const String orderStatusProcessing = 'Processing';
  static const String orderStatusShipped = 'Shipped';
  static const String orderStatusDelivered = 'Delivered';
  static const String orderStatusCancelled = 'Cancelled';

  // ─── Shared Preferences Keys ─────────────────────────────────────────────
  /// The key used to persist the cart as a JSON string in local storage.
  static const String cartPrefsKey = 'fashion_store_cart';

  // ─── UI Dimensions ────────────────────────────────────────────────────────
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 12.0;
}
