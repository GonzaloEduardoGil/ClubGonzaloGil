import 'package:club_gonzalo_gil/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navega desde bienvenida al login', (tester) async {
    await tester.pumpWidget(const ClubGonzaloGilApp());

    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Contraseña'), findsOneWidget);
  });
}
