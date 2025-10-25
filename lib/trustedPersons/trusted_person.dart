class TrustedPerson {
  final String name;
  final String phoneNumber;
  final String email;

  TrustedPerson({
    required this.name,
    required this.phoneNumber,
    required this.email,
  });

  @override
  String toString() {
    return 'TrustedPerson{name: $name, phone: $phoneNumber, email: $email}';
  }
}
