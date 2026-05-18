// lib/services/diagnosis_service.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Handles image upload and diagnosis history.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class DiagnosisService {

  // ── DIAGNOSE IMAGE ────────────────────────────────
  static Future<Map<String, dynamic>> diagnoseImage(File imageFile) async {
    try {
      final token = await AuthService.getAccessToken();

      // Use multipart request to send image file
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.diagnose),
      );

      // Add auth header
      request.headers['Authorization'] = 'Bearer $token';

      // Add image file to request
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',       // field name — must match Django serializer
          imageFile.path,
        ),
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'data': data};
      }

      return {
        'success': false,
        'error': data['error'] ?? 'Diagnosis failed. Try again.'
      };
    } catch (e) {
      return {'success': false, 'error': 'Connection failed. Check internet.'};
    }
  }

  // ── GET DIAGNOSIS HISTORY ─────────────────────────
  static Future<Map<String, dynamic>> getHistory() async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.get(
        Uri.parse(ApiConfig.diagnosisHistory),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return {'success': true, 'data': data};
      }

      return {'success': false, 'error': 'Failed to load history.'};
    } catch (e) {
      return {'success': false, 'error': 'Connection failed.'};
    }
  }

  // ── DELETE DIAGNOSIS ──────────────────────────────
  static Future<bool> deleteDiagnosis(int diagnosisId) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.delete(
        Uri.parse(ApiConfig.diagnosisDetail(diagnosisId)),
        headers: headers,
      );

      return response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // ── SUBMIT FEEDBACK ───────────────────────────────
  static Future<bool> submitFeedback({
    required int diagnosisId,
    required bool wasAccurate,
    String comment = '',
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http.post(
        Uri.parse(ApiConfig.diagnosisFeedback(diagnosisId)),
        headers: headers,
        body: jsonEncode({
          'was_accurate': wasAccurate,
          'comment':      comment,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}