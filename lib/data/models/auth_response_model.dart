import '../../domain/entities/user.dart';

class AuthResponseModel {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String token;

  AuthResponseModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.token,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      token: (json['accessToken'] ?? json['token']) as String,
    );
  }

  User toEntity() {
    return User(
      id: id,
      username: username,
      firstName: firstName,
      lastName: lastName,
      token: token,
    );
  }
}
