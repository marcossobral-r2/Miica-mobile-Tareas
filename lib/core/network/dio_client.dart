// © r2 software. All rights reserved.
// File: lib/core/network/dio_client.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Configured Dio instance with auth and logging interceptors.
// Author: AI-generated with r2 software guidelines

import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Provides a configured Dio instance for the app.
/// - Sets base URL, timeouts, JSON content-type.
/// - Adds interceptors for logging and (optionally) auth.
class DioClient {
  DioClient._();

  static Dio create({List<Interceptor> extraInterceptors = const []}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        logPrint: (obj) {
          // ignore: avoid_print
          print(obj);
        },
      ),
    );

    for (final interceptor in extraInterceptors) {
      dio.interceptors.add(interceptor);
    }

    return dio;
  }
}
