/// fashion_store/lib/models/user_model.dart
///
/// Represents a customer's profile document stored in the Firestore
/// `users` collection. This model is separate from Firebase's own
/// [firebase_auth.User] object — it holds extended business data like
/// the delivery address that Firebase Auth does not support natively.
///
/// Firestore document structure:
/// ```
/// users/{uid}
///   ├── id         : String  (same as the Firebase Auth UID)
///   ├── email      : String
///   ├── name       : String
///   ├── phone      : String
///   └── address    : String
/// ```

class UserModel {
  // ─── Fields ───────────────────────────────────────────────────────────────

  /// The Firebase Auth UID. Also used as the Firestore document ID.
  final String id;

  /// The user's email address — mirrors the Firebase Auth email.
  final String email;

  /// The user's display name.
  final String name;

  /// Contact phone number used for delivery coordination.
  final String phone;

  /// Default delivery address shown on the Checkout screen.
  final String address;

  // ─── Constructor ──────────────────────────────────────────────────────────

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.address,
  });

  // ─── Factory — from JSON ───────────────────────────────────────────────────

  /// Creates a [UserModel] from a Firestore document snapshot map.
  ///
  /// [id] is passed separately because Firestore document IDs are not
  /// stored inside the document data itself.
  factory UserModel.fromJson(Map<String, dynamic> json, {required String id}) {
    return UserModel(
      id: id,
      email: json['email'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      address: json['address'] as String? ?? '',
    );
  }

  // ─── Factory — from Firestore ──────────────────────────────────────────────

  /// Alias for [fromJson] — called by [AppAuthProvider] when reading
  /// the Firestore user document. The parameter order matches the pattern
  /// used across all other models in this project.
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel.fromJson(data, id: id);
  }

  // ─── Serialise to Firestore ────────────────────────────────────────────────

  /// Converts this model to a Map suitable for writing to Firestore.
  ///
  /// The [id] field is intentionally excluded because it matches the
  /// document ID and Firestore does not require it inside the data map.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'phone': phone,
      'address': address,
    };
  }

  // ─── copyWith ─────────────────────────────────────────────────────────────

  /// Returns a new [UserModel] with selected fields replaced.
  /// Used by [ProfileScreen] to apply partial edits without mutating state.
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  // ─── Equality & Debug ─────────────────────────────────────────────────────

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'UserModel(id: $id, name: $name, email: $email)';
}