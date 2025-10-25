class User {
  final int id;
  final String auth_token;
  final String user_name;
  final String full_name;
  final String phone_number;
  final String email;
  final int alias;

  User({
    required this.id,
    required this.auth_token,
    required this.user_name,
    required this.full_name,
    required this.phone_number,
    required this.email,
    required this.alias,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      auth_token: json['access_token'],
      user_name: json['user_name'],
      full_name: json['full_name'],
      phone_number: json['phone_number'],
      email: json['email'],
      alias: json['alias'],
    );
  }
}