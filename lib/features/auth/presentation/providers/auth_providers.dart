import '../../../../core/providers/base_provider.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';

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

  // ---------------------------------------------------------------------------
  // Auto-login on cold start
  // ---------------------------------------------------------------------------

  Future<void> _tryAutoLogin() async {
    final saved = await _repository.getSavedUser();
    if (saved != null) {
      _currentUser = saved;
      setLoaded();
    } else {
      setIdle();
    }
  }

  // ---------------------------------------------------------------------------
  // Login
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Logout
  // ---------------------------------------------------------------------------

  Future<void> logout() async {
    await runBusy(() async {
      await _repository.logout();
      _currentUser = null;
      setIdle();
    });
  }
}
