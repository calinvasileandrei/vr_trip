import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveDeviceNumberToPrefs(String deviceNumber) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString('deviceNumber', deviceNumber);
}

Future<String?> loadDeviceNumberFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('deviceNumber');
}


Future<void> saveManagerIpToPrefs(String? managerIp) async {
  final prefs = await SharedPreferences.getInstance();
  if(managerIp == null) {
    prefs.remove('managerIp');
    return;
  }
  prefs.setString('managerIp', managerIp);
}

Future<String?> loadManagerIpFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('managerIp');
}
