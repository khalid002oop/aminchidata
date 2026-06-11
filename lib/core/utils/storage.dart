import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static const _tokenKey     = 'auth_token';
  static const _userKey      = 'user_data';
  static const _scopeKey     = 'token_scope';
  static const _emailKey     = 'user_email';
  static const _bioKey       = 'biometric_enabled';
  static const _securePinKey = 'secure_txn_pin';

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ── Token ────────────────────────────────────────────────
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

  // ── User data ─────────────────────────────────────────────
  static Future<void> saveUserData(String json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json);
  }

  static Future<String?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userKey);
  }

  // ── Email (for reauth + biometric) ───────────────────────
  static Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
  }

  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  // ── Biometric flag ────────────────────────────────────────
  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_bioKey, enabled);
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_bioKey) ?? false;
  }

  // ── Secure PIN (for biometric-based transaction auth) ─────
  static Future<void> saveSecurePin(String pin) async {
    await _secure.write(key: _securePinKey, value: pin);
  }

  static Future<String?> getSecurePin() async {
    try {
      return await _secure.read(key: _securePinKey);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearSecurePin() async {
    await _secure.delete(key: _securePinKey);
  }

  // ── Full clear ────────────────────────────────────────────
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_scopeKey);
    // Keep email + biometric pref so next login can offer fingerprint again
  }
}
