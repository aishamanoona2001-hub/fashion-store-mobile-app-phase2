/// fashion_store/lib/screens/shop/home_screen.dart
///
/// The landing dashboard shown after login.
///
/// Layout (top → bottom):
///   • Personalised greeting using the user's name from [AppAuthProvider].
///   • Horizontal scrollable row of category chips.
///     Tapping a chip navigates to [ProductListingScreen] with that category.
///   • "Featured Products" section header.
///   • Lazy-loading 2-column grid of featured [ProductCard]s.
///
/// Data flow:
///   • On first build, [ProductProvider.fetchInitialData()] is triggered via
///     a [FutureBuilder]-style approach using [_initFuture] stored in state.
///   • Pull-to-refresh calls [ProductProvider.refreshProducts()].

import 'package:fashion_store/providers/auth_provider.dart';
import 'package:fashion_store/providers/product_provider.dart';
import 'package:fashion_store/screens/shop/product_listing_screen.dart';
import 'package:fashion_store/utils/app_constants.dart';
import 'package:fashion_store/utils/app_theme.dart';
import 'package:fashion_store/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Stored so it is only created once — prevents re-fetching on every
  /// rebuild triggered by [notifyListeners].
  late Future<void> _initFuture;
  int _selectedCategoryIndex = 0;

  @override
  void initState() {
    super.initState();
    // context.read is safe in initState (no listen needed here).
    _initFuture = context.read<ProductProvider>().fetchInitialData();
  }

  // ─── Pull-to-refresh ──────────────────────────────────────────────────────

  Future<void> _onRefresh() async {
    await context.read<ProductProvider>().refreshProducts();
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppTheme.primaryColor,
          child: FutureBuilder<void>(
            future: _initFuture,
            builder: (context, snapshot) {
              // Show a full-screen loader on the very first fetch only.
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Show an error state if the initial fetch failed.
              if (snapshot.hasError) {
                return _buildErrorState();
              }

              return _buildContent(context);
            },
          ),
        ),
      ),
    );
  }

  // ─── Main Content ─────────────────────────────────────────────────────────

  Widget _buildContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── App Bar / Greeting ───────────────────────────────────────────
        SliverToBoxAdapter(child: _buildHeader(context)),

        // ── Category Chips ───────────────────────────────────────────────
        SliverToBoxAdapter(child: _buildCategoryRow(context)),

        // ── "Featured Products" Title ────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Text(
              'Featured Products',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),

        // ── Featured Products Grid ───────────────────────────────────────
        _buildFeaturedGrid(context),

        // Bottom padding for the nav bar.
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  // ─── Header / Greeting ────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    final userName = context.select<AppAuthProvider, String>(
      (auth) => auth.userModel?.name ?? 'there',
    );

    // Extract first name only for a friendlier greeting.
    final firstName = userName.split(' ').first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, $firstName 👋',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Discover your next favourite style.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          // Brand icon placeholder.
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Category Chips ───────────────────────────────────────────────────────

  Widget _buildCategoryRow(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: AppConstants.productCategories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = AppConstants.productCategories[index];
          final isSelected = _selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategoryIndex = index);
              if (index != 0) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductListingScreen(initialCategory: category),
                  ),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF1A1A2E) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? const Color(0xFF1A1A2E) : const Color(0xFFBDBDBD),
                ),
              ),
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF333333),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Featured Grid ────────────────────────────────────────────────────────

  Widget _buildFeaturedGrid(BuildContext context) {
    final featured = context.watch<ProductProvider>().featuredProducts;

    if (featured.isEmpty) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.0),
            child: Text(
              'No featured products yet.\nCheck back soon!',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => ProductCard(product: featured[index]),
          childCount: featured.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          // Extra height for the text area below the image.
          childAspectRatio: 0.72,
        ),
      ),
    );
  }

  // ─── Error State ──────────────────────────────────────────────────────────

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 64, color: AppTheme.textSecondaryColor),
            const SizedBox(height: 16),
            const Text(
              'Could not load products.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pull down to retry.',
              style: TextStyle(color: AppTheme.textSecondaryColor),
            ),
          ],
        ),
      ),
    );
  }
}
