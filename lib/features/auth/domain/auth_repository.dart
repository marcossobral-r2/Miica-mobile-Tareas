// © r2 software. All rights reserved.
// File: lib/features/auth/domain/auth_repository.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Abstraction for authentication operations.
// Author: AI-generated with r2 software guidelines

/// Abstraction for auth; hides HTTP details from the app.
abstract class AuthRepository {
  /// Inputs: [username] and [secret] non-empty.
  /// Attempts login, persists tokens on success.
  /// Outputs: true when tokens saved, false otherwise.
  /// Side effects: secure storage writes.
  Future<bool> login({required String username, required String secret});

  /// Clears local tokens and session.
  Future<void> logout();

  /// Returns true if an access token is available.
  Future<bool> isLoggedIn();
}
