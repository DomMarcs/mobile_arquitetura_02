import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../errors/failure.dart';

class HttpResponse {
  final dynamic data;
  HttpResponse(this.data);
}

class HttpClient {
  Future<HttpResponse> get(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return HttpResponse(jsonDecode(response.body));
      }

      if (response.statusCode >= 500) {
        throw ServerException('Erro no servidor. Tente novamente mais tarde.');
      }

      throw Failure('Falha ao carregar dados. Código de status: ${response.statusCode}');
    } on SocketException {
      throw NetworkException('Não foi possível conectar. Verifique sua internet.');
    }
  }

  Future<HttpResponse> post(String url, Map<String, dynamic> body) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        return HttpResponse(jsonDecode(response.body));
      }

      if (response.statusCode == 400 || response.statusCode == 401) {
        throw AuthenticationException('Usuário ou senha inválidos.');
      }

      if (response.statusCode >= 500) {
        throw ServerException('Erro no servidor. Tente novamente mais tarde.');
      }

      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        final errorMessage = errorData['message'] as String?;
        if (errorMessage != null && errorMessage.isNotEmpty) {
          throw Failure(errorMessage);
        }
      } catch (_) {
        // Ignore parse errors and fall back to generic message.
      }

      throw Failure('Falha ao autenticar. Código de status: ${response.statusCode}');
    } on SocketException {
      throw NetworkException('Não foi possível conectar. Verifique sua internet.');
    }
  }
}