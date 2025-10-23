// © r2 software. All rights reserved.
// File: lib/core/config/app_config.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Centralized runtime configuration (API base URL, timeouts, etc.)
// Author: AI-generated with r2 software guidelines

class AppConfig {
  const AppConfig._();

  static const String apiBaseUrl = 'https://tareas-test.miica.r2software.net';
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
