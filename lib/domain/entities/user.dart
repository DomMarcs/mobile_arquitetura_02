class User {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String token;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.token,
  });

  String get fullName => '$firstName $lastName';
}
