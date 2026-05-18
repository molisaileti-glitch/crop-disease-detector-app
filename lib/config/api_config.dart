// lib/config/api_config.dart
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// All API configuration in one place.
// Change the base URL here and it updates everywhere.
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ApiConfig {
  // Base URL of our Django API on Render
  // Change this to your actual Render URL
  static const String baseUrl =
      'https://crop-disease-detector-api-jlmu.onrender.com/api/v1';

  // Auth endpoints
  static const String register = '$baseUrl/auth/register/';
  static const String login    = '$baseUrl/auth/login/';
  static const String logout   = '$baseUrl/auth/logout/';
  static const String refresh  = '$baseUrl/auth/token/refresh/';

  // User endpoints
  static const String profile  = '$baseUrl/user/profile/';

  // Diagnosis endpoints
  static const String diagnose        = '$baseUrl/diagnose/';
  static const String diagnosisHistory= '$baseUrl/diagnose/history/';

  // Diagnosis detail — append ID
  static String diagnosisDetail(int id) => '$baseUrl/diagnose/$id/';
  static String diagnosisFeedback(int id) => '$baseUrl/diagnose/$id/feedback/';
}