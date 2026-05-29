/// fashion_store/lib/widgets/bottom_nav_widget.dart
///
/// The root scaffold of the authenticated app.
///
/// Hosts three tabs via a [BottomNavigationBar]:
///   0 → [HomeScreen]
///   1 → [CartScreen]
///   2 → [ProfileScreen]
///
/// Each tab is kept alive using [IndexedStack] so that state (scroll
/// position, loaded data) is preserved when the user switches tabs.
///
/// The cart tab badge dynamically shows the total item quantity from
/// [CartProvider] so the user always sees an up-to-date count.

import 'package:fashion_store/providers/cart_provider.dart';
import 'package:fashion_store/providers/navigation_provider.dart';
import 'package:fashion_store/screens/cart/cart_screen.dart';        // ← FIXED
import 'package:fashion_store/screens/profile/profile_screen.dart';
import 'package:fashion_store/screens/shop/home_screen.dart';
import 'package:fashion_store/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MainNavigationScaffold extends StatelessWidget {
  const MainNavigationScaffold({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = context.watch<NavigationProvider>().selectedIndex;

    final cartQuantity = context.select<CartProvider, int>(
      (cart) => cart.totalQuantity,
    );

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => context.read<NavigationProvider>().setIndex(index),
        items: [
          // ── Home ───────────────────────────────────────────────────────
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),

          // ── Cart (with badge) ──────────────────────────────────────────
          BottomNavigationBarItem(
            icon: Badge(
              isLabelVisible: cartQuantity > 0,
              label: Text(
                cartQuantity > 99 ? '99+' : '$cartQuantity',
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: AppTheme.accentColor,
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            activeIcon: Badge(
              isLabelVisible: cartQuantity > 0,
              label: Text(
                cartQuantity > 99 ? '99+' : '$cartQuantity',
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: AppTheme.accentColor,
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),

          // ── Profile ────────────────────────────────────────────────────
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}