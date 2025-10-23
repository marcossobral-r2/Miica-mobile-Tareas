// © r2 software. All rights reserved.
// File: lib/core/network/auth_interceptor.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Adds Bearer token and handles 401 via refresh (if available).
// Author: AI-generated with r2 software guidelines

import 'package:dio/dio.dart';

import '../security/token_store.dart';

/// Injects Authorization header and tries refresh on 401 (if refresh token exists).
class AuthInterceptor extends Interceptor {
  AuthInterceptor({
    required this.tokenStore,
    required this.unauthenticatedDio,
  });

  final TokenStore tokenStore;
  final Dio unauthenticatedDio;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final access = await tokenStore.readAccess();
    if (access != null && access.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final cloneRequest = await unauthenticatedDio.fetch(err.requestOptions);
        return handler.resolve(cloneRequest);
      }
    }
    super.onError(err, handler);
  }

  Future<bool> _tryRefresh() async {
    final refresh = await tokenStore.readRefresh();
    if (refresh == null || refresh.isEmpty) {
      return false;
    }

    try {
      final response = await unauthenticatedDio.post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refresh},
      );
      final access = response.data['access_token'] as String?;
      final newRefresh = response.data['refresh_token'] as String?;
      if (access != null && access.isNotEmpty) {
        await tokenStore.saveTokens(access, refresh: newRefresh ?? refresh);
        return true;
      }
    } catch (_) {
      // No refresh available or failed. Caller should handle logout.
    }
    return false;
  }
}
