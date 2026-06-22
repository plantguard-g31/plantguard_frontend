import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  static const String baseUrl = 'https://jeshik.dpdns.org/api/v1';

  // Secure storage for JWT token
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

      // Save JWT access token securely
      await _storage.write(
        key: 'access_token',
        value: data['access_token'],
      );

      // Optional test print
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
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getToken();

    final res = await http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    } else {
      throw Exception('Failed to load user profile');
    }
  }

  // ------- AUTH HEADERS -------
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

  if (response.statusCode == 200) {
    final data = jsonDecode(responseBody);
    return data['profile_photo_url'];
  } else {
    throw Exception('Failed to upload profile photo');
  }
}

// ------- LOGOUT -------
static Future<void> logout() async {
  await _storage.delete(key: 'access_token');
}
}