import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'user_cache.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.99:8000/api/v1';

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  // ------- REGISTER -------
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'confirm_password': confirmPassword,
      }),
    );

    if (res.statusCode == 201) {
      return jsonDecode(res.body);
    } else {
      final body = jsonDecode(res.body);
      throw Exception(body['detail'] ?? 'Registration failed');
    }
  }

  // ------- LOGIN -------
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);

      await _storage.write(
        key: 'access_token',
        value: data['access_token'],
      );

      print('JWT token saved successfully');
    } else {
      final body = jsonDecode(res.body);
      throw Exception(body['detail'] ?? 'Login failed');
    }
  }

  // ------- GET TOKEN -------
  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // ------- GET CURRENT USER PROFILE -------
// ------- GET CURRENT USER PROFILE -------
static Future<Map<String, dynamic>> getCurrentUser() async {
  final token = await getToken();

  print("TOKEN: $token");

  final res = await http.get(
    Uri.parse('$baseUrl/user/me'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  print("PROFILE STATUS: ${res.statusCode}");
  print("PROFILE RESPONSE: ${res.body}");

  if (res.statusCode == 200) {
    final data = jsonDecode(res.body);

    print("USER DATA: $data");

    await UserCache.saveUser(
      name: data['name'] ?? '',
      photoUrl: data['profile_picture_url'] ?? '',
    );

    return data;
  } else {
    throw Exception('Failed to load user profile');
  }
}

  // ------- AUTH HEADERS -------
  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();

    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ------- UPLOAD PROFILE PHOTO -------
  static Future<String?> uploadProfilePhoto(String imagePath) async {
    final token = await getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/user/upload-photo'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imagePath,
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
print("UPLOAD STATUS: ${response.statusCode}");
print("UPLOAD RESPONSE: $responseBody");
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['profile_picture_url'];
    } else {
      throw Exception('Failed to upload profile photo');
    }
  }

  // ------- LOGOUT -------
  static Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await UserCache.clear();
  }
}