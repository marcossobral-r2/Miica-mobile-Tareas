// © r2 software. All rights reserved.
// File: lib/features/auth/presentation/controllers/login_controller.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Riverpod controller handling login submissions.
// Author: AI-generated with r2 software guidelines

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:miica_mobile/core/di/providers.dart';

/// Coordinates login flow state transitions for the UI layer.
/// Responsibilities: trigger AuthRepository login, expose AsyncValue.
/// Limits: no UI widgets, no persistent storage.
class LoginController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData<void>(null);

  /// Inputs: [username], [secret] must be non-empty.
  /// Executes login and updates state to loading/error/success.
  /// Outputs: AsyncValue<void> via state; no direct return.
  /// Side effects: persistence handled by repository, not stored here.
  Future<void> submit({
    required String username,
    required String secret,
  }) async {
    if (state.isLoading) {
      return;
    }

    state = const AsyncValue<void>.loading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final result = await repository.login(username: username, secret: secret);
      if (!result) {
        state = AsyncValue<void>.error(
          'Usuario o clave inválidos',
          StackTrace.current,
        );
        return;
      }
      state = const AsyncValue<void>.data(null);
    } on DioException catch (error) {
      state = AsyncValue<void>.error(
        _mapDioError(error),
        StackTrace.current,
      );
    } catch (_) {
      state = AsyncValue<void>.error(
        'Ocurrió un error inesperado. Intentá nuevamente.',
        StackTrace.current,
      );
    }
  }

  String _mapDioError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    if (statusCode == 400 || statusCode == 401) {
      return 'Usuario o clave inválidos';
    }
    if (statusCode == 408 || (statusCode >= 500 && statusCode < 600)) {
      return 'No pudimos conectar con el servidor. Verificá tu conexión e intentá de nuevo.';
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return 'No pudimos conectar con el servidor. Verificá tu conexión e intentá de nuevo.';
      default:
        return 'Ocurrió un error inesperado. Intentá nuevamente.';
    }
  }
}

/// Provides a controller instance per UI consumer.
final loginControllerProvider =
    NotifierProvider.autoDispose<LoginController, AsyncValue<void>>(
  LoginController.new,
  name: 'loginControllerProvider',
);
