import 'package:flutter/foundation.dart';
import 'package:propnex_take_home_test/core/network/api_exception.dart';

enum ViewState {
  idle,
  loading,
  loaded,
  empty,
  error,
  busy,
}

abstract class BaseProvider extends ChangeNotifier {
  ViewState _state = ViewState.idle;
  String _errorMessage = '';
  bool _disposed = false;

  ViewState get state => _state;
  String get errorMessage => _errorMessage;

  bool get isIdle => _state == ViewState.idle;
  bool get isLoading => _state == ViewState.loading;
  bool get isLoaded => _state == ViewState.loaded;
  bool get isEmpty => _state == ViewState.empty;
  bool get isError => _state == ViewState.error;
  bool get isBusy => _state == ViewState.busy;

  void setIdle() => _setState(ViewState.idle);
  void setLoading() => _setState(ViewState.loading);
  void setLoaded() => _setState(ViewState.loaded);
  void setEmpty([bool condition = true]) => _setState(
    condition ? ViewState.empty : ViewState.loaded,
  );
  void setBusy() => _setState(ViewState.busy);

  void setError(String message) {
    _errorMessage = message;
    _setState(ViewState.error);
  }

  void clearError() {
    _errorMessage = '';
    if (_state == ViewState.error) setIdle();
  }

  void _setState(ViewState newState) {
    if (_disposed) return;
    _state = newState;
    notifyListeners();
  }

  Future<void> run(
    Future<void> Function() action, {
    bool showLoading = true,
  }) async {
    if (showLoading) setLoading();
    try {
      await action();
      if (isLoading) setLoaded();
    } catch (e) {
      setError(friendlyError(e));
    }
  }

  Future<void> runBusy(Future<void> Function() action) async {
    setBusy();
    try {
      await action();
      if (isBusy) setLoaded();
    } catch (e) {
      setError(friendlyError(e));
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
