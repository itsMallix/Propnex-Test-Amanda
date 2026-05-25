import '../entities/user.dart';

abstract class AuthRepository {
  /// Login with [username] and [password].
  /// Returns authenticated [User] on success.
  Future<User> login({required String username, required String password});

  /// Clears stored session data.
  Future<void> logout();

  /// Returns saved [User] from local storage, or null if not logged in.
  Future<User?> getSavedUser();
}
