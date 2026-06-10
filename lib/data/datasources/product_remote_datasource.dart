import '../../core/network/http_client.dart';
import '../models/product_model.dart';

class ProductRemoteDatasource {
  final HttpClient client;

  ProductRemoteDatasource(this.client);

  Future<List<ProductModel>> getProducts() async {
    final response = await client.get(
      'https://dummyjson.com/products',
    );
    final data = response.data as Map<String, dynamic>;
    final List<dynamic> products = data['products'] as List<dynamic>;
    return products
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}