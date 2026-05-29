/// fashion_store/lib/utils/seed_service.dart
///
/// Provides sample product data for development and demonstration purposes.
///
/// Usage:
///   Call [SeedService.getProducts] to get the full list of sample products.
///   This replaces the old Firestore seeder — no database write needed.
///
/// Products: 15 items spanning all six categories.
/// Featured items: 7 products marked with `isFeatured: true`.
///
/// TODO: Remove this file and replace with your real backend API
/// once your product catalogue is live.

import 'package:fashion_store/models/product_model.dart';

class SeedService {
  SeedService._(); // Utility class — no instantiation needed.

  // ─── Public API ────────────────────────────────────────────────────────────

  /// Returns the full list of sample [ProductModel] objects.
  ///
  /// Each product gets a simple index-based ID (e.g. "product_0", "product_1").
  /// Replace with real IDs from your backend when ready.
  static List<ProductModel> getProducts() {
    return _products.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return ProductModel.fromJson(data, id: 'product_$index');
    }).toList();
  }

  /// Returns only products where `isFeatured` is `true`.
  static List<ProductModel> getFeaturedProducts() {
    return getProducts().where((p) => p.isFeatured).toList();
  }

  /// Returns products filtered by [category].
  /// Pass "All" to get every product.
  static List<ProductModel> getProductsByCategory(String category) {
    if (category == 'All') return getProducts();
    return getProducts().where((p) => p.category == category).toList();
  }

  // ─── Sample Product Data ───────────────────────────────────────────────────

  static final List<Map<String, dynamic>> _products = [
    // ── Men ──────────────────────────────────────────────────────────────────
    {
      'title': "Men's Classic White Shirt",
      'description':
          'A timeless white dress shirt crafted from premium 100% cotton. '
          'Features a slim-fit design with a button-down collar. '
          'Versatile enough for formal meetings and smart-casual weekends alike.',
      'price': 49.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1602810318383-e386cc2a3ccf?w=600&q=80',
      'category': 'Men',
      'isFeatured': true,
    },
    {
      'title': "Men's Slim Fit Jeans",
      'description':
          'Classic slim-fit denim jeans with a contemporary cut. '
          'Made from stretch denim for all-day comfort and freedom of movement. '
          'Finished in a clean dark-indigo wash that pairs with everything.',
      'price': 69.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1542272604-787c3835535d?w=600&q=80',
      'category': 'Men',
      'isFeatured': false,
    },
    {
      'title': "Men's Casual Bomber Jacket",
      'description':
          'A versatile bomber jacket perfect for layering through every season. '
          'Features a full zip, ribbed cuffs and hem, and two side pockets. '
          'Lightweight ripstop shell keeps you warm without the bulk.',
      'price': 89.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1551028719-00167b16eac5?w=600&q=80',
      'category': 'Men',
      'isFeatured': true,
    },

    // ── Women ─────────────────────────────────────────────────────────────────
    {
      'title': "Women's Floral Midi Dress",
      'description':
          'An elegant floral-print midi dress with a flattering wrap-style front. '
          'Features an adjustable tie waist and delicate flutter sleeves. '
          'Lightweight viscose fabric drapes beautifully for any occasion.',
      'price': 79.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1572804013309-59a88b7e92f1?w=600&q=80',
      'category': 'Women',
      'isFeatured': true,
    },
    {
      'title': "Women's Tailored Blazer",
      'description':
          'A chic single-breasted blazer with a modern slim silhouette. '
          'Notched lapels and a structured shoulder give a polished look. '
          'A true wardrobe staple — wear it over a dress or with jeans.',
      'price': 99.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1594938298603-c8148c4b4ac6?w=600&q=80',
      'category': 'Women',
      'isFeatured': false,
    },
    {
      'title': "Women's Relaxed Linen Top",
      'description':
          'A breezy relaxed-fit top in 100% washed linen. '
          'V-neckline with short roll-up sleeves for a laid-back summer look. '
          'Available in soft neutral tones that mix and match effortlessly.',
      'price': 34.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1485462537746-965f33f7f6a7?w=600&q=80',
      'category': 'Women',
      'isFeatured': false,
    },
    {
      'title': "Women's Wide-Leg Trousers",
      'description':
          'Sophisticated wide-leg trousers in a flowing crepe fabric. '
          'High-rise waist with a side zip for a clean, minimal finish. '
          'Effortlessly elegant — dressed up with heels or down with trainers.',
      'price': 74.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1509631179647-0177331693ae?w=600&q=80',
      'category': 'Women',
      'isFeatured': true,
    },

    // ── Kids ──────────────────────────────────────────────────────────────────
    {
      'title': "Kids' Adventure Graphic Tee",
      'description':
          'A fun, comfortable graphic tee made from 100% soft ring-spun cotton. '
          'Vibrant printed design that stays bright wash after wash. '
          'Tag-free label and roomy fit make it the perfect everyday tee.',
      'price': 24.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1518831959646-742c3a14ebf7?w=600&q=80',
      'category': 'Kids',
      'isFeatured': false,
    },
    {
      'title': "Kids' Denim Dungarees",
      'description':
          'Durable denim dungarees with an adjustable bib and shoulder straps. '
          'Elasticated back waistband for a comfortable fit as they grow. '
          'Reinforced knees stand up to the toughest playground adventures.',
      'price': 39.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1519238263530-99bdd11df2ea?w=600&q=80',
      'category': 'Kids',
      'isFeatured': false,
    },

    // ── Accessories ───────────────────────────────────────────────────────────
    {
      'title': 'Premium Leather Bifold Wallet',
      'description':
          'A slim bifold wallet hand-stitched from genuine top-grain leather. '
          'Six card slots, a full-length bill pocket, and an ID window. '
          'Comes in a premium gift box — ideal as a personal treat or gift.',
      'price': 44.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1627123424574-724758594e93?w=600&q=80',
      'category': 'Accessories',
      'isFeatured': true,
    },
    {
      'title': 'Classic Aviator Sunglasses',
      'description':
          'Iconic teardrop aviator frames with UV400 polarised lenses. '
          'Lightweight stainless steel frame with spring-loaded hinges. '
          'Includes a branded microfibre pouch and hard-shell carry case.',
      'price': 59.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1572635196237-14b3f281503f?w=600&q=80',
      'category': 'Accessories',
      'isFeatured': false,
    },
    {
      'title': 'Minimalist Leather Wristwatch',
      'description':
          'A clean, minimal watch with a genuine leather strap and steel case. '
          'Japanese quartz movement with a scratch-resistant sapphire crystal. '
          '30 m water resistance — wear it from desk to weekend without worry.',
      'price': 129.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=600&q=80',
      'category': 'Accessories',
      'isFeatured': true,
    },

    // ── Footwear ──────────────────────────────────────────────────────────────
    {
      'title': "Men's Canvas Low-Top Sneakers",
      'description':
          'Clean, minimal low-top sneakers with a cotton canvas upper and '
          'vulcanised rubber sole. Cushioned OrthoLite insole for all-day comfort. '
          'A timeless silhouette that pairs with chinos, jeans or shorts.',
      'price': 84.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=600&q=80',
      'category': 'Footwear',
      'isFeatured': true,
    },
    {
      'title': "Women's Block Heel Pumps",
      'description':
          'Elegant pointed-toe pumps with a stable block heel for all-day wear. '
          'Soft suede upper with a cushioned leather insole. '
          'A versatile style that takes you from the office straight to dinner.',
      'price': 94.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1543163521-1bf539c55dd2?w=600&q=80',
      'category': 'Footwear',
      'isFeatured': false,
    },
    {
      'title': 'Unisex Performance Running Shoes',
      'description':
          'High-performance runners with a responsive foam midsole and '
          'lightweight breathable mesh upper. Reflective heel tab for low-light '
          'visibility. Suitable for road running, gym sessions, and daily wear.',
      'price': 109.99,
      'imageUrl':
          'https://images.unsplash.com/photo-1608231387042-66d1773070a5?w=600&q=80',
      'category': 'Footwear',
      'isFeatured': true,
    },
  ];
}