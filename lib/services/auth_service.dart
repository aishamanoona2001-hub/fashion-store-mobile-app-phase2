/// fashion_store/lib/services/auth_service.dart
///
/// A thin, stateless auth service — no Firebase dependency.
///
/// Responsibilities:
///   - Register new customers with email + password.
///   - Sign existing customers in and out.
///
/// TODO: Replace the mock implementations with your real backend API calls.

class AuthService {
  // ─── Register ─────────────────────────────────────────────────────────────

  /// Creates a new account with [email] and [password].
  ///
  /// Returns a [Map] containing the new user's basic info on success.
  /// Throws an [Exception] on failure (e.g. email already in use).
  ///
  /// TODO: Replace with your real registration API call.
  /// Example:
  ///   final response = await http.post(
  ///     Uri.parse('https://your-api.com/auth/register'),
  ///     body: {'email': email, 'password': password},
  ///   );
  Future<Map<String, dynamic>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    // Mock: simulate a network delay.
    await Future.delayed(const Duration(seconds: 1));

    // Mock: return a fake user response.
    return {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'email': email.trim(),
    };
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  /// Signs in an existing user with [email] and [password].
  ///
  /// Returns a [Map] containing the user's basic info on success.
  /// Throws an [Exception] on failure (e.g. wrong password).
  ///
  /// TODO: Replace with your real login API call.
  /// Example:
  ///   final response = await http.post(
  ///     Uri.parse('https://your-api.com/auth/login'),
  ///     body: {'email': email, 'password': password},
  ///   );
  Future<Map<String, dynamic>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    // Mock: simulate a network delay.
    await Future.delayed(const Duration(seconds: 1));

    // Mock: accept any credentials and return a fake user.
    return {
      'id': 'mock_user_001',
      'email': email.trim(),
    };
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  /// Signs the current user out.
  ///
  /// TODO: Add your real logout API call here if needed
  /// (e.g. invalidating a token on the server).
  Future<void> signOut() async {
    // Mock: simulate a network delay.
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ─── Error Message Helper ─────────────────────────────────────────────────

  /// Translates an [Exception] into a human-readable string
  /// suitable for display in a SnackBar or form error message.
  ///
  /// TODO: Update these error codes to match your real backend's
  /// error responses.
  static String getReadableAuthError(Exception e) {
    final message = e.toString().toLowerCase();

    if (message.contains('email-already-in-use') ||
        message.contains('already exists')) {
      return 'An account with this email already exists.';
    } else if (message.contains('invalid-email') ||
        message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    } else if (message.contains('weak-password') ||
        message.contains('weak password')) {
      return 'Password must be at least 6 characters.';
    } else if (message.contains('user-not-found') ||
        message.contains('not found')) {
      return 'No account found for this email address.';
    } else if (message.contains('wrong-password') ||
        message.contains('incorrect password')) {
      return 'Incorrect password. Please try again.';
    } else if (message.contains('too-many-requests') ||
        message.contains('too many')) {
      return 'Too many attempts. Please wait a moment and try again.';
    } else if (message.contains('network') ||
        message.contains('connection')) {
      return 'Network error. Please check your connection.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }
}