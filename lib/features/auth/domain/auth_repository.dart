// © r2 software. All rights reserved.
// File: lib/features/auth/domain/auth_repository.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Abstraction for authentication operations.
// Author: AI-generated with r2 software guidelines

/// Abstraction for auth; hides HTTP details from the app.
abstract class AuthRepository {
  /// Logs in with username+pin and persists tokens.
  Future<bool> login({required String username, required String pin});

  /// Clears local tokens and session.
  Future<void> logout();

  /// Returns true if an access token is available.
  Future<bool> isLoggedIn();
}
