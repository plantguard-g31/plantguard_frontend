import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'user_cache.dart';
import 'models/history_item_model.dart';
import 'treatment_library_item_model.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.77:8000/api/v1';

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
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    throw Exception(_readBackendError(res.body));
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
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      await _storage.write(
        key: 'access_token',
        value: data['access_token'],
      );

      if (data['refresh_token'] != null) {
        await _storage.write(
          key: 'refresh_token',
          value: data['refresh_token'],
        );
      }

      print('JWT token saved successfully');
      return;
    }

    throw Exception(_readBackendError(res.body));
  }

  // ------- GET ACCESS TOKEN -------
  static Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }

  // ------- GET REFRESH TOKEN -------
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  // ------- GET CURRENT USER PROFILE -------
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Session expired. Please login again.');
    }

    final res = await http.get(
      Uri.parse('$baseUrl/user/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('PROFILE STATUS: ${res.statusCode}');
    print('PROFILE RESPONSE: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      await UserCache.saveUser(
        name: data['name'] ?? '',
        photoUrl: data['profile_picture_url'] ?? '',
      );

      return data;
    }

    throw Exception(_readBackendError(res.body));
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

    if (token == null || token.isEmpty) {
      throw Exception('Session expired. Please login again.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/user/profile-photo'),
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

    print('UPLOAD STATUS: ${response.statusCode}');
    print('UPLOAD RESPONSE: $responseBody');

    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody) as Map<String, dynamic>;
      return data['profile_picture_url'];
    }

    throw Exception(_readBackendError(responseBody));
  }

  // ------- DIAGNOSE PLANT IMAGE -------
  static Future<Map<String, dynamic>> diagnosePlantImage({
    required String imagePath,
    String cropType = 'tomato',
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Session expired. Please login again.');
    }

    final uri = Uri.parse('$baseUrl/diagnose/').replace(
      queryParameters: {
        'crop_type': cropType,
        'lang': 'en',
      },
    );

    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imagePath,
      ),
    );

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    print('DIAGNOSE STATUS: ${response.statusCode}');
    print('DIAGNOSE RESPONSE: $responseBody');

    if (response.statusCode == 200) {
      return jsonDecode(responseBody) as Map<String, dynamic>;
    }

    throw Exception(_readBackendError(responseBody));
  }

  // ------- GET HISTORY LIST -------
  static Future<List<HistoryItemModel>> getHistoryList({
    int limit = 10,
    int offset = 0,
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Session expired. Please login again.');
    }

    final uri = Uri.parse('$baseUrl/history/').replace(
      queryParameters: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('HISTORY STATUS: ${res.statusCode}');
    print('HISTORY RESPONSE: ${res.body}');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final items = data['items'];

      if (items is List) {
        return items
            .map(
              (item) => HistoryItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      return [];
    }

    throw Exception(_readBackendError(res.body));
  }

  // ------- GET HISTORY DETAIL -------
  static Future<Map<String, dynamic>> getHistoryDetail(String historyId) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Session expired. Please login again.');
    }

    final res = await http.get(
      Uri.parse('$baseUrl/history/$historyId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('HISTORY DETAIL STATUS: ${res.statusCode}');
    print('HISTORY DETAIL RESPONSE: ${res.body}');

    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    throw Exception(_readBackendError(res.body));
  }

  // ------- GET TREATMENT LIBRARY -------
  static Future<List<TreatmentLibraryItemModel>> getTreatmentLibrary({
    String? cropType,
    String search = '',
    String lang = 'en',
  }) async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Session expired. Please login again.');
    }

    final queryParams = <String, String>{
      'lang': lang,
    };

    if (cropType != null && cropType.isNotEmpty) {
      queryParams['crop_type'] = cropType;
    }

    if (search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final uri = Uri.parse('$baseUrl/treatments/library').replace(
      queryParameters: queryParams,
    );

    final res = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print('TREATMENT LIBRARY STATUS: ${res.statusCode}');
    print('TREATMENT LIBRARY RESPONSE: ${res.body}');

    if (res.statusCode == 200) {
      final decoded = jsonDecode(res.body);

      if (decoded is List) {
        return decoded
            .map(
              (item) => TreatmentLibraryItemModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }

      if (decoded is Map<String, dynamic>) {
        final items = decoded['items'] ??
            decoded['data'] ??
            decoded['treatments'] ??
            decoded['results'];

        if (items is List) {
          return items
              .map(
                (item) => TreatmentLibraryItemModel.fromJson(
                  Map<String, dynamic>.from(item),
                ),
              )
              .toList();
        }
      }

      return [];
    }

    throw Exception(_readBackendError(res.body));
  }

  // ------- READ ERROR DIRECTLY FROM BACKEND -------
  static String _readBackendError(String responseBody) {
    try {
      final data = jsonDecode(responseBody);

      if (data is Map<String, dynamic>) {
        final detail = data['detail'];

        if (detail is Map<String, dynamic>) {
          if (detail['message_en'] != null) {
            return detail['message_en'].toString();
          }

          if (detail['message'] != null) {
            return detail['message'].toString();
          }

          if (detail['error_code'] != null) {
            return detail['error_code'].toString();
          }
        }

        if (data['message_en'] != null) {
          return data['message_en'].toString();
        }

        if (data['message'] != null) {
          return data['message'].toString();
        }

        if (data['detail'] != null) {
          return data['detail'].toString();
        }

        if (data['error'] != null) {
          return data['error'].toString();
        }

        if (data['error_code'] != null) {
          return data['error_code'].toString();
        }
      }

      return 'Something went wrong. Please try again.';
    } catch (_) {
      return 'Something went wrong. Please try again.';
    }
  }

  // ------- LOGOUT LOCAL -------
  static Future<void> logout() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await UserCache.clear();
  }
}