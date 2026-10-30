/// Infrastructure and Network Exceptions.
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network connection error.',
    super.code = 'NETWORK_EXCEPTION',
    super.details,
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message = 'Internal server exception.',
    super.code = 'SERVER_EXCEPTION',
    super.details,
  });
}

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_EXCEPTION',
    super.details,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Session expired or unauthorized.',
    super.code = 'UNAUTHORIZED',
    super.details,
  });
}
