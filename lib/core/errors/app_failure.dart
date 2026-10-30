/// Domain-level failure representation for DermaScan AI.
sealed class AppFailure {
  final String message;
  final String? code;

  const AppFailure({required this.message, this.code});

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure({
    super.message = 'Unable to connect. Please check your internet connection.',
    super.code = 'NETWORK_ERROR',
  });
}

final class ServerFailure extends AppFailure {
  const ServerFailure({
    super.message = 'A server error occurred. Please try again later.',
    super.code = 'SERVER_ERROR',
  });
}

final class AuthFailure extends AppFailure {
  const AuthFailure({
    required super.message,
    super.code = 'AUTH_ERROR',
  });
}

final class ValidationFailure extends AppFailure {
  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
  });
}

final class ImageQualityFailure extends AppFailure {
  const ImageQualityFailure({
    super.message = 'The image quality is insufficient for analysis. Please upload a clearer image.',
    super.code = 'IMAGE_QUALITY_INSUFFICIENT',
  });
}

final class LocationPermissionFailure extends AppFailure {
  const LocationPermissionFailure({
    super.message = 'Location access was denied. You can search for a location manually.',
    super.code = 'LOCATION_PERMISSION_DENIED',
  });
}
