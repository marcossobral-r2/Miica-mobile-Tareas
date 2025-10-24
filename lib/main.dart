// © r2 software. All rights reserved.
// File: lib/main.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Flutter entry point configuring providers and router.
// Author: AI-generated with r2 software guidelines

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:miica_mobile/app_router.dart';

void main() {
  runApp(const ProviderScope(child: MiicaApp()));
}

/// Root widget for MIICA Mobile.
/// Responsibilities: provide theme and wire go_router.
/// Limits: does not host feature logic directly.
class MiicaApp extends ConsumerWidget {
  const MiicaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'MIICA Mobile',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1B5E20)),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
