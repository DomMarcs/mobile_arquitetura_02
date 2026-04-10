import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductService {
  ProductService({http.Client? client}) : _client = client ?? http.Client();

  static const String _fakeStoreBaseUrl = 'https://fakestoreapi.com/products';
  static const String _dummyJsonBaseUrl = 'https://dummyjson.com/products';
  final http.Client _client;
  String? _resolvedBaseUrl;

  List<String> get _baseUrls => [
    _resolvedBaseUrl,
    _fakeStoreBaseUrl,
    _dummyJsonBaseUrl,
  ].whereType<String>().toSet().toList();

  Future<List<Product>> fetchProducts() async {
    Exception? lastError;
    for (final baseUrl in _baseUrls) {
      try {
        final response = await _client.get(Uri.parse(baseUrl));
        if (response.statusCode != 200) {
          throw Exception('Falha ao buscar produtos (${response.statusCode})');
        }

        final decoded = jsonDecode(response.body);
        final data = _extractProductList(decoded);
        _resolvedBaseUrl = baseUrl;
        return data
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        lastError = Exception(e.toString());
      }
    }

    throw Exception('Falha ao buscar produtos: $lastError');
  }

  Future<Product> addProduct(Product product) async {
    final baseUrl = _resolvedBaseUrl ?? _dummyJsonBaseUrl;
    final postUrl = baseUrl == _dummyJsonBaseUrl ? '$baseUrl/add' : baseUrl;
    final response = await _client.post(
      Uri.parse(postUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Falha ao cadastrar produto (${response.statusCode})');
    }

    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<Product> updateProduct(Product product) async {
    if (product.id == null) {
      throw Exception('Produto sem id para atualizar');
    }

    final baseUrl = _resolvedBaseUrl ?? _dummyJsonBaseUrl;
    final response = await _client.put(
      Uri.parse('$baseUrl/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Falha ao atualizar produto (${response.statusCode})');
    }

    return Product.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteProduct(String id) async {
    final baseUrl = _resolvedBaseUrl ?? _dummyJsonBaseUrl;
    final response = await _client.delete(Uri.parse('$baseUrl/$id'));

    // APIs mock podem retornar 404 para registros nao persistidos.
    if (response.statusCode != 200 &&
        response.statusCode != 204 &&
        response.statusCode != 404) {
      throw Exception('Falha ao excluir produto (${response.statusCode})');
    }
  }

  List<dynamic> _extractProductList(dynamic decoded) {
    if (decoded is List<dynamic>) {
      return decoded;
    }
    if (decoded is Map<String, dynamic> &&
        decoded['products'] is List<dynamic>) {
      return decoded['products'] as List<dynamic>;
    }
    throw Exception('Formato de resposta inesperado');
  }
}
