// © r2 software. All rights reserved.
// File: lib/features/tasks/presentation/pages/tasks_page.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Placeholder tasks screen shown after successful login.
// Author: AI-generated with r2 software guidelines

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:miica_mobile/core/di/providers.dart';

/// Minimal task list placeholder shown after authentication.
/// Responsibilities: confirm navigation and allow token clearing.
/// Limits: does not render actual task data yet.
class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesion',
            onPressed: () async {
              await ref.read(authRepositoryProvider).logout();
              if (!context.mounted) return;
              context.go('/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Bienvenido. Esta es la vista de tareas pendiente de implementar.'),
      ),
    );
  }
}
