import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppPreferences {
  static const _accessTokenKey = 'accessToken';
  static const _refreshTokenKey = 'refreshToken';
  static const _isDiscoverModeKey = 'isDiscoverMode'; // ✅ المفتاح الجديد
  static const _userIdKey = 'userId'; // ✅ لتخزين معرف المستخدم

  // إنشاء instance من FlutterSecureStorage
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  /// حفظ Access Token
  static Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessTokenKey, value: token);
  }

  /// حفظ Refresh Token
  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _refreshTokenKey, value: token);
  }

  /// استرجاع Access Token
  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _accessTokenKey);
  }

  /// استرجاع Refresh Token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _refreshTokenKey);
  }

  /// حذف Access Token
  static Future<void> clearAccessToken() async {
    await _secureStorage.delete(key: _accessTokenKey);
  }

  /// حذف Refresh Token
  static Future<void> clearRefreshToken() async {
    await _secureStorage.delete(key: _refreshTokenKey);
  }

  /// حذف كل البيانات (اختياري)
  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }


  static Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      saveAccessToken(accessToken),
      saveRefreshToken(refreshToken),
    ]);
  }

  // ✅ خاص بـ وضع الاستكشاف (Discover Mode)

  /// حفظ حالة وضع الاستكشاف
  static Future<void> saveDiscoverMode(bool isEnabled) async {
    await _secureStorage.write(
      key: _isDiscoverModeKey,
      value: isEnabled.toString(), // "true" أو "false"
    );
  }

  /// استرجاع حالة وضع الاستكشاف
  static Future<bool> getDiscoverMode() async {
    final value = await _secureStorage.read(key: _isDiscoverModeKey);
    return value == 'true'; // تحويل النص إلى bool
  }

  /// حذف وضع الاستكشاف (اختياري)
  static Future<void> clearDiscoverMode() async {
    await _secureStorage.delete(key: _isDiscoverModeKey);
  }

  // ✅ خاص بـ معرف المستخدم (User ID)

  /// حفظ معرف المستخدم
  static Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _userIdKey, value: userId);
  }

  /// استرجاع معرف المستخدم
  static Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  /// حذف معرف المستخدم
  static Future<void> clearUserId() async {
    await _secureStorage.delete(key: _userIdKey);
  }
}
