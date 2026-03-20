import 'package:flutter/foundation.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_state.dart';

class ProductViewModel extends ChangeNotifier {
  final ProductRepository repository;

  ProductState _state = const ProductState();
  bool _showFavoritesOnly = false;

  ProductViewModel(this.repository);

  bool get isLoading => _state.isLoading;
  String? get error => _state.error;
  bool get showFavoritesOnly => _showFavoritesOnly;
  List<Product> get products => _state.products;

  int get favoriteCount => _state.products.where((p) => p.favorite).length;

  List<Product> get visibleProducts {
    if (!_showFavoritesOnly) return _products;
    return _state.products.where((p) => p.favorite).toList();
  }

  // Local getter com o nome antigo, para minimizar mudanças no resto do arquivo.
  List<Product> get _products => _state.products;

  Future<void> loadProducts() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners(); // Atualiza UI para estado de carregamento.

    String? error;
    try {
      final loaded = await repository.getProducts();
      final favoriteIds =
          _state.products.where((p) => p.favorite).map((p) => p.id).toSet();
      for (final product in loaded) {
        product.favorite = favoriteIds.contains(product.id);
      }
      debugPrint(
        'Loaded ${loaded.length} products. Favorites kept: ${loaded.where((p) => p.favorite).length}',
      );
      _state = _state.copyWith(products: loaded);
    } catch (e) {
      error = e.toString(); // `Failure.toString()` retorna a mensagem.
      debugPrint('Failed to load products: $error');
      _state = _state.copyWith(error: error);
    }

    _state = _state.copyWith(isLoading: false, error: error);
    notifyListeners(); // Atualiza UI para estado final (sucesso/erro).
  }

  void toggleFavorite(int id) {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) return;

    _products[index].favorite = !_products[index].favorite;
    debugPrint('Product $id favorite => ${_products[index].favorite}');
    notifyListeners();
  }

  void setShowFavoritesOnly(bool value) {
    if (_showFavoritesOnly == value) return;
    _showFavoritesOnly = value;
    notifyListeners();
  }
}
