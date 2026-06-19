import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({bool forceRefresh = false});
  Future<void> saveFavorites(Set<int> favoriteIds);
  Future<Set<int>> getFavorites();
}
