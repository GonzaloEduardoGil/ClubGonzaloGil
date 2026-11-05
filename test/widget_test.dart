import 'package:club_gonzalo_gil/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra la pantalla de bienvenida', (tester) async {
    await tester.pumpWidget(const ClubGonzaloGilApp());

    expect(find.text('Club Gonzalo Gil'), findsOneWidget);
    expect(
      find.text('Reservá tu espacio deportivo de forma simple y rápida.'),
      findsOneWidget,
    );
  });
}