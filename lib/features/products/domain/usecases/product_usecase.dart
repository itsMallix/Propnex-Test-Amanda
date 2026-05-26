import 'package:propnex_take_home_test/features/products/domain/entities/product.dart';
import 'package:propnex_take_home_test/features/products/domain/repositories/product_repository.dart';

class GetProductsUseCase {
  final ProductRepository _repo;
  GetProductsUseCase(this._repo);

  Future<List<Product>> execute({int limit = 10, int skip = 0}) =>
      _repo.getProducts(limit: limit, skip: skip);
}

class SearchProductsUseCase {
  final ProductRepository _repo;
  SearchProductsUseCase(this._repo);

  Future<List<Product>> execute(String query, {int limit = 10, int skip = 0}) =>
      _repo.searchProducts(query, limit: limit, skip: skip);
}

class GetProductByIdUseCase {
  final ProductRepository _repo;
  GetProductByIdUseCase(this._repo);

  Future<Product> execute(int id) => _repo.getProductById(id);
}

class CreateProductUseCase {
  final ProductRepository _repo;
  CreateProductUseCase(this._repo);

  Future<Product> execute(Product product) => _repo.createProduct(product);
}

class UpdateProductUseCase {
  final ProductRepository _repo;
  UpdateProductUseCase(this._repo);

  Future<Product> execute(Product product) => _repo.updateProduct(product);
}

class DeleteProductUseCase {
  final ProductRepository _repo;
  DeleteProductUseCase(this._repo);

  Future<bool> execute(int id) => _repo.deleteProduct(id);
}
