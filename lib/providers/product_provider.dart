/// fashion_store/lib/providers/product_provider.dart
///
/// Manages the product catalogue state — now fetching from Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_store/models/product_model.dart';
import 'package:fashion_store/utils/app_constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

class ProductProvider extends ChangeNotifier {
  // ─── Firebase Instance ────────────────────────────────────────────────────
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── State ────────────────────────────────────────────────────────────────
  List<ProductModel> _allProducts = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _filteredProducts = [];
  String _selectedCategory = AppConstants.productCategories.first; // 'All'
  bool _isLoading = false;
  String? _errorMessage;

  // ─── Public Getters ───────────────────────────────────────────────────────
  List<ProductModel> get allProducts => _allProducts;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get filteredProducts => _filteredProducts;
  String get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ─── Fetch Initial Data ───────────────────────────────────────────────────

  /// Fetches all products from Firestore.
  /// Called once from HomeScreen on first load.
  Future<void> fetchInitialData() async {
    if (_allProducts.isNotEmpty) return; // Already loaded — skip.

    _setLoading(true);
    _clearError();

    try {
      final snapshot = await _db.collection('products').get();

      _allProducts = snapshot.docs.map((doc) {
        return ProductModel.fromFirestore(
          doc.data(),
          doc.id,
        );
      }).toList();

      // Featured products are those with isFeatured == true in Firestore.
      _featuredProducts =
          _allProducts.where((p) => p.isFeatured == true).toList();

      // Start with all products visible.
      _filteredProducts = _allProducts;
    } catch (e) {
      _setError('Failed to load products. Please try again.');
      debugPrint('ProductProvider: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ─── Category Selection ───────────────────────────────────────────────────

  /// Filters [_filteredProducts] by category — done client-side, no extra
  /// Firestore calls needed.
  Future<void> selectCategory(String category) async {
    if (_selectedCategory == category) return;

    _selectedCategory = category;

    if (_allProducts.isEmpty) {
      await fetchInitialData();
      return;
    }

    if (category == 'All') {
      _filteredProducts = _allProducts;
    } else {
      _filteredProducts =
          _allProducts.where((p) => p.category == category).toList();
    }

    notifyListeners();
  }

  /// Forces a full refresh from Firestore (pull-to-refresh).
  Future<void> refreshProducts() async {
    _allProducts = [];
    _featuredProducts = [];
    _filteredProducts = [];
    await fetchInitialData();
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    if (SchedulerBinding.instance.schedulerPhase != SchedulerPhase.idle) {
      SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}