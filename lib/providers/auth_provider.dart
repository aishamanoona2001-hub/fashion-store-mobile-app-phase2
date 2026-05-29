/// fashion_store/lib/providers/auth_provider.dart
///
/// Manages authentication state using Firebase Auth + Firestore.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fashion_store/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AppAuthProvider extends ChangeNotifier {
  // ─── Firebase Instances ───────────────────────────────────────────────────
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── State ────────────────────────────────────────────────────────────────
  UserModel? _userModel;
  bool _isLoading = true; // true on startup while Firebase resolves auth state
  String? _errorMessage;

  // ─── Constructor ──────────────────────────────────────────────────────────
  AppAuthProvider() {
    // Listen to Firebase auth state changes in real time.
    // This fires immediately on startup with the persisted session (if any),
    // which is how AuthGate knows whether to show Home or Login.
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  // ─── Public Getters ───────────────────────────────────────────────────────
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _userModel != null;

  // ─── Auth State Listener ──────────────────────────────────────────────────

  /// Called automatically by Firebase whenever the auth state changes.
  /// Fetches the Firestore user document and updates [_userModel].
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      // User signed out — clear the model.
      _userModel = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    // User is signed in — fetch their profile from Firestore.
    try {
      final doc = await _db.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _userModel = UserModel.fromFirestore(doc.data()!, firebaseUser.uid);
      }
    } catch (e) {
      debugPrint('AppAuthProvider: failed to fetch user doc — $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  /// Creates a new Firebase Auth user and saves their profile to Firestore.
  /// Returns `true` on success, `false` on failure.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save extended profile to Firestore.
      await _db.collection('users').doc(credential.user!.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'address': '',
        'createdAt': Timestamp.now(),
      });

      // _onAuthStateChanged will fire automatically and set _userModel.
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyError(e.code));
      return false;
    } catch (e) {
      _setError('Registration failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Login ────────────────────────────────────────────────────────────────

  /// Signs in an existing user with email and password.
  /// Returns `true` on success, `false` on failure.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // _onAuthStateChanged will fire automatically and set _userModel.
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_friendlyError(e.code));
      return false;
    } catch (e) {
      _setError('Login failed. Please try again.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────────────

  /// Signs out and clears all local state.
  Future<void> logout() async {
    await _auth.signOut();
    // _onAuthStateChanged fires automatically and sets _userModel = null.
  }

  // ─── Profile Update ───────────────────────────────────────────────────────

  /// Updates the local [_userModel] cache after a successful profile save.
  void updateLocalUserModel(UserModel updatedUser) {
    _userModel = updatedUser;
    notifyListeners();
  }

  // ─── Private Helpers ──────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _isLoading = false;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  /// Converts Firebase error codes into human-readable messages.
  String _friendlyError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}