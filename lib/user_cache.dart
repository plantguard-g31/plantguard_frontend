import 'package:shared_preferences/shared_preferences.dart';

class UserCache {
  static Future<void> saveUser({
    required String name,
    required String photoUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('user_name', name);
    await prefs.setString('profile_photo_url', photoUrl);
  }

  static Future<Map<String, String>> getUser() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'name': prefs.getString('user_name') ?? '',
      'photo_url': prefs.getString('profile_photo_url') ?? '',
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('user_name');
    await prefs.remove('profile_photo_url');
  }
}