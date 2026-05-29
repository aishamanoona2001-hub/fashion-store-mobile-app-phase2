/// fashion_store/lib/providers/navigation_provider.dart
///
/// Controls the active tab index of [MainNavigationScaffold].
///
/// Any screen deep in the navigation stack can obtain this provider via
/// `context.read<NavigationProvider>().setIndex(n)` and then pop back to
/// the root — the [MainNavigationScaffold] will reactively switch to
/// the requested tab without needing callbacks or GlobalKeys.

import 'package:flutter/foundation.dart';

class NavigationProvider extends ChangeNotifier {
  int _selectedIndex = 0;

  /// The index of the currently visible tab (0 = Home, 1 = Cart, 2 = Profile).
  int get selectedIndex => _selectedIndex;

  /// Switches to tab [index]. No-op if the tab is already active.
  void setIndex(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }
}
