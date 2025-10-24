// © r2 software. All rights reserved.
// File: lib/core/network/dio_client.dart
// Project: MIICA Mobile (Cuadrillas)
// Description: Configured Dio instance with auth and logging interceptors.
// Author: AI-generated with r2 software guidelines

import 'dart:developer' as developer;

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

    dio.interceptors.add(_SafeLogInterceptor());

    for (final interceptor in extraInterceptors) {
      dio.interceptors.add(interceptor);
    }

    return dio;
  }
}

/// Logs basic request/response information without exposing credentials.
/// Inputs: Dio request/response lifecycle events.
/// Outputs: developer.log statements, no side effects on data.
class _SafeLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      'REQUEST ${options.method} ${options.uri}',
      name: 'Dio',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    developer.log(
      'RESPONSE ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
      name: 'Dio',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      'ERROR ${err.response?.statusCode ?? 'N/A'} ${err.requestOptions.method} ${err.requestOptions.uri}: ${err.message}',
      name: 'Dio',
      error: err,
    );
    handler.next(err);
  }
}
