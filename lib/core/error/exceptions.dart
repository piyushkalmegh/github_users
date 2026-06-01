/// Custom exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalException;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() => message;
}

/// Exception for network connectivity issues
class NetworkException implements Exception {
  final String message;

  NetworkException({this.message = 'Network error occurred'});

  @override
  String toString() => message;
}

/// Exception for cached data not found
class CacheException implements Exception {
  final String message;

  CacheException({this.message = 'Cache error occurred'});

  @override
  String toString() => message;
}

/// Enum for failure types
enum FailureType {
  network,
  api,
  cache,
  unknown,
}

/// Generic Failure class for error handling
class Failure {
  final String message;
  final FailureType type;
  final dynamic exception;

  Failure({
    required this.message,
    required this.type,
    this.exception,
  });

  /// Factory constructor for network failures
  factory Failure.network(String message) {
    return Failure(
      message: message,
      type: FailureType.network,
    );
  }

  /// Factory constructor for API failures
  factory Failure.api(String message, {int? statusCode}) {
    return Failure(
      message: message,
      type: FailureType.api,
      exception: statusCode,
    );
  }

  /// Factory constructor for cache failures
  factory Failure.cache(String message) {
    return Failure(
      message: message,
      type: FailureType.cache,
    );
  }

  /// Factory constructor for unknown failures
  factory Failure.unknown(String message) {
    return Failure(
      message: message,
      type: FailureType.unknown,
    );
  }
}

