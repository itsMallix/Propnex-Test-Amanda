import '../../../../core/network/http_client.dart';
import '../models/user_model.dart';

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
    // POST https://dummyjson.com/auth/login
    // Returns: { id, username, email, firstName, lastName, image, token, ... }
    final response = await _client.post(
      '/auth/login',
      body: {
        'username': username,
        'password': password,
        'expiresInMins': 60,
      },
    );
    return UserModel.fromJson(response as Map<String, dynamic>);
  }
}
