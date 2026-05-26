import 'package:propnex_take_home_test/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login({required String username, required String password});

  Future<void> logout();

  Future<User?> getSavedUser();
}
