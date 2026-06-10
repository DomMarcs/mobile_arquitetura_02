import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpResponse {
  final dynamic data;
  HttpResponse(this.data);
}

class HttpClient {
  Future<HttpResponse> get(String url) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return HttpResponse(jsonDecode(response.body));
    }
    throw Exception('Falha ao carregar dados. Código de status: ${response.statusCode}');
  }

  Future<HttpResponse> post(String url, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      return HttpResponse(jsonDecode(response.body));
    }
    throw Exception('Falha ao autenticar. Código de status: ${response.statusCode}');
  }
}