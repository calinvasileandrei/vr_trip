import 'package:flutter_dotenv/flutter_dotenv.dart';

class Logger {
  static final _prefix = '[VR_TRIP]';
  static final _isActive = dotenv.get('PROD') == 'false' ? true : false;

  static void log(String message) {
    if (!_isActive) return;
    print("${_prefix} [INFO] $message");
  }

  static void warn(String message) {
    if (!_isActive) return;
    print("${_prefix} [WARNING] $message");
  }

  static void error(String message) {
    if (!_isActive) return;
    print("${_prefix} [ERROR] $message");
  }
}
