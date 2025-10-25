class TrustedPerson {
  final String name;
  final String phoneNumber;

  TrustedPerson({required this.name, required this.phoneNumber});

  @override
  String toString() {
    return 'TrustedPerson{name: $name, phoneNumber: $phoneNumber}';
  }
}
