/// fashion_store/lib/screens/profile/profile_screen.dart
///
/// Displays and allows editing of the customer's account details.
///
/// Layout (top → bottom):
///   • Avatar + display name + email header.
///   • Editable form fields: Full Name, Phone, Delivery Address.
///   • "Save Changes" button — saves to Firestore and patches local cache.
///   • "Order History" navigation tile.
///   • "Logout" button with a confirmation dialog.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_store/models/user_model.dart';
import 'package:fashion_store/providers/auth_provider.dart';
import 'package:fashion_store/screens/profile/order_history_screen.dart';
import 'package:fashion_store/utils/app_theme.dart';
import 'package:fashion_store/widgets/loading_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ─── Form State ───────────────────────────────────────────────────────────

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;

  bool _isSaving = false;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    final user = context.read<AppAuthProvider>().userModel;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // ─── Save Profile ─────────────────────────────────────────────────────────

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authProvider = context.read<AppAuthProvider>();
      final userId = authProvider.userModel?.id ?? '';

      // ── Save to Firestore ────────────────────────────────────────────
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });

      // Patch in-memory model so HomeScreen greeting updates instantly.
      final currentUser = authProvider.userModel!;
      authProvider.updateLocalUserModel(
        currentUser.copyWith(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Failed to update profile. Please try again.'),
            backgroundColor: AppTheme.accentColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentColor,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AppAuthProvider>().logout();
              // AuthGate automatically routes to LoginScreen.
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final user = context.select<AppAuthProvider, UserModel?>(
      (auth) => auth.userModel,
    );

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Avatar Header ────────────────────────────────────────
              _buildAvatarHeader(context, user),

              const SizedBox(height: 28),

              // ── Edit Fields ──────────────────────────────────────────
              _buildSectionTitle(context, 'Account Details'),
              const SizedBox(height: 12),
              _buildEditForm(user),

              const SizedBox(height: 24),

              // ── Save Button ──────────────────────────────────────────
              LoadingButton(
                label: 'Save Changes',
                isLoading: _isSaving,
                onPressed: _saveProfile,
              ),

              const SizedBox(height: 28),

              // ── Navigation Tiles ─────────────────────────────────────
              _buildSectionTitle(context, 'My Orders'),
              const SizedBox(height: 12),
              _buildOrderHistoryTile(context),

              const SizedBox(height: 28),

              // ── Logout ───────────────────────────────────────────────
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentColor,
                  side: const BorderSide(color: AppTheme.accentColor),
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _confirmLogout,
                icon: const Icon(Icons.logout),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Sub-Widgets ──────────────────────────────────────────────────────────

  Widget _buildAvatarHeader(BuildContext context, UserModel? user) {
    final initial =
        (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : '?';

    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppTheme.primaryColor,
          child: Text(
            initial,
            style: const TextStyle(
              fontSize: 36,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user?.name ?? 'Your Name',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          user?.email ?? '',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge);
  }

  Widget _buildEditForm(UserModel? user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // ── Email (read-only) ────────────────────────────────────
            _buildReadOnlyField(
              context,
              label: 'Email',
              value: user?.email ?? '—',
              icon: Icons.email_outlined,
            ),

            const SizedBox(height: 16),

            // ── Full Name ────────────────────────────────────────────
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Name cannot be empty.';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ── Phone ─────────────────────────────────────────────────
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              validator: (value) => null,
            ),

            const SizedBox(height: 16),

            // ── Address ───────────────────────────────────────────────
            TextFormField(
              controller: _addressController,
              keyboardType: TextInputType.streetAddress,
              textInputAction: TextInputAction.done,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Default Delivery Address',
                prefixIcon: Icon(Icons.location_on_outlined),
                alignLabelWithHint: true,
              ),
              validator: (value) => null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        fillColor: AppTheme.backgroundColor,
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
      ),
    );
  }

  Widget _buildOrderHistoryTile(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.receipt_long_outlined,
            color: AppTheme.primaryColor,
          ),
        ),
        title: const Text('Order History'),
        subtitle: const Text('View all your past orders'),
        trailing: const Icon(
          Icons.chevron_right,
          color: AppTheme.textSecondaryColor,
        ),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
        ),
      ),
    );
  }
}