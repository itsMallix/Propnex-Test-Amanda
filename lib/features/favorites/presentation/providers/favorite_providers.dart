import 'package:propnex_take_home_test/core/providers/base_provider.dart';
import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';
import 'package:propnex_take_home_test/features/favorites/domain/entities/favorite.dart';
import 'package:propnex_take_home_test/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:propnex_take_home_test/features/favorites/domain/usecases/favorite_usecase.dart';
import 'package:propnex_take_home_test/features/favorites/data/repositories/favorite_repository_impl.dart';

class FavoritesProvider extends BaseProvider {
  late final GetFavoritesUseCase _getFavorites;
  late final ToggleFavoriteUseCase _toggleFavorite;

  FavoritesProvider({FavoriteRepository? repository}) {
    final repo = repository ?? FavoriteRepositoryImpl();
    _getFavorites = GetFavoritesUseCase(repo);
    _toggleFavorite = ToggleFavoriteUseCase(repo);
    loadFavorites();
  }

  List<Favorite> _favorites = [];
  List<Favorite> get favorites => List.unmodifiable(_favorites);

  int get count => _favorites.length;

  final Set<int> _favoriteIds = {};

  Future<void> loadFavorites() async {
    await run(() async {
      _favorites = await _getFavorites.execute();
      _favoriteIds
        ..clear()
        ..addAll(_favorites.map((f) => f.product.id));
      setEmpty(_favorites.isEmpty);
      if (_favorites.isNotEmpty) setLoaded();
    });
  }

  Future<void> toggleFavorite(Product product) async {
    final wasAdded = _favoriteIds.contains(product.id);

    if (wasAdded) {
      _favoriteIds.remove(product.id);
      _favorites.removeWhere((f) => f.product.id == product.id);
    } else {
      _favoriteIds.add(product.id);
      _favorites.insert(
        0,
        Favorite(product: product, addedAt: DateTime.now()),
      );
    }

    setEmpty(_favorites.isEmpty);
    if (_favorites.isNotEmpty) setLoaded();
    notifyListeners();

    try {
      await _toggleFavorite.execute(product);
    } catch (_) {
      if (wasAdded) {
        _favoriteIds.add(product.id);
        _favorites.insert(
          0,
          Favorite(product: product, addedAt: DateTime.now()),
        );
      } else {
        _favoriteIds.remove(product.id);
        _favorites.removeWhere((f) => f.product.id == product.id);
      }
      notifyListeners();
    }
  }

  bool isFavorite(int productId) => _favoriteIds.contains(productId);
  Future<void> removeFavorite(Product product) async {
    if (!_favoriteIds.contains(product.id)) return;
    await toggleFavorite(product);
  }
}
