import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

class ProductCacheDatasource {
  static const String _productsKey = 'cached_products';
  static const String _favoritesKey = 'favorite_product_ids';
  List<ProductModel>? _memoryCache;

  Future<void> save(List<ProductModel> products) async {
    _memoryCache = products;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = products.map((p) => p.toJson()).toList();
      await prefs.setString(_productsKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  Future<List<ProductModel>?> get() async {
    if (_memoryCache != null) return _memoryCache;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_productsKey);
      if (jsonStr != null) {
        final List<dynamic> jsonList = jsonDecode(jsonStr) as List<dynamic>;
        _memoryCache = jsonList
            .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return _memoryCache;
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveFavorites(Set<int> favoriteIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = favoriteIds.map((id) => id.toString()).toList();
      await prefs.setStringList(_favoritesKey, stringList);
    } catch (_) {}
  }

  Future<Set<int>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stringList = prefs.getStringList(_favoritesKey);
      if (stringList != null) {
        return stringList.map((s) => int.parse(s)).toSet();
      }
    } catch (_) {}
    return {};
  }
}
