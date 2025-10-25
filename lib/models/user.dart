class User {
  final int? id;
  final String username;
  final String fullname;
  final String? phonenumber;
  final String? email;
  final int? alias;

  User({
    this.id,
    required this.username,
    required this.fullname,
    this.phonenumber,
    this.email,
    this.alias,
  });

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
