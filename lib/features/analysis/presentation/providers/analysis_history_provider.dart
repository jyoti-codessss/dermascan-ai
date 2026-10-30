import 'dart:convert';
import 'package:dermascan_ai/features/analysis/data/services/analysis_api_service.dart';
import 'package:dermascan_ai/features/analysis/domain/analysis_record.dart';
import 'package:dermascan_ai/features/auth/domain/auth_state.dart';
import 'package:dermascan_ai/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Riverpod provider for real, user-scoped persisted analysis history.
final analysisHistoryProvider =
    StateNotifierProvider<AnalysisHistoryNotifier, List<AnalysisRecord>>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return AnalysisHistoryNotifier(ref, authState);
});

class AnalysisHistoryNotifier extends StateNotifier<List<AnalysisRecord>> {
  final Ref _ref;
  final AuthState _authState;
  String? _currentUserId;

  AnalysisHistoryNotifier(this._ref, this._authState) : super(const []) {
    if (_authState is Authenticated) {
      _currentUserId = _authState.user.id;
      _loadForUser(_authState.user.id);
    } else {
      state = const [];
    }
  }

  String _userKey(String userId) => 'analysis_history_$userId';

  Future<void> _loadForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_userKey(userId));
    if (raw != null) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        state = list
            .map((e) => AnalysisRecord.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (_) {
        state = const [];
      }
    }

    // Also fetch latest real history from backend API in background
    try {
      final token = await _ref.read(authNotifierProvider.notifier).getAccessToken();
      final remote = await AnalysisApiService.fetchUserAnalyses(token);
      if (remote.isNotEmpty) {
        state = remote;
        await _persistForUser(userId);
      }
    } catch (_) {}
  }

  Future<void> addRecord(AnalysisRecord record) async {
    state = [record, ...state];
    if (_currentUserId != null) {
      await _persistForUser(_currentUserId!);
    }
  }

  Future<void> clear() async {
    state = const [];
    if (_currentUserId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey(_currentUserId!));
    }
  }

  Future<void> _persistForUser(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(state.map((r) => r.toJson()).toList());
    await prefs.setString(_userKey(userId), encoded);
  }
}
