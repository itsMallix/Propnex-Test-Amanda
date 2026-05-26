import 'package:flutter/material.dart';
import 'package:propnex_take_home_test/core/theme/app_theme.dart';
import 'package:propnex_take_home_test/features/auth/presentation/providers/auth_providers.dart';
import 'package:propnex_take_home_test/features/auth/presentation/screens/auth_gate_screen.dart';
import 'package:propnex_take_home_test/features/auth/presentation/screens/login_screen.dart';
import 'package:propnex_take_home_test/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:propnex_take_home_test/features/products/presentation/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';
import 'features/products/presentation/providers/product_providers.dart';
import 'features/favorites/presentation/providers/favorite_provider.dart';
import 'features/main/presentation/screens/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => FavoritesProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Propnex Take Home Test',
        theme: AppTheme.theme,
        home: AuthGate(),
        routes: {
          LoginScreen.routeName: (_) => const LoginScreen(),
          MainScreen.routeName: (_) => const MainScreen(),
          ProductDetailScreen.routeName: (_) => const ProductDetailScreen(),
          FavoritesScreen.routeName: (_) => const FavoritesScreen(),
        },
      ),
    );
  }
}
