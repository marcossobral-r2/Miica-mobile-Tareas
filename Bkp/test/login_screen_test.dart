import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:miica_mobile/main.dart';

void main() {
  testWidgets('Login screen renders expected widgets', (tester) async {
    await tester.pumpWidget(const MiicaApp());

    expect(find.text('MIICA'), findsOneWidget);
    expect(
      find.text('Sistema de Cuadrillas – Arbolado GCBA'),
      findsOneWidget,
    );
    expect(find.text('Ingresar'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Usuario o Legajo'),
      'capataz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'PIN o Contraseña'),
      '1234',
    );

    await tester.tap(find.text('Ingresar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Tareas'), findsOneWidget);
    expect(find.textContaining('Mostrando'), findsOneWidget);

    final detailButton = find.widgetWithText(OutlinedButton, 'Ver detalle').first;
    await tester.ensureVisible(detailButton);
    await tester.tap(detailButton);
    await tester.pumpAndSettle();

    expect(find.text('Detalle de Tarea'), findsOneWidget);
    expect(find.text('Datos del Árbol'), findsOneWidget);
  });
}
