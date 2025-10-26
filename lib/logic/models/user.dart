/// 302FoundFrontend (2025) - Model: User.
///
/// Lightweight user model used by UI/forms and API services. Fields correspond
/// to backend keys (e.g. user_name, full_name). Instances are immutable.
///
/// Example:
/// ```dart
/// final u = User.fromJson(json);
/// ```
class User {
  /// Database id (nullable for new/local instances).
  final int? id;

  /// Unique username (login handle).
  final String username;

  /// Full display name.
  final String fullname;

  /// Optional phone number.
  final String? phonenumber;

  /// Optional email address.
  final String? email;

  /// Optional alias id used by the app.
  final int? alias;

  User({
    this.id,
    required this.username,
    required this.fullname,
    this.phonenumber,
    this.email,
    this.alias,
  });

  /// Create a [User] from API JSON.
  ///
  /// @param json decoded map from backend
  /// @return User instance
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['user_name'],
      fullname: json['full_name'],
      phonenumber: json['phone_number'],
      email: json['email'],
      alias: json['alias'],
    );
  }
}
