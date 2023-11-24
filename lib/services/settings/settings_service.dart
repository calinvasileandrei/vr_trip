import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveDeviceNumberToPrefs(String deviceNumber) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('deviceNumber', deviceNumber);
}

Future<String?> loadDeviceNumberFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('deviceNumber');
}
