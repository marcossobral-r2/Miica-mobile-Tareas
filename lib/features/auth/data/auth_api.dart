// © r2 software. All rights reserved.
// File: lib/features/auth/data/auth_api.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Low-level HTTP calls for authentication endpoints.
// Author: AI-generated with r2 software guidelines

import 'package:dio/dio.dart';

import 'auth_constants.dart';

/// Performs raw HTTP calls to Omnia auth endpoints.
/// This layer knows endpoints and payloads; it does not manage tokens directly.
class AuthApi {
  AuthApi({
    required Dio unauthenticatedDio,
    required Dio authenticatedDio,
  })  : _unauthenticatedDio = unauthenticatedDio,
        _authenticatedDio = authenticatedDio;

  final Dio _unauthenticatedDio;
  final Dio _authenticatedDio;

  /// Inputs: [username] must not be null/empty, [secret] must not be null/empty.
  /// Performs POST login request using Omnia credential keys.
  /// Outputs: raw response map; throws [DioException] on HTTP failures.
  /// Side effects: network request only.
  Future<Map<String, dynamic>> login({
    required String username,
    required String secret,
  }) async {
    final response = await _unauthenticatedDio.post<Map<String, dynamic>>(
      AuthEndpoints.login,
      data: {
        kAuthUserKey: username,
        kAuthSecretKey: secret,
      },
    );
    return response.data ?? <String, dynamic>{};
  }

  /// Inputs: none.
  /// Performs authenticated GET to retrieve user info when available.
  /// Outputs: raw map (possibly empty); throws [DioException] if unauthorized.
  /// Side effects: network I/O only.
  Future<Map<String, dynamic>> me() async {
    final response = await _authenticatedDio.get<Map<String, dynamic>>(AuthEndpoints.me);
    return response.data ?? <String, dynamic>{};
  }
}
