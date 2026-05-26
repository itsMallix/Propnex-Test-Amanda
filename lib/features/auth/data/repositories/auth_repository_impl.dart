import 'dart:convert';

import 'package:propnex_take_home_test/core/network/http_client.dart';
import 'package:propnex_take_home_test/features/auth/data/datasources/auth_remote_ds.dart';
import 'package:propnex_take_home_test/features/auth/data/models/user_model.dart';
import 'package:propnex_take_home_test/features/auth/domain/entities/user.dart';
import 'package:propnex_take_home_test/features/auth/domain/repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;

  static const _keyUser = 'saved_user';
  static const _keyToken = 'auth_token';

  AuthRepositoryImpl({AuthRemoteDataSource? remote})
    : _remote = remote ?? AuthRemoteDataSourceImpl();

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final user = await _remote.login(username: username, password: password);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, user.token);
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));

    HttpClient().setAuthToken(user.token);

    return user;
  }

  @override
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUser);
    HttpClient().clearAuthToken();
  }

  @override
  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyUser);
    final token = prefs.getString(_keyToken);

    if (raw == null || token == null) return null;

    HttpClient().setAuthToken(token);
    return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
