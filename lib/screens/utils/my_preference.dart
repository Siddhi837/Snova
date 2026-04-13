import 'package:shared_preferences/shared_preferences.dart';

class MyPreference {

  static const String isLoginKey = "isLogin";
  static const String emailKey = "email";

  static Future<void> setLogin(bool value, String emailStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoginKey, value);
    await prefs.setString(emailKey, emailStr);
  }

  static Future<bool> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoginKey) ?? false;
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(emailKey);
  }

  static Future<void> clearLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(isLoginKey);
    await prefs.remove(emailKey);
  }
}