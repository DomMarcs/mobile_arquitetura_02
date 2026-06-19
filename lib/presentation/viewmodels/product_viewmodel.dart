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

  Future<void> loadProducts({bool forceRefresh = false}) async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners(); // Atualiza UI para estado de carregamento.

    String? error;
    try {
      final loaded = await repository.getProducts(forceRefresh: forceRefresh);
      _state = _state.copyWith(products: loaded);
    } catch (e) {
      error = e.toString(); // `Failure.toString()` retorna a mensagem.
      debugPrint('Failed to load products: $error');
      _state = _state.copyWith(error: error);
    }

    _state = _state.copyWith(isLoading: false, error: error);
    notifyListeners(); // Atualiza UI para estado final (sucesso/erro).
  }

  void toggleFavorite(int id) async {
    final index = _products.indexWhere((p) => p.id == id);
    if (index == -1) return;

    _products[index].favorite = !_products[index].favorite;
    debugPrint('Product $id favorite => ${_products[index].favorite}');
    notifyListeners();

    final favoriteIds = _products.where((p) => p.favorite).map((p) => p.id).toSet();
    await repository.saveFavorites(favoriteIds);
  }

  void setShowFavoritesOnly(bool value) {
    if (_showFavoritesOnly == value) return;
    _showFavoritesOnly = value;
    notifyListeners();
  }
}
