import '../../core/network/http_client.dart';
import '../models/product_model.dart';

class ProductRemoteDatasource {
  final HttpClient client;

  ProductRemoteDatasource(this.client);

  Future<List<ProductModel>> getProducts() async {
    final response = await client.get(
      'https://fakestoreapi.com/products',
    );
    final List<dynamic> data = response.data as List<dynamic>;
    return data.map((json) => ProductModel.fromJson(json as Map<String, dynamic>)).toList();
  }
}
