// lib/services/auth_service.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Handles all authentication — login, register,
// logout, and storing JWT tokens securely.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';

class AuthService {
  // Secure storage for JWT tokens
  // Encrypted on device — much safer than SharedPreferences
  static const _storage = FlutterSecureStorage();

  // Storage keys
  static const _accessTokenKey  = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _usernameKey     = 'username';

  // ── REGISTER ─────────────────────────────────────
  static Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String phoneNumber,
    required String location,
    required String password,
    required String password2,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username':     username,
          'email':        email,
          'phone_number': phoneNumber,
          'location':     location,
          'password':     password,
          'password2':    password2,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // Save tokens securely on device
        await _saveTokens(
          accessToken:  data['tokens']['access'],
          refreshToken: data['tokens']['refresh'],
          username:     data['user']['username'],
        );
        return {'success': true, 'data': data};
      }

      return {'success': false, 'error': data};
    } catch (e) {
      return {'success': false, 'error': 'Connection failed. Check internet.'};
    }
  }

  // ── LOGIN ─────────────────────────────────────────
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _saveTokens(
          accessToken:  data['tokens']['access'],
          refreshToken: data['tokens']['refresh'],
          username:     data['user']['username'],
        );
        return {'success': true, 'data': data};
      }

      return {'success': false, 'error': data['error'] ?? 'Login failed'};
    } catch (e) {
      return {'success': false, 'error': 'Connection failed. Check internet.'};
    }
  }

  // ── LOGOUT ────────────────────────────────────────
  static Future<void> logout() async {
    try {
      final refreshToken = await getRefreshToken();
      final accessToken  = await getAccessToken();

      if (refreshToken != null && accessToken != null) {
        await http.post(
          Uri.parse(ApiConfig.logout),
          headers: {
            'Content-Type':  'application/json',
            'Authorization': 'Bearer $accessToken',
          },
          body: jsonEncode({'refresh': refreshToken}),
        );
      }
    } catch (e) {
      // Even if API call fails, clear local tokens
    } finally {
      await _clearTokens();
    }
  }

  // ── TOKEN HELPERS ─────────────────────────────────
  static Future<void> _saveTokens({
    required String accessToken,
    required String refreshToken,
    required String username,
  }) async {
    await _storage.write(key: _accessTokenKey,  value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _usernameKey,     value: username);
  }

  static Future<void> _clearTokens() async {
    await _storage.deleteAll();
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }

  // Returns auth header for protected API calls
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type':  'application/json',
    };
  }
}