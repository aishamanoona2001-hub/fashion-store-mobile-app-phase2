import 'package:fashion_store/providers/auth_provider.dart';
import 'package:fashion_store/providers/cart_provider.dart';
import 'package:fashion_store/providers/navigation_provider.dart';
import 'package:fashion_store/providers/product_provider.dart';
import 'package:fashion_store/screens/auth/login_screen.dart';
import 'package:fashion_store/utils/app_constants.dart';
import 'package:fashion_store/utils/app_theme.dart';
import 'package:fashion_store/widgets/bottom_nav_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';        // ← ADD THIS
import 'firebase_options.dart';                           // ← ADD THIS

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ← ADD THIS — connects Flutter to your Firebase project
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const FashionStoreApp());
}

class FashionStoreApp extends StatelessWidget {
  const FashionStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AppAuthProvider>(
          create: (_) => AppAuthProvider(),
        ),
        ChangeNotifierProvider<ProductProvider>(
          create: (_) => ProductProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),
        ChangeNotifierProvider<NavigationProvider>(
          create: (_) => NavigationProvider(),
        ),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AppAuthProvider>();

    if (authProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return authProvider.isAuthenticated
        ? const MainNavigationScaffold()
        : const LoginScreen();
  }
}