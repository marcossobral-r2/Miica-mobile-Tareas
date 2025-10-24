// © r2 software. All rights reserved.
// File: lib/features/auth/data/auth_constants.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Canonical keys and endpoints for authentication payloads.
// Author: AI-generated with r2 software guidelines

/// Request keys (confirmed against Swagger spec /docs).
/// Responsibilities: ensure payload fields are changeable in one place.
/// Limits: does not include validation or networking logic.
const String kAuthUserKey = 'email';
const String kAuthSecretKey = 'password';
const String kAuthRefreshKey = 'refresh_token';

/// Response keys (confirmed against Swagger spec /docs).
/// Responsibilities: provide consistent map lookups for tokens.
/// Limits: does not model full response objects.
const String kAccessTokenKey = 'access_token';
const String kRefreshTokenKey = 'refresh_token';
const String kTokenTypeKey = 'token_type';

/// Fixed endpoints for authentication requests.
/// Responsibilities: single source for auth-related paths.
/// Limits: does not handle query params or versions.
abstract class AuthEndpoints {
  const AuthEndpoints._();

  static const String login = '/api/v1/auth/login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String me = '/api/v1/me';
}
