import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:propnex_take_home_test/features/favorites/presentation/providers/favorite_provider.dart';
import 'package:propnex_take_home_test/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:propnex_take_home_test/features/products/presentation/screens/product_screen.dart';

class MainScreen extends StatefulWidget {
  static const routeName = '/main';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  static const _screens = [
    ProductScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Consumer<FavoritesProvider>(
        builder: (_, favProvider, _) => NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront_rounded),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: favProvider.count > 0,
                label: Text('${favProvider.count}'),
                child: const Icon(Icons.favorite_border_rounded),
              ),
              selectedIcon: Badge(
                isLabelVisible: favProvider.count > 0,
                label: Text('${favProvider.count}'),
                child: const Icon(Icons.favorite_rounded),
              ),
              label: 'Favorites',
            ),
          ],
        ),
      ),
    );
  }
}
