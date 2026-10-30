import 'dart:async';
import 'dart:convert';
import 'package:dermascan_ai/core/constants/api_endpoints.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String _kAccessTokenKey = 'auth_access_token_v1';
const String _kRefreshTokenKey = 'auth_refresh_token_v1';
const String _kUserKey = 'auth_user_v1';

/// Callback invoked when refresh token is completely invalid/expired and user must re-authenticate.
typedef AuthExpiredCallback = void Function();

/// Centralized API Client with automatic JWT token refresh & retry interceptor.
class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  ApiClient._internal();

  AuthExpiredCallback? onAuthExpired;
  Future<String?>? _refreshFuture;

  // ─── Token Accessors ────────────────────────────────────────────────────────

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kAccessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kRefreshTokenKey);
  }

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString(_kAccessTokenKey, accessToken),
      prefs.setString(_kRefreshTokenKey, refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(_kAccessTokenKey),
      prefs.remove(_kRefreshTokenKey),
      prefs.remove(_kUserKey),
    ]);
  }

  // ─── HTTP Methods with Auto-Refresh Interceptor ────────────────────────────

  Future<http.Response> get(
    Uri url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    return _sendWithAutoRefresh((token) {
      final combinedHeaders = _mergeHeaders(headers, token);
      return http.get(url, headers: combinedHeaders).timeout(timeout);
    });
  }

  Future<http.Response> post(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    return _sendWithAutoRefresh((token) {
      final combinedHeaders = _mergeHeaders(headers, token);
      return http.post(url, headers: combinedHeaders, body: body).timeout(timeout);
    });
  }

  Future<http.Response> put(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    return _sendWithAutoRefresh((token) {
      final combinedHeaders = _mergeHeaders(headers, token);
      return http.put(url, headers: combinedHeaders, body: body).timeout(timeout);
    });
  }

  Future<http.Response> delete(
    Uri url, {
    Map<String, String>? headers,
    Object? body,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    return _sendWithAutoRefresh((token) {
      final combinedHeaders = _mergeHeaders(headers, token);
      return http.delete(url, headers: combinedHeaders, body: body).timeout(timeout);
    });
  }

  /// Sends a multipart request with auto-refresh and retry on 401 TOKEN_EXPIRED.
  Future<http.Response> sendMultipart(
    http.MultipartRequest Function(String? token) requestBuilder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final token = await getAccessToken();
    final request = requestBuilder(token);
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    try {
      final streamedResponse = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401 && _isTokenExpiredError(response)) {
        debugPrint('[ApiClient] Multipart received 401 TOKEN_EXPIRED. Attempting refresh & retry...');
        final newToken = await _refreshToken();

        if (newToken != null && newToken.isNotEmpty) {
          final retryRequest = requestBuilder(newToken);
          retryRequest.headers['Authorization'] = 'Bearer $newToken';
          final retryStreamed = await retryRequest.send().timeout(timeout);
          return await http.Response.fromStream(retryStreamed);
        } else {
          _handleAuthExpired();
        }
      }

      return response;
    } catch (e) {
      debugPrint('[ApiClient] Multipart request error: $e');
      rethrow;
    }
  }

  // ─── Private Auto-Refresh Engine ──────────────────────────────────────────

  Future<http.Response> _sendWithAutoRefresh(
    Future<http.Response> Function(String? token) requestExecutor,
  ) async {
    final token = await getAccessToken();
    http.Response response;

    try {
      response = await requestExecutor(token);
    } catch (e) {
      rethrow;
    }

    // Check if response indicates token expiration
    if (response.statusCode == 401 && _isTokenExpiredError(response)) {
      debugPrint('[ApiClient] 401 TOKEN_EXPIRED detected. Initiating token refresh...');
      final newToken = await _refreshToken();

      if (newToken != null && newToken.isNotEmpty) {
        debugPrint('[ApiClient] Token refreshed successfully. Retrying original request...');
        return await requestExecutor(newToken);
      } else {
        debugPrint('[ApiClient] Token refresh failed. Redirecting to login...');
        _handleAuthExpired();
      }
    }

    return response;
  }

  /// Refreshes the access token using the stored refresh token.
  /// Uses a memoized future so concurrent 401 requests share the same refresh call.
  Future<String?> _refreshToken() async {
    if (_refreshFuture != null) {
      return _refreshFuture;
    }

    _refreshFuture = _executeRefreshTokenRequest();
    try {
      final newToken = await _refreshFuture;
      return newToken;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<String?> _executeRefreshTokenRequest() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        debugPrint('[ApiClient] No refresh token found in storage.');
        return null;
      }

      final uri = Uri.parse(ApiEndpoints.authRefresh);
      final res = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'refreshToken': refreshToken}),
          )
          .timeout(const Duration(seconds: 10));

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body) as Map<String, dynamic>;
        final tokens = body['data']?['tokens'] as Map<String, dynamic>?;

        if (tokens != null) {
          final newAccess = tokens['accessToken'] as String;
          final newRefresh = tokens['refreshToken'] as String;

          await saveTokens(accessToken: newAccess, refreshToken: newRefresh);
          debugPrint('[ApiClient] Stored new tokens from /api/v1/auth/refresh');
          return newAccess;
        }
      }

      debugPrint('[ApiClient] Refresh endpoint returned HTTP ${res.statusCode}: ${res.body}');
      return null;
    } catch (e) {
      debugPrint('[ApiClient] Error refreshing token: $e');
      return null;
    }
  }

  bool _isTokenExpiredError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final code = body['error']?['code']?.toString();
      final msg = body['error']?['message']?.toString().toLowerCase() ?? '';
      return code == 'TOKEN_EXPIRED' ||
          code == 'NO_TOKEN' ||
          code == 'INVALID_TOKEN' ||
          msg.contains('expired') ||
          msg.contains('token');
    } catch (_) {
      // Default to true for any 401 on authenticated requests
      return response.statusCode == 401;
    }
  }

  void _handleAuthExpired() {
    clearTokens();
    if (onAuthExpired != null) {
      onAuthExpired!();
    }
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers, String? token) {
    final map = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...?headers,
    };

    if (token != null && token.isNotEmpty && !map.containsKey('Authorization')) {
      map['Authorization'] = 'Bearer $token';
    }

    return map;
  }
}
