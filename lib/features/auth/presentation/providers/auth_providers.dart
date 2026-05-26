import 'package:propnex_take_home_test/core/providers/base_provider.dart';
import 'package:propnex_take_home_test/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:propnex_take_home_test/features/auth/domain/entities/user.dart';
import 'package:propnex_take_home_test/features/auth/domain/repositories/auth_repository.dart';
import 'package:propnex_take_home_test/features/auth/domain/usecases/login_usecase.dart';

class AuthProvider extends BaseProvider {
  final AuthRepository _repository;
  late final LoginUseCase _loginUseCase;

  User? _currentUser;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  AuthProvider({AuthRepository? repository})
    : _repository = repository ?? AuthRepositoryImpl() {
    _loginUseCase = LoginUseCase(_repository);
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    final saved = await _repository.getSavedUser();
    if (saved != null) {
      _currentUser = saved;
      setLoaded();
    } else {
      setIdle();
    }
  }

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    bool success = false;
    await run(() async {
      _currentUser = await _loginUseCase.execute(
        username: username,
        password: password,
      );
      setLoaded();
      success = true;
    });
    return success;
  }

  Future<void> logout() async {
    await runBusy(() async {
      await _repository.logout();
      _currentUser = null;
      setIdle();
    });
  }
}
