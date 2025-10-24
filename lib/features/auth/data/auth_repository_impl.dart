// © r2 software. All rights reserved.
// File: lib/features/auth/data/auth_repository_impl.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: AuthRepository implementation (JWT).
// Author: AI-generated with r2 software guidelines

import '../../../core/security/token_store.dart';
import '../domain/auth_repository.dart';
import 'auth_api.dart';
import 'auth_constants.dart';

/// Implements login using Omnia JWT endpoints.
/// Side effects: persists tokens on successful login.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.api,
    required this.tokenStore,
  });

  final AuthApi api;
  final TokenStore tokenStore;

  @override
  Future<bool> login({required String username, required String secret}) async {
    final data = await api.login(username: username, secret: secret);
    final access = data[kAccessTokenKey] as String?;
    final refresh = data[kRefreshTokenKey] as String?;
    if (access == null || access.isEmpty) {
      return false;
    }
    await tokenStore.saveTokens(access, refresh: refresh);
    return true;
  }

  @override
  Future<void> logout() => tokenStore.clear();

  @override
  Future<bool> isLoggedIn() async {
    final access = await tokenStore.readAccess();
    return access != null && access.isNotEmpty;
  }
}
