import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({int limit = 10, int skip = 0});
  Future<List<Product>> searchProducts(
    String query, {
    int limit = 10,
    int skip = 0,
  });
  Future<Product> getProductById(int id);
  Future<Product> createProduct(Product product);
  Future<Product> updateProduct(Product product);
  Future<bool> deleteProduct(int id);
}
