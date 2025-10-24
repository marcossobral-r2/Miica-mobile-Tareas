// © r2 software. All rights reserved.
// File: lib/core/network/auth_interceptor.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Adds Bearer token and handles 401 via refresh (if available).
// Author: AI-generated with r2 software guidelines

import 'package:dio/dio.dart';

import '../security/token_store.dart';
import '../../features/auth/data/auth_constants.dart';

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
    if (access != null && access.isNotEmpty && _shouldAttachToken(options.path)) {
      options.headers['Authorization'] = 'Bearer $access';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && _shouldAttemptRefresh(err.requestOptions.path)) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retried = await _retryWithNewAccess(err.requestOptions);
        if (retried != null) {
          return handler.resolve(retried);
        }
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
        AuthEndpoints.refresh,
        data: {kAuthRefreshKey: refresh},
      );
      final data = response.data as Map<String, dynamic>? ?? <String, dynamic>{};
      final access = data[kAccessTokenKey] as String?;
      final newRefresh = data[kRefreshTokenKey] as String?;
      if (access != null && access.isNotEmpty) {
        await tokenStore.saveTokens(access, refresh: newRefresh ?? refresh);
        return true;
      }
    } catch (_) {
      // No refresh available or failed. Caller should handle logout.
    }
    await tokenStore.clear();
    return false;
  }

  bool _shouldAttachToken(String path) {
    return path != AuthEndpoints.login && path != AuthEndpoints.refresh;
  }

  bool _shouldAttemptRefresh(String path) => _shouldAttachToken(path);

  Future<Response<dynamic>?> _retryWithNewAccess(RequestOptions options) async {
    final access = await tokenStore.readAccess();
    if (access == null || access.isEmpty) {
      return null;
    }

    final newOptions = options.copyWith(
      headers: Map<String, dynamic>.from(options.headers)
        ..['Authorization'] = 'Bearer $access',
    );

    try {
      return await unauthenticatedDio.fetch<dynamic>(newOptions);
    } catch (_) {
      await tokenStore.clear();
      return null;
    }
  }
}
