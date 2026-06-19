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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'token': token,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      token: json['token'] as String,
    );
  }
}
