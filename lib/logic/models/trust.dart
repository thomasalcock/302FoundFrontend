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
  /// This factory tolerates minor backend variations (numeric values as
  /// strings, alternative key names) and safely coerces numeric types.
  factory Trust.fromJson(Map<String, dynamic> json) {
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
    final userIdVal = parseInt(getVal(['user_id', 'userId', 'user']));
    final trusteeIdVal = parseInt(
      getVal(['trustee_id', 'trusteeId', 'trustee']),
    );

    if (userIdVal == null || trusteeIdVal == null) {
      throw Exception('Invalid JSON for Trust: missing required fields');
    }

    return Trust(id: idVal, userId: userIdVal, trusteeId: trusteeIdVal);
  }

  /// Convert this [Trust] to a JSON-compatible map using API snake_case keys.
  /// Used by services when encoding request bodies.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{'user_id': userId, 'trustee_id': trusteeId};
    if (id != null) map['id'] = id;
    return map;
  }
}
