import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';
import 'package:propnex_take_home_test/features/favorites/domain/entities/favorite.dart';

abstract class FavoriteRepository {
  Future<List<Favorite>> getFavorites();
  Future<void> addFavorite(Product product);
  Future<void> removeFavorite(int productId);
  Future<bool> isFavorite(int productId);
}
