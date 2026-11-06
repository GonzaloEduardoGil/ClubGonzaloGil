import 'package:club_gonzalo_gil/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('navega desde login al registro', (tester) async {
    await tester.pumpWidget(const ClubGonzaloGilApp());

    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextButton).last);
    await tester.pumpAndSettle();

    expect(find.text('Registrarme'), findsNWidgets(2));
    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Confirmar contraseña'), findsOneWidget);
  });
}
