import 'package:propnex_take_home_test/features/products/data/models/product_model.dart';
import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';
import 'package:propnex_take_home_test/features/favorites/domain/entities/favorite.dart';
import 'package:propnex_take_home_test/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:propnex_take_home_test/features/favorites/data/datasources/favorite_local_ds.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource _local;

  FavoriteRepositoryImpl({FavoriteLocalDataSource? local})
    : _local = local ?? FavoriteLocalDataSourceImpl();

  @override
  Future<List<Favorite>> getFavorites() async {
    final raws = await _local.getFavoriteRaws();
    return raws.map((raw) {
      final product = ProductModel.fromJson(
        raw['product'] as Map<String, dynamic>,
      );
      final addedAt = DateTime.parse(raw['addedAt'] as String);
      return Favorite(product: product, addedAt: addedAt);
    }).toList()..sort((a, b) => b.addedAt.compareTo(a.addedAt));
  }

  @override
  Future<void> addFavorite(Product product) =>
      _local.saveFavorite(product, DateTime.now());

  @override
  Future<void> removeFavorite(int productId) =>
      _local.removeFavorite(productId);

  @override
  Future<bool> isFavorite(int productId) async {
    final raws = await _local.getFavoriteRaws();
    return raws.any(
      (r) => (r['product'] as Map<String, dynamic>)['id'] == productId,
    );
  }
}
