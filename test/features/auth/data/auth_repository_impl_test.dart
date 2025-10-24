import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miica_mobile/core/security/token_store.dart';
import 'package:miica_mobile/features/auth/data/auth_api.dart';
import 'package:miica_mobile/features/auth/data/auth_constants.dart';
import 'package:miica_mobile/features/auth/data/auth_repository_impl.dart';

class _InMemoryTokenStore extends TokenStore {
  _InMemoryTokenStore();

  String? accessToken;
  String? refreshToken;

  @override
  Future<void> saveTokens(String access, {String? refresh}) async {
    accessToken = access;
    refreshToken = refresh;
  }

  @override
  Future<String?> readAccess() async => accessToken;

  @override
  Future<String?> readRefresh() async => refreshToken;

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
  }
}

class _FakeAuthApi extends AuthApi {
  _FakeAuthApi(this._handler)
      : super(
          unauthenticatedDio: Dio(),
          authenticatedDio: Dio(),
        );

  final Future<Map<String, dynamic>> Function(String username, String secret) _handler;

  @override
  Future<Map<String, dynamic>> login({
    required String username,
    required String secret,
  }) {
    return _handler(username, secret);
  }
}

void main() {
  group('AuthRepositoryImpl', () {
    test('saves tokens on successful login', () async {
      final store = _InMemoryTokenStore();
      final api = _FakeAuthApi((username, secret) async {
        expect(username, 'operator@example.com');
        expect(secret, 'top-secret');
        return {
          kAccessTokenKey: 'access-token',
          kRefreshTokenKey: 'refresh-token',
        };
      });
      final repository = AuthRepositoryImpl(api: api, tokenStore: store);

      final success = await repository.login(
        username: 'operator@example.com',
        secret: 'top-secret',
      );

      expect(success, isTrue);
      expect(store.accessToken, equals('access-token'));
      expect(store.refreshToken, equals('refresh-token'));
    });

    test('rethrows DioException on API error', () async {
      final store = _InMemoryTokenStore();
      final api = _FakeAuthApi((username, secret) async {
        throw DioException(
          requestOptions: RequestOptions(path: AuthEndpoints.login),
          response: Response(
            requestOptions: RequestOptions(path: AuthEndpoints.login),
            statusCode: 401,
          ),
        );
      });
      final repository = AuthRepositoryImpl(api: api, tokenStore: store);

      expect(
        () => repository.login(username: 'email', secret: 'bad-pass'),
        throwsA(isA<DioException>()),
      );
      expect(store.accessToken, isNull);
      expect(store.refreshToken, isNull);
    });
  });
}
