// © r2 software. All rights reserved.
// File: lib/core/di/providers.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: App-wide providers for DI (Dio, TokenStore, AuthRepository).
// Author: AI-generated with r2 software guidelines

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../network/auth_interceptor.dart';
import '../network/dio_client.dart';
import '../security/token_store.dart';
import '../../features/auth/data/auth_api.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/auth_repository.dart';

/// Provides a single instance of [TokenStore].
final tokenStoreProvider = Provider<TokenStore>((ref) => const TokenStore());

/// Unauthenticated Dio (no bearer), used for login/refresh and as retry client.
final dioBaseProvider = Provider<Dio>((ref) {
  return DioClient.create();
});

/// Authenticated Dio with interceptor (Bearer + refresh).
final dioAuthProvider = Provider<Dio>((ref) {
  final base = DioClient.create();
  final store = ref.read(tokenStoreProvider);
  final unauthenticated = ref.read(dioBaseProvider);
  final authInterceptor = AuthInterceptor(
    tokenStore: store,
    unauthenticatedDio: unauthenticated,
  );
  base.interceptors.add(authInterceptor);
  return base;
});

/// Low-level authentication API.
final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.read(dioBaseProvider);
  return AuthApi(dio);
});

/// Repository that coordinates authentication operations.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    api: ref.read(authApiProvider),
    tokenStore: ref.read(tokenStoreProvider),
  );
});
