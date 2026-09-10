import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static const _accessTokenKey = 'access_token';
  static const _userId = 'user_id';
  static const _userName = 'user_name';
  static const _userRole = 'role_name';
  static const _isTokenExternal = 'is_token_external';

  /*static Future<void> saveToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }*/

  static Future<void> saveToken({
    required String accessToken,
    required bool isTokenExternal
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setBool(_isTokenExternal, isTokenExternal);
  }

  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  static Future<String?> getUserID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userId);
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userId, userId);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userName);
  }

  static Future<void> saveUserName(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userName, userId);
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRole);
  }

  static Future<void> saveUserRole(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userRole, userId);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
