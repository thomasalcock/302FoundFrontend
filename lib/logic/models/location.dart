class Location {
  final int? id;
  final int userId;
  final int latitude;
  final int longitude;

  Location({
    this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'],
      userId: json['user_id'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }
}
