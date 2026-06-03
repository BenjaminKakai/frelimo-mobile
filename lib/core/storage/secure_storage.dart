import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../config/env.dart';

/// Wraps `flutter_secure_storage` so the rest of the app never sees raw keys.
///
/// We deliberately avoid `localStorage` / shared_preferences for tokens —
/// the keystore on Android (and Keychain on iOS) is the only place a JWT
/// should live on a device.
class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: Env.accessTokenKey, value: token);
  Future<String?> getAccessToken() =>
      _storage.read(key: Env.accessTokenKey);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: Env.refreshTokenKey, value: token);
  Future<String?> getRefreshToken() =>
      _storage.read(key: Env.refreshTokenKey);

  Future<void> saveUser(Map<String, dynamic> user) =>
      _storage.write(key: Env.userKey, value: jsonEncode(user));
  Future<Map<String, dynamic>?> getUser() async {
    final s = await _storage.read(key: Env.userKey);
    if (s != null) return jsonDecode(s) as Map<String, dynamic>;
    return null;
  }

  /// Cache `/profile/me` so the digital card can render fully offline.
  /// The QR code is generated locally from the cached member number, so
  /// branch staff can still verify even without network.
  Future<void> saveProfileCache(Map<String, dynamic> profile) =>
      _storage.write(key: Env.profileKey, value: jsonEncode(profile));
  Future<Map<String, dynamic>?> getProfileCache() async {
    final s = await _storage.read(key: Env.profileKey);
    if (s != null) return jsonDecode(s) as Map<String, dynamic>;
    return null;
  }

  Future<void> saveLocale(String code) =>
      _storage.write(key: Env.localeKey, value: code);
  Future<String?> getLocale() => _storage.read(key: Env.localeKey);

  Future<void> saveTheme(String theme) =>
      _storage.write(key: Env.themeKey, value: theme);
  Future<String?> getTheme() => _storage.read(key: Env.themeKey);

  Future<void> clearAll() => _storage.deleteAll();
  Future<bool> hasToken() async {
    final t = await getAccessToken();
    return t != null && t.isNotEmpty;
  }
}
