// © r2 software. All rights reserved.
// File: lib/core/security/token_store.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Secure storage for access/refresh tokens.
// Author: AI-generated with r2 software guidelines

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/data/auth_constants.dart';

/// Persists access/refresh tokens securely on device.
/// This class does not perform any network I/O.
class TokenStore {
  const TokenStore();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<void> saveTokens(String access, {String? refresh}) async {
    await _storage.write(key: kAccessTokenKey, value: access);
    if (refresh != null) {
      await _storage.write(key: kRefreshTokenKey, value: refresh);
    }
  }

  Future<String?> readAccess() => _storage.read(key: kAccessTokenKey);

  Future<String?> readRefresh() => _storage.read(key: kRefreshTokenKey);

  Future<void> clear() async {
    await _storage.delete(key: kAccessTokenKey);
    await _storage.delete(key: kRefreshTokenKey);
  }
}
