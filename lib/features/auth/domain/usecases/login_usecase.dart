import 'package:propnex_take_home_test/features/auth/domain/entities/user.dart';
import 'package:propnex_take_home_test/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  Future<User> execute({
    required String username,
    required String password,
  }) {
    return _repository.login(username: username, password: password);
  }
}
