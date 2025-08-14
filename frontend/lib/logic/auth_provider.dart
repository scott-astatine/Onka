import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../core/config.dart';

/// Provider for the authentication service.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// Represents the authentication state of the user.
class AuthState {
  final String? token;
  final bool isLoading;
  final String? error;

  AuthState({this.token, this.isLoading = false, this.error});

  bool get isAuthenticated => token != null;
}

/// Manages authentication logic, including login and reporting.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  /// Fetches a JWT from the backend for the given client ID.
  Future<void> login(String clientId) async {
    state = AuthState(isLoading: true);
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/token?client_id=$clientId');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        state = AuthState(token: data['access_token']);
      } else {
        state = AuthState(error: 'Failed to authenticate: ${response.body}');
      }
    } catch (e) {
      state = AuthState(error: 'Failed to connect to server: $e');
    }
  }

  /// Reports a user, using the stored JWT for authentication.
  Future<void> reportUser(String reportedId) async {
    if (state.token == null) return;

    try {
      final url = Uri.parse('${AppConfig.baseUrl}/api/report');
      await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${state.token}',
        },
        body: jsonEncode({'reported_id': reportedId}),
      );
    } catch (e) {
      debugPrint('Failed to report user: $e');
    }
  }
}
