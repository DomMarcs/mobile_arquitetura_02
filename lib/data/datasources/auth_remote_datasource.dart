import '../../core/network/http_client.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDatasource {
  final HttpClient client;

  AuthRemoteDatasource(this.client);

  Future<AuthResponseModel> login(String username, String password) async {
    final response = await client.post(
      'https://dummyjson.com/auth/login',
      {
        'username': username,
        'password': password,
      },
    );

    final data = response.data as Map<String, dynamic>;
    return AuthResponseModel.fromJson(data);
  }
}
