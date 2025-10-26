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
  /// This factory accepts minor backend typos (e.g. 'phone_numer') and coerces
  /// numeric types safely.
  factory User.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) return int.tryParse(v);
      return null;
    }

    dynamic getVal(List<String> keys) {
      for (var k in keys) {
        if (json.containsKey(k)) return json[k];
      }
      return null;
    }

    final idVal = parseInt(getVal(['id']));
    final usernameVal = getVal(['user_name', 'userName', 'username']);
    final fullnameVal = getVal(['full_name', 'fullName', 'fullname']);
    final phoneVal = getVal([
      'phone_number',
      'phone_numer',
      'phoneNumber',
      'phonenumber',
    ]);
    final emailVal = getVal(['email']);
    final aliasVal = parseInt(getVal(['alias']));

    if (usernameVal == null || fullnameVal == null) {
      throw Exception('Invalid JSON for User: missing required fields');
    }

    return User(
      id: idVal,
      username: usernameVal.toString(),
      fullname: fullnameVal.toString(),
      phonenumber: phoneVal == null ? null : phoneVal.toString(),
      email: emailVal == null ? null : emailVal.toString(),
      alias: aliasVal,
    );
  }

  /// Convert this [User] to a JSON-compatible map using API snake_case keys.
  /// Used by services when encoding request bodies.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_name': username,
      'full_name': fullname,
      'phone_number': phonenumber,
      'email': email,
      'alias': alias,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
