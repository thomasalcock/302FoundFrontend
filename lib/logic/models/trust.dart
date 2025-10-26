/// 302FoundFrontend (2025) - Model: Trust.
///
/// Represents a trust relationship between a user and a trustee. This simple
/// data holder mirrors the API payload keys (user_id, trustee_id).
///
/// Example:
/// ```dart
/// final t = Trust.fromJson(json);
/// ```
class Trust {
  /// Database id (nullable for new, unsaved instances).
  final int? id;

  /// The owner/user id.
  final int userId;

  /// The trustee's user id.
  final int trusteeId;

  Trust({this.id, required this.userId, required this.trusteeId});

  /// Create a [Trust] from API JSON.
  ///
  /// @param json decoded JSON map from backend
  /// @return Trust instance
  factory Trust.fromJson(Map<String, dynamic> json) {
    return Trust(
      id: json['id'],
      userId: json['user_id'],
      trusteeId: json['trustee_id'],
    );
  }
}
