import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:miica_mobile/app_router.dart';
import 'package:miica_mobile/core/di/providers.dart';
import 'package:miica_mobile/features/auth/domain/auth_repository.dart';
import 'package:miica_mobile/features/auth/presentation/controllers/login_controller.dart';
import 'package:miica_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:miica_mobile/main.dart';

class _StubAuthRepository implements AuthRepository {
  bool _loggedIn = false;
  bool shouldSucceed = false;

  @override
  Future<bool> login({required String username, required String secret}) async {
    _loggedIn = shouldSucceed;
    return shouldSucceed;
  }

  @override
  Future<void> logout() async {
    _loggedIn = false;
  }

  @override
  Future<bool> isLoggedIn() async => _loggedIn;
}

class _LoadingLoginController extends LoginController {
  @override
  AsyncValue<void> build() => const AsyncValue<void>.loading();

  @override
  Future<void> submit({
    required String username,
    required String secret,
  }) async {
    // No-op for loading state verification.
  }
}

void main() {
  group('LoginPage', () {
    testWidgets('disables submit button while loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(_StubAuthRepository()),
            loginControllerProvider.overrideWith(_LoadingLoginController.new),
          ],
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('shows SnackBar on invalid credentials', (tester) async {
      final stubRepository = _StubAuthRepository();
      stubRepository.shouldSucceed = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(stubRepository),
          ],
          child: const MaterialApp(home: LoginPage()),
        ),
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'operator@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contrasena'),
        'wrong',
      );

      await tester.tap(find.text('Ingresar'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Usuario o clave inválidos'), findsOneWidget);
    });

    testWidgets('navigates to tareas on success', (tester) async {
      final stubRepository = _StubAuthRepository()..shouldSucceed = true;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(stubRepository),
            appRouterProvider.overrideWith((ref) {
              return GoRouter(
                initialLocation: '/login',
                routes: [
                  GoRoute(
                    path: '/login',
                    builder: (context, state) => const LoginPage(),
                  ),
                  GoRoute(
                    path: '/tareas',
                    builder: (context, state) => const Scaffold(
                      body: Center(child: Text('Pantalla de tareas')),
                    ),
                  ),
                ],
              );
            }),
          ],
          child: const MiicaApp(),
        ),
      );

      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'operator@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Contrasena'),
        'correct',
      );

      await tester.tap(find.text('Ingresar'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Pantalla de tareas'), findsOneWidget);
    });
  });
}
