import 'package:propnex_take_home_test/core/constants/api_constants.dart';
import 'package:propnex_take_home_test/core/network/http_client.dart';
import 'package:propnex_take_home_test/features/products/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({int limit = 10, int skip = 0});
  Future<List<ProductModel>> searchProducts(
    String query, {
    int limit = 10,
    int skip = 0,
  });
  Future<ProductModel> getProductById(int id);
  Future<ProductModel> createProduct(ProductModel product);
  Future<ProductModel> updateProduct(ProductModel product);
  Future<bool> deleteProduct(int id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final HttpClient _client;

  ProductRemoteDataSourceImpl({HttpClient? client})
    : _client = client ?? HttpClient();

  @override
  Future<List<ProductModel>> getProducts({int limit = 10, int skip = 0}) async {
    final response = await _client.get(
      ApiConstants.productsEndpoint,
      queryParams: {'limit': '$limit', 'skip': '$skip'},
    );
    return _parseList(response);
  }

  @override
  Future<List<ProductModel>> searchProducts(
    String query, {
    int limit = 10,
    int skip = 0,
  }) async {
    final response = await _client.get(
      ApiConstants.productsSearchEndpoint,
      queryParams: {'q': query, 'limit': '$limit', 'skip': '$skip'},
    );
    return _parseList(response);
  }

  @override
  Future<ProductModel> getProductById(int id) async {
    final response = await _client.get('${ApiConstants.productsEndpoint}/$id');
    return ProductModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await _client.post(
      ApiConstants.productsAddEndpoint,
      body: product.toRequestBody(),
    );
    return ProductModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await _client.put(
      '${ApiConstants.productsEndpoint}/${product.id}',
      body: product.toRequestBody(),
    );
    return ProductModel.fromJson(response as Map<String, dynamic>);
  }

  @override
  Future<bool> deleteProduct(int id) async {
    final response = await _client.delete(
      '${ApiConstants.productsEndpoint}/$id',
    );
    final map = response as Map<String, dynamic>;
    return map['isDeleted'] == true;
  }

  List<ProductModel> _parseList(dynamic response) {
    final map = response as Map<String, dynamic>;
    final list = map['products'] as List<dynamic>;
    return list
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
