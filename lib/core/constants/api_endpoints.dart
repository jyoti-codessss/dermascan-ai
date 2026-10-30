// Flutter API endpoint constants for DermaScan AI Backend
// Adjust BASE_URL for your environment:
//   - Android emulator: http://10.0.2.2:5001
//   - Physical device on same Wi-Fi: http://<YOUR_MACHINE_IP>:5001
//   - Production: https://api.dermascan.ai

class ApiEndpoints {
  ApiEndpoints._();

  // ─── Base URL ──────────────────────────────────────────────────────────────
  /// Change this to your machine's local IP when testing on a physical device.
  /// Example: 'http://192.168.1.10:5001'
  static const String baseUrl =
      String.fromEnvironment('API_BASE_URL', defaultValue: 'https://dermascan-ai-plfk.onrender.com');

  static const String apiV1 = '$baseUrl/api/v1';

  // ─── Auth Endpoints ────────────────────────────────────────────────────────
  static const String authRegister = '$apiV1/auth/register';
  static const String authLogin = '$apiV1/auth/login';
  static const String authGoogle = '$apiV1/auth/google';
  static const String authRefresh = '$apiV1/auth/refresh';
  static const String authLogout = '$apiV1/auth/logout';
  static const String authMe = '$apiV1/auth/me';
  static const String authForgotPassword = '$apiV1/auth/forgot-password';
  static const String authResetPassword = '$apiV1/auth/reset-password';

  // ─── Analysis Endpoints (Phase 2) ─────────────────────────────────────────
  static const String analyses = '$apiV1/analyses';
  static String analysisDetail(String id) => '$apiV1/analyses/$id';

  // ─── Nearby Care Endpoints (Phase 3 & PostGIS) ───────────────────────────
  static const String nearbyDoctors = '$apiV1/nearby/doctors';
  static const String nearbyDoctorAiMatch = '$apiV1/nearby/doctors/ai-match';
  static const String nearbyDermatologists = '$apiV1/nearby/dermatologists';
  static const String nearbyHospitals = '$apiV1/nearby/hospitals';
  static String nearbyPlaceDetail(String placeId) => '$apiV1/nearby/places/$placeId';

  // ─── AI Assistant Chat Endpoints ──────────────────────────────────────────
  static const String chat = '$apiV1/chat';

  // ─── Health Check ─────────────────────────────────────────────────────────
  static const String health = '$baseUrl/health';
}

