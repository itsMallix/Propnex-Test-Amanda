import 'package:propnex_take_home_test/core/constants/api_constants.dart';
import 'package:propnex_take_home_test/core/network/http_client.dart';
import 'package:propnex_take_home_test/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final HttpClient _client;

  AuthRemoteDataSourceImpl({HttpClient? client})
    : _client = client ?? HttpClient();

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.loginEndpoint,
      body: {
        'username': username,
        'password': password,
        'expiresInMins': 60,
      },
    );
    return UserModel.fromJson(response as Map<String, dynamic>);
  }
}
