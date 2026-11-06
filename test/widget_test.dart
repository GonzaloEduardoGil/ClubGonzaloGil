import 'package:club_gonzalo_gil/screens/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navega desde login al registro', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: WelcomeScreen(),
      ),
    );

    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TextButton).last);
    await tester.pumpAndSettle();

    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Confirmar contraseña'), findsOneWidget);
  });
}