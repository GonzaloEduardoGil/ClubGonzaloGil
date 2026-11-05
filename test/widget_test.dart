import 'package:club_gonzalo_gil/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('navega desde login al registro', (tester) async {
    await tester.pumpWidget(const ClubGonzaloGilApp());

    await tester.tap(find.text('Comenzar'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Registrate'));
    await tester.pumpAndSettle();

    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Confirmar contraseña'), findsOneWidget);
  });
}
