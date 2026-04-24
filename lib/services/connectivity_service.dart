import 'dart:io';

class ConnectivityService {
  /// Checks if the device has an active internet connection by
  /// performing a DNS lookup for a reliable host.
  /// Returns true when reachable, false otherwise.
  static Future<bool> hasConnection({
    Duration timeout = const Duration(seconds: 5),
  }) async {
    try {
      final result = await InternetAddress.lookup(
        'example.com',
      ).timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
