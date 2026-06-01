import 'package:dio/dio.dart';
import 'package:github_users/core/error/exceptions.dart';
import 'package:github_users/core/utils/constants.dart';
import 'package:logger/logger.dart';

/// HTTP client wrapper using Dio
class DioClient {
  late Dio _dio;
  final Logger _logger = Logger();

  DioClient() {
    _initializeDio();
  }

  /// Initialize Dio with base configuration
  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/vnd.github+json',
          'User-Agent': 'github_users_app', // GitHub API requires a User-Agent header
          'X-GitHub-Api-Version': '2022-11-28',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('Request: ${options.method} ${options.baseUrl}${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d('Response: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Dio Error: ${error.type} - ${error.message}');
          if (error.response != null) {
            _logger.e('Error Data: ${error.response?.data}');
          }
          return handler.next(error);
        },
      ),
    );
  }

  /// GET request
  Future<T> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParameters,
        options: options,
      );

      return response.data as T;
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      _logger.e('Unexpected error in GET $endpoint: $e');
      throw ApiException(message: e.toString());
    }
  }

  /// Handle Dio exceptions and convert to ApiException
  ApiException _handleDioException(DioException exception) {
    String message = 'An error occurred';

    switch (exception.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout';
        break;
      case DioExceptionType.badResponse:
        final data = exception.response?.data;
        if (data is Map && data.containsKey('message')) {
          message = data['message'];
        } else {
          message = 'HTTP ${exception.response?.statusCode}: ${exception.response?.statusMessage ?? 'Bad Response'}';
        }
        break;
      case DioExceptionType.cancel:
        message = 'Request cancelled';
        break;
      case DioExceptionType.connectionError:
        message = 'Connection error. Please check your internet or CORS settings if on Web.';
        break;
      default:
        message = exception.message ?? 'Unknown network error';
    }

    return ApiException(
      message: message,
      statusCode: exception.response?.statusCode,
      originalException: exception,
    );
  }
}
