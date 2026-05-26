import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';
import 'package:propnex_take_home_test/features/favorites/domain/entities/favorite.dart';
import 'package:propnex_take_home_test/features/favorites/domain/repositories/favorite_repository.dart';

class GetFavoritesUseCase {
  final FavoriteRepository _repo;
  GetFavoritesUseCase(this._repo);

  Future<List<Favorite>> execute() => _repo.getFavorites();
}

class ToggleFavoriteUseCase {
  final FavoriteRepository _repo;
  ToggleFavoriteUseCase(this._repo);

  Future<bool> execute(Product product) async {
    final already = await _repo.isFavorite(product.id);
    if (already) {
      await _repo.removeFavorite(product.id);
      return false;
    } else {
      await _repo.addFavorite(product);
      return true;
    }
  }
}

class IsFavoriteUseCase {
  final FavoriteRepository _repo;
  IsFavoriteUseCase(this._repo);

  Future<bool> execute(int productId) => _repo.isFavorite(productId);
}
