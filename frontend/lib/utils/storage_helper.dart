import 'package:shared_preferences/shared_preferences.dart';


class KKBStorageHelper {
  KKBStorageHelper._();

  // store user's preferred mode (light or dark)
  static Future<void> setPreferredMode(String mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('preferredMode', mode);
  }

  // get user's preferred mode (light or dark)
  static Future<String> getPreferredMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('preferredMode') ?? 'light';
  }
}