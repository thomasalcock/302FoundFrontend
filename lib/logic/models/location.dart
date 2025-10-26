/// 302FoundFrontend (2025) - Model: Location.
///
/// Simple data holder for persisted location entries. Fields mirror the API
/// payload (user_id, latitude, longitude). Latitude/longitude are stored as
/// integers in this model (project convention).
///
/// Example:
/// ```dart
/// final loc = Location.fromJson(json);
/// ```
class Location {
  /// Database id (nullable for not-yet-persisted instances).
  final int? id;

  /// Owner user's id.
  final int userId;

  /// Latitude encoded as integer (project convention).
  final int latitude;

  /// Longitude encoded as integer (project convention).
  final int longitude;

  Location({
    this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
  });

  /// Create a [Location] from the API JSON.
  ///
  /// This factory is resilient to minor backend variations (e.g. numeric values
  /// as strings, alternative key names) and safely coerces numeric types.
  factory Location.fromJson(Map<String, dynamic> json) {
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
    final latVal = parseInt(getVal(['latitude', 'lat']));
    final longVal = parseInt(getVal(['longitude', 'lng', 'long']));

    if (userIdVal == null || latVal == null || longVal == null) {
      throw Exception('Invalid JSON for Location: missing required fields');
    }

    return Location(
      id: idVal,
      userId: userIdVal,
      latitude: latVal,
      longitude: longVal,
    );
  }

  /// Convert this [Location] to a JSON-compatible map using API snake_case keys.
  /// Used by services when encoding request bodies.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}
