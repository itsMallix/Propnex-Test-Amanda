import 'package:flutter/material.dart';
import 'package:propnex_take_home_test/features/main/presentation/screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:propnex_take_home_test/core/providers/view_state_widget.dart';
import 'package:propnex_take_home_test/features/products/presentation/providers/product_providers.dart';
import 'package:propnex_take_home_test/features/products/presentation/screens/product_detail_screen.dart';
import 'package:propnex_take_home_test/features/favorites/presentation/providers/favorite_provider.dart';
import 'package:propnex_take_home_test/features/favorites/presentation/widgets/favorite_card.dart';

class FavoritesScreen extends StatelessWidget {
  static const routeName = '/favorites';

  const FavoritesScreen({super.key});

  void _shareAll(BuildContext context) {
    final favorites = context.read<FavoritesProvider>().favorites;
    if (favorites.isEmpty) return;

    final buffer = StringBuffer('🛍️ My Favorite Products\n\n');
    for (final fav in favorites) {
      final p = fav.product;
      buffer.writeln(
        '• ${p.title} — \$${p.discountedPrice.toStringAsFixed(2)} ⭐${p.rating}',
      );
    }
    Share.share(buffer.toString(), subject: 'My Favorite Products');
  }

  void _openDetail(BuildContext context, dynamic product) {
    context.read<ProductProvider>().selectProduct(product);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: context.read<ProductProvider>(),
            ),
            ChangeNotifierProvider.value(
              value: context.read<FavoritesProvider>(),
            ),
          ],
          child: const ProductDetailScreen(),
        ),
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    FavoritesProvider provider,
    dynamic product,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Favorite'),
        content: Text('Remove "${product.title}" from favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await provider.removeFavorite(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<FavoritesProvider>(
          builder: (_, provider, _) => Text(
            provider.count > 0 ? 'Favorites (${provider.count})' : 'Favorites',
          ),
        ),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (_, provider, _) => provider.count > 0
                ? IconButton(
                    tooltip: 'Share all',
                    icon: const Icon(Icons.share_rounded),
                    onPressed: () => _shareAll(context),
                  )
                : const SizedBox.shrink(),
          ),
          Consumer<FavoritesProvider>(
            builder: (_, provider, _) => provider.count > 0
                ? IconButton(
                    tooltip: 'Clear all',
                    icon: const Icon(Icons.delete_sweep_rounded),
                    onPressed: () => _confirmClearAll(context, provider),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer<FavoritesProvider>(
        builder: (context, provider, _) {
          return ViewStateWidget(
            state: provider.state,
            errorMessage: provider.errorMessage,
            onRetry: provider.loadFavorites,
            emptyWidget: const _EmptyFavorites(),
            child: RefreshIndicator(
              onRefresh: provider.loadFavorites,
              child: _FavoritesList(
                provider: provider,
                onTap: (p) => _openDetail(context, p),
                onRemove: (p) => _confirmRemove(context, provider, p),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmClearAll(
    BuildContext context,
    FavoritesProvider provider,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Favorites'),
        content: const Text('Remove all items from your favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final list = List.of(provider.favorites);
      for (final fav in list) {
        await provider.removeFavorite(fav.product);
      }
    }
  }
}

class _FavoritesList extends StatelessWidget {
  final FavoritesProvider provider;
  final void Function(dynamic) onTap;
  final void Function(dynamic) onRemove;

  const _FavoritesList({
    required this.provider,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final favorites = provider.favorites;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      itemCount: favorites.length,
      itemBuilder: (_, index) {
        final fav = favorites[index];
        final product = fav.product;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: ValueKey(product.id),
            direction: DismissDirection.endToStart,
            background: _RemoveBackground(),
            onDismissed: (_) => provider.removeFavorite(product),
            child: FavoriteCard(
              favorite: fav,
              onTap: () => onTap(product),
              onRemove: () => onRemove(product),
            ),
          ),
        );
      },
    );
  }
}

class _RemoveBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 4),
          Text(
            'Remove',
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 600),
            curve: Curves.elasticOut,
            builder: (_, scale, child) =>
                Transform.scale(scale: scale, child: child),
            child: Icon(
              Icons.favorite_border_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No favorites yet',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the love icons on any product\nto save it here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MainScreen(),
              ),
            ),
            child: const Text('Browse Products'),
          ),
        ],
      ),
    );
  }
}
