
import 'dart:io';

class NetworkUtils {

  static bool isValidIpAddress(String ip) {
    // Try to parse the string as an IP address
    InternetAddress? result = InternetAddress.tryParse(ip);

    // Check if the result is not null (meaning the parse was successful)
    return result != null;
  }
}
