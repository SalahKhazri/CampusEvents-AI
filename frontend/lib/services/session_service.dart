import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:campus_events_ai/models/user_model.dart';

class SessionService {
  static const String _userKey = 'current_user';
  static const String _themeKey = 'theme_mode';

  Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_userKey);
    if (data == null) return null;
    return UserModel.fromJson(jsonDecode(data));
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  Future<bool> isLoggedIn() async {
    final user = await getUser();
    return user != null;
  }

  Future<void> setThemeMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}
