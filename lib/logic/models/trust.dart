class Trust {
  final int? id;
  final int userId;
  final int trusteeId;

  Trust({this.id, required this.userId, required this.trusteeId});

  factory Trust.fromJson(Map<String, dynamic> json) {
    return Trust(
      id: json['id'],
      userId: json['user_id'],
      trusteeId: json['trustee_id'],
    );
  }
}
