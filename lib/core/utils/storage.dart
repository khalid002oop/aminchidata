import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const _tokenKey   = 'auth_token';
  static const _userKey    = 'user_data';
  static const _scopeKey   = 'token_scope';

  static Future<void> saveToken(String token, {String scope = 'full'}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_scopeKey, scope);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<String?> getScope() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_scopeKey);
  }

  static Future<void> saveUserData(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json);
  }

  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_scopeKey);
  }
}
