import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

/// Network connectivity service
class NetworkService {
  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();

  /// Check if device has internet connectivity
  Future<bool> hasInternet() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _isConnected(result);
    } catch (e) {
      _logger.e('Network check error: $e');
      // If check fails, we assume there's internet to let the request fail naturally
      return true; 
    }
  }

  bool _isConnected(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream {
    return _connectivity.onConnectivityChanged.map((result) {
      return _isConnected(result);
    });
  }
}
