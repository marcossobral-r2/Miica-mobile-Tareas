// © r2 software. All rights reserved.
// File: lib/core/security/token_store.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Secure storage for access/refresh tokens.
// Author: AI-generated with r2 software guidelines

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists access/refresh tokens securely on device.
/// This class does not perform any network I/O.
class TokenStore {
  const TokenStore();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static const String _kAccess = 'access_token';
  static const String _kRefresh = 'refresh_token';

  Future<void> saveTokens(String access, {String? refresh}) async {
    await _storage.write(key: _kAccess, value: access);
    if (refresh != null) {
      await _storage.write(key: _kRefresh, value: refresh);
    }
  }

  Future<String?> readAccess() => _storage.read(key: _kAccess);

  Future<String?> readRefresh() => _storage.read(key: _kRefresh);

  Future<void> clear() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
  }
}
