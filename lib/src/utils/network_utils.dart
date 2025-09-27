import 'dart:io';

class NetworkUtils {
  /// Get the local IP address for iOS simulator
  static Future<String> getLocalIP() async {
    try {
      // Get all network interfaces
      final interfaces = await NetworkInterface.list();
      
      // Find the first non-loopback IPv4 address
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (address.type == InternetAddressType.IPv4 && 
              !address.isLoopback && 
              address.address.startsWith('192.168.')) {
            return address.address;
          }
        }
      }
      
      // Fallback to localhost
      return 'localhost';
    } catch (e) {
      return 'localhost';
    }
  }
}