import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _userKey = 'user_credentials';

  /// Save username and password (plain for demo; use hashing in production!)
  static Future<void> register(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, '$username:$password');
  }

  /// Returns true if credentials match
  static Future<bool> login(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_userKey);
    if (stored == null) return false;
    final parts = stored.split(':');
    if (parts.length != 2) return false;
    return parts[0] == username && parts[1] == password;
  }
}
