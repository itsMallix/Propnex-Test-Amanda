class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class BadRequestException extends ApiException {
  const BadRequestException({required super.message, super.statusCode});
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({required super.message, super.statusCode});
}

class NotFoundException extends ApiException {
  const NotFoundException({required super.message, super.statusCode});
}

class ServerException extends ApiException {
  const ServerException({required super.message, super.statusCode});
}

class NetworkException extends ApiException {
  const NetworkException({required super.message}) : super(statusCode: null);
}

String friendlyError(Object e) {
  if (e is NetworkException) {
    return 'No internet connection. Please try again.';
  } else if (e is UnauthorizedException) {
    return 'Session expired. Please log in again.';
  } else if (e is NotFoundException) {
    return 'The requested item was not found.';
  } else if (e is ServerException) {
    return 'Server error. Please try again later.';
  } else if (e is ApiException) {
    return e.message;
  }
  return 'Something went wrong. Please try again.';
}
