import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';
import 'package:propnex_take_home_test/features/products/domain/repositories/product_repository.dart';
import 'package:propnex_take_home_test/features/products/data/datasources/product_remote_ds.dart';
import 'package:propnex_take_home_test/features/products/data/models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remote;

  ProductRepositoryImpl({ProductRemoteDataSource? remote})
    : _remote = remote ?? ProductRemoteDataSourceImpl();

  @override
  Future<List<Product>> getProducts({int limit = 10, int skip = 0}) =>
      _remote.getProducts(limit: limit, skip: skip);

  @override
  Future<List<Product>> searchProducts(
    String query, {
    int limit = 10,
    int skip = 0,
  }) => _remote.searchProducts(query, limit: limit, skip: skip);

  @override
  Future<Product> getProductById(int id) => _remote.getProductById(id);

  @override
  Future<Product> createProduct(Product product) =>
      _remote.createProduct(product as ProductModel);

  @override
  Future<Product> updateProduct(Product product) async {
    if (product.id > 100) {
      return product;
    }
    return _remote.updateProduct(product as ProductModel);
  }

  @override
  Future<bool> deleteProduct(int id) async {
    if (id > 100) {
      return true;
    }
    return _remote.deleteProduct(id);
  }
}
