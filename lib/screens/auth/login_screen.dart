/// fashion_store/lib/screens/auth/login_screen.dart
///
/// The entry screen for returning customers.
///
/// UI layout (top → bottom):
///   • Brand logo / app name header.
///   • Email text field with validation.
///   • Password text field with show/hide toggle and validation.
///   • "Forgot Password?" text button (placeholder — not yet implemented).
///   • "Login" elevated button (shows spinner while loading).
///   • "Don't have an account? Register" navigation link.
///
/// Auth flow:
///   1. User fills the form and taps "Login".
///   2. [_formKey.currentState!.validate()] runs client-side validators.
///   3. [AppAuthProvider.login()] is called; errors surface via [_errorMessage].
///   4. On success, [AppAuthProvider.isAuthenticated] becomes true and
///      [AuthGate] in [main.dart] automatically navigates to the main app.
///      No manual Navigator.push is needed.

import 'package:fashion_store/providers/auth_provider.dart';
import 'package:fashion_store/screens/auth/register_screen.dart';
import 'package:fashion_store/utils/app_theme.dart';
import 'package:fashion_store/widgets/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // ─── Form State ───────────────────────────────────────────────────────────

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  /// Controls whether the password field shows plain text.
  bool _obscurePassword = true;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void dispose() {
    // Always dispose controllers to release resources.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  /// Validates the form and calls the auth provider to sign in.
  Future<void> _submit() async {
    // Dismiss keyboard before triggering async work.
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AppAuthProvider>();
    await authProvider.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    // On failure, the provider sets [errorMessage]. Show it in a SnackBar.
    if (!authProvider.isAuthenticated && mounted) {
      final error = authProvider.errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
    // On success, AuthGate reacts to the auth state change automatically.
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Watch [isLoading] so the button reacts to provider state changes.
    final isLoading = context.select<AppAuthProvider, bool>(
      (p) => p.isLoading,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),

                  // ── Brand Header ─────────────────────────────────────────
                  _buildHeader(context),

                  const SizedBox(height: 48),

                  // ── Email Field ───────────────────────────────────────────
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email address.';
                      }
                      // Simple RFC-5322 inspired regex.
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email address.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ── Password Field ────────────────────────────────────────
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password.';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),

                  // ── Forgot Password (placeholder) ─────────────────────────
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                    
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Password reset coming soon.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text('Forgot Password?'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Login Button ──────────────────────────────────────────
                  LoadingButton(
                    label: 'Login',
                    isLoading: isLoading,
                    onPressed: _submit,
                  ),

                  const SizedBox(height: 32),

                  // ── Register Navigation ───────────────────────────────────
                  _buildRegisterLink(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Sub-Widgets ──────────────────────────────────────────────────────────

  /// Displays the app name and a welcoming sub-heading.
  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // Simple icon as a brand placeholder — replace with a real logo asset.
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.shopping_bag_outlined,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Fashion Store',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'Welcome back! Sign in to continue.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  /// Row with a prompt and a [TextButton] to navigate to [RegisterScreen].
  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don't have an account?",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const RegisterScreen()),
            );
          },
          child: const Text('Register'),
        ),
      ],
    );
  }
}
