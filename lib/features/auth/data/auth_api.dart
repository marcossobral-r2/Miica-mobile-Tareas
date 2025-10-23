// © r2 software. All rights reserved.
// File: lib/features/auth/data/auth_api.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Low-level HTTP calls for authentication endpoints.
// Author: AI-generated with r2 software guidelines

import 'package:dio/dio.dart';

/// Performs raw HTTP calls to Omnia auth endpoints.
/// This layer knows endpoints and payloads; it does not manage tokens directly.
class AuthApi {
  AuthApi(this.dio);

  final Dio dio;

  /// Attempts login with username + pin.
  /// Returns raw map with tokens and user info.
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await dio.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return response.data ?? <String, dynamic>{};
  }

  /// Optionally verify current identity (sanity check).
  Future<Map<String, dynamic>> me() async {
    final response = await dio.get<Map<String, dynamic>>('/api/v1/me');
    return response.data ?? <String, dynamic>{};
  }
}
