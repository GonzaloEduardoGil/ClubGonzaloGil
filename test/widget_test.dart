import 'package:club_gonzalo_gil/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('muestra la pantalla de bienvenida', (tester) async {
    await tester.pumpWidget(const ClubGonzaloGilApp());

    expect(find.text('CLUB DEPORTIVO'), findsOneWidget);
    expect(find.text('Comenzar'), findsOneWidget);
  });
}