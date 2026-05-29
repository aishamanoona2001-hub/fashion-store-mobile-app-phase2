/// fashion_store/lib/models/product_model.dart
///
/// Represents a single product document in the Firestore `products`
/// collection. Products are pre-loaded manually in Firestore; this model
/// is used only for reading/deserialising that data.
///
/// Firestore document structure:
/// ```
/// products/{productId}
///   ├── title        : String
///   ├── description  : String
///   ├── price        : Number  (stored as double)
///   ├── imageUrl     : String  (a publicly accessible HTTPS URL)
///   ├── category     : String  (must match one of AppConstants.productCategories)
///   └── isFeatured   : Boolean (true → shown on HomeScreen featured grid)
/// ```

class ProductModel {
  // ─── Fields ───────────────────────────────────────────────────────────────

  /// The Firestore document ID for this product.
  final String id;

  /// Short display name shown on product cards (e.g. "Classic White Tee").
  final String title;

  /// Long-form description shown on [ProductDetailsScreen].
  final String description;

  /// Retail price in the store's base currency (assumed LKR / USD etc.).
  final double price;

  /// A publicly accessible HTTPS URL to the product image.
  /// Loaded via [CachedNetworkImage] for efficient rendering.
  final String imageUrl;

  /// Category tag — must match one of the values in [AppConstants.productCategories].
  /// Used to filter products on [ProductListingScreen].
  final String category;

  /// When `true`, this product is displayed in the featured grid on [HomeScreen].
  final bool isFeatured;

  // ─── Constructor ──────────────────────────────────────────────────────────

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isFeatured,
  });

  // ─── Factory — from JSON ───────────────────────────────────────────────────

  /// Creates a [ProductModel] from a Firestore document snapshot.
  ///
  /// [id] is the document ID (passed separately, as with [UserModel]).
  /// The `price` field is coerced via `num` cast to handle both `int`
  /// and `double` values that Firestore may return.
  factory ProductModel.fromJson(
    Map<String, dynamic> json, {
    required String id,
  }) {
    return ProductModel(
      id: id,
      title: json['title'] as String? ?? 'Untitled Product',
      description: json['description'] as String? ?? '',
      // Firestore stores numbers as either int or double; cast via num first.
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['imageUrl'] as String? ?? '',
      category: json['category'] as String? ?? 'All',
      isFeatured: json['isFeatured'] as bool? ?? false,
    );
  }

  // ─── Factory — from Firestore ──────────────────────────────────────────────

  /// Alias for [fromJson] — called by [ProductProvider] when reading
  /// Firestore documents. Matches the same pattern used in [UserModel].
  factory ProductModel.fromFirestore(Map<String, dynamic> data, String id) {
    return ProductModel.fromJson(data, id: id);
  }

  // ─── Serialise to Firestore ────────────────────────────────────────────────

  /// Converts this model to a Firestore-compatible Map.
  /// The `id` is excluded (it is the document ID, not a field).
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'isFeatured': isFeatured,
    };
  }

  // ─── Equality & Debug ─────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'ProductModel(id: $id, title: $title, price: $price, category: $category)';
}