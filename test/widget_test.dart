// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miica_mobile/main.dart';
import 'package:miica_mobile/core/di/providers.dart';
import 'package:miica_mobile/features/auth/domain/auth_repository.dart';

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<bool> login({required String username, required String pin}) async => true;

  @override
  Future<void> logout() async {}

  @override
  Future<bool> isLoggedIn() async => false;
}

void main() {
  testWidgets('MiicaApp loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        ],
        child: const MiicaApp(),
      ),
    );
    expect(find.text('MIICA'), findsOneWidget);
    expect(find.text('Sistema de Cuadrillas – Arbolado GCBA'), findsOneWidget);
  });
}
