import '../../core/errors/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_cache_datasource.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remote;
  final ProductCacheDatasource cache;

  ProductRepositoryImpl(this.remote, this.cache);

  @override
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = await cache.get();
      if (cached != null && cached.isNotEmpty) {
        final favoriteIds = await cache.getFavorites();
        return cached
            .map(
              (m) => Product(
                id: m.id,
                title: m.title,
                price: m.price,
                image: m.image,
                description: m.description,
                category: m.category,
                favorite: favoriteIds.contains(m.id),
              ),
            )
            .toList();
      }
    }

    try {
      final models = await remote.getProducts();
      await cache.save(models);
      
      final favoriteIds = await cache.getFavorites();
      return models
          .map(
            (m) => Product(
              id: m.id,
              title: m.title,
              price: m.price,
              image: m.image,
              description: m.description,
              category: m.category,
              favorite: favoriteIds.contains(m.id),
            ),
          )
          .toList();
    } catch (e) {
      final cached = await cache.get();
      if (cached != null) {
        final favoriteIds = await cache.getFavorites();
        return cached
            .map(
              (m) => Product(
                id: m.id,
                title: m.title,
                price: m.price,
                image: m.image,
                description: m.description,
                category: m.category,
                favorite: favoriteIds.contains(m.id),
              ),
            )
            .toList();
      }
      throw Failure('Não foi possível carregar os produtos');
    }
  }

  @override
  Future<void> saveFavorites(Set<int> favoriteIds) async {
    await cache.saveFavorites(favoriteIds);
  }

  @override
  Future<Set<int>> getFavorites() async {
    return await cache.getFavorites();
  }
}
