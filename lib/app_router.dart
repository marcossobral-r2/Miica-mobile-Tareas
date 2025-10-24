// © r2 software. All rights reserved.
// File: lib/app_router.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: go_router configuration for login and tasks flows.
// Author: AI-generated with r2 software guidelines

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:miica_mobile/core/di/providers.dart';
import 'package:miica_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:miica_mobile/features/tasks/presentation/pages/tasks_page.dart';

/// Provides the global [GoRouter] used by MaterialApp.router.
/// Responsibilities: define routes and auth-based redirects.
/// Limits: does not expose imperative navigation APIs.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepository = ref.read(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/tareas',
        builder: (context, state) => const TasksPage(),
      ),
    ],
    redirect: (context, state) async {
      final loggedIn = await authRepository.isLoggedIn();
      final loggingIn = state.matchedLocation == '/login';

      if (!loggedIn && !loggingIn) {
        return '/login';
      }
      if (loggedIn && loggingIn) {
        return '/tareas';
      }
      return null;
    },
  );
});
