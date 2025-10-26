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
  /// @param json decoded JSON map from the backend
  /// @return Location instance
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      userId: json['user_id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
