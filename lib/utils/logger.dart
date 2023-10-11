class Logger {
  static final _prefix = '[VR_TRIP]';

  static void log(String message) {
    print("${_prefix} [INFO] $message");
  }

  static void warn(String message) {
    print("${_prefix} [WARNING] $message");
  }

  static void error(String message) {
    print("${_prefix} [ERROR] $message");
  }
}
