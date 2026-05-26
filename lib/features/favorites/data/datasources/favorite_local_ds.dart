import 'dart:convert';
import 'package:propnex_take_home_test/features/products/data/models/product_model.dart';
import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FavoriteLocalDataSource {
  Future<List<Map<String, dynamic>>> getFavoriteRaws();
  Future<void> saveFavorite(Product product, DateTime addedAt);
  Future<void> removeFavorite(int productId);
}

class FavoriteLocalDataSourceImpl implements FavoriteLocalDataSource {
  static const _key = 'favorites';

  @override
  Future<List<Map<String, dynamic>>> getFavoriteRaws() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
  }

  @override
  Future<void> saveFavorite(Product product, DateTime addedAt) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];

    final exists = list.any((e) {
      final m = jsonDecode(e) as Map<String, dynamic>;
      return m['product']['id'] == product.id;
    });
    if (exists) return;

    final entry = jsonEncode({
      'addedAt': addedAt.toIso8601String(),
      'product': (product as ProductModel).toJson(),
    });
    list.add(entry);
    await prefs.setStringList(_key, list);
  }

  @override
  Future<void> removeFavorite(int productId) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.removeWhere((e) {
      final m = jsonDecode(e) as Map<String, dynamic>;
      return m['product']['id'] == productId;
    });
    await prefs.setStringList(_key, list);
  }
}
