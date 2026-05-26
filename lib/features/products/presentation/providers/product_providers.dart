import 'dart:async';
import 'package:flutter/material.dart';
import 'package:propnex_take_home_test/core/providers/base_provider.dart';
import 'package:propnex_take_home_test/features/products/data/models/product_model.dart';
import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';
import 'package:propnex_take_home_test/features/products/domain/repositories/product_repository.dart';
import 'package:propnex_take_home_test/features/products/domain/usecases/product_usecase.dart';
import 'package:propnex_take_home_test/features/products/data/repositories/product_repository_impl.dart';

class ProductProvider extends BaseProvider {
  late final GetProductsUseCase _getProducts;
  late final SearchProductsUseCase _searchProducts;
  late final CreateProductUseCase _createProduct;
  late final UpdateProductUseCase _updateProduct;
  late final DeleteProductUseCase _deleteProduct;

  ProductProvider({ProductRepository? repository}) {
    final repo = repository ?? ProductRepositoryImpl();
    _getProducts = GetProductsUseCase(repo);
    _searchProducts = SearchProductsUseCase(repo);
    _createProduct = CreateProductUseCase(repo);
    _updateProduct = UpdateProductUseCase(repo);
    _deleteProduct = DeleteProductUseCase(repo);
  }

  final List<Product> _products = [];
  List<Product> get products => List.unmodifiable(_products);

  static const int _pageSize = 10;
  int _skip = 0;
  bool _hasMore = true;
  bool _loadingMore = false;
  bool get hasMore => _hasMore;
  bool get loadingMore => _loadingMore;

  String _query = '';
  String get query => _query;
  bool get isSearching => _query.isNotEmpty;
  Timer? _debounce;

  Product? _selected;
  Product? get selected => _selected;

  Future<void> fetchProducts({bool isRefresh = false}) async {
    if (isRefresh) {
      _reset();
    }

    await run(
      () async {
        final result = await _getProducts.execute(
          limit: _pageSize,
          skip: _skip,
        );
        _products.addAll(result);
        _skip += result.length;
        _hasMore = result.length == _pageSize;
        setEmpty(_products.isEmpty);
        if (_products.isNotEmpty) setLoaded();
      },
      showLoading: _products.isEmpty,
    );
  }

  Future<void> loadMore() async {
    if (_loadingMore || !_hasMore || isSearching) return;

    _loadingMore = true;
    notifyListeners();

    try {
      final result = await _getProducts.execute(
        limit: _pageSize,
        skip: _skip,
      );
      _products.addAll(result);
      _skip += result.length;
      _hasMore = result.length == _pageSize;
    } catch (e) {
      debugPrint('loadMore error: $e');
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  void onSearchChanged(String query) {
    _debounce?.cancel();
    _query = query.trim();

    if (_query.isEmpty) {
      _reset();
      fetchProducts();
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _resetSearch();
      _runSearch();
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    _query = '';
    _reset();
    fetchProducts();
  }

  Future<void> _runSearch() async {
    await run(() async {
      final result = await _searchProducts.execute(
        _query,
        limit: _pageSize,
        skip: _skip,
      );
      _products.addAll(result);
      _skip += result.length;
      _hasMore = result.length == _pageSize;
      setEmpty(_products.isEmpty);
      if (_products.isNotEmpty) setLoaded();
    });
  }

  Future<bool> createProduct({
    required String title,
    required String description,
    required double price,
    required int stock,
    required String brand,
    required String category,
    String thumbnail = '',
  }) async {
    bool success = false;
    await runBusy(() async {
      final newProduct = ProductModel(
        id: 0,
        title: title,
        description: description,
        price: price,
        discountPercentage: 0,
        rating: 0,
        stock: stock,
        brand: brand,
        category: category,
        thumbnail: thumbnail,
        images: [],
      );
      final created = await _createProduct.execute(newProduct);
      _products.insert(0, created);
      success = true;
    });
    return success;
  }

  Future<bool> updateProduct({
    required Product product,
    required String title,
    required String description,
    required double price,
    required int stock,
    required String brand,
    required String category,
  }) async {
    bool success = false;
    await runBusy(() async {
      final model = product as ProductModel;
      final updated = await _updateProduct.execute(
        model.copyWith(
          title: title,
          description: description,
          price: price,
          stock: stock,
          brand: brand,
          category: category,
        ),
      );
      final idx = _products.indexWhere((p) => p.id == updated.id);
      if (idx != -1) _products[idx] = updated;
      _selected = updated;
      success = true;
    });
    return success;
  }

  Future<bool> deleteProduct(int id) async {
    bool success = false;
    await runBusy(() async {
      final ok = await _deleteProduct.execute(id);
      if (ok) {
        _products.removeWhere((p) => p.id == id);
        if (_products.isEmpty) setEmpty();
      }
      success = ok;
    });
    return success;
  }

  void selectProduct(Product product) {
    _selected = product;
    notifyListeners();
  }

  void _reset() {
    _products.clear();
    _skip = 0;
    _hasMore = true;
    _query = '';
  }

  void _resetSearch() {
    _products.clear();
    _skip = 0;
    _hasMore = true;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
