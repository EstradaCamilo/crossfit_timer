import 'package:flutter_test/flutter_test.dart';

import 'package:crossfit_timer/app/app.dart';

void main() {
  testWidgets('App boots with For Time home in Spanish', (tester) async {
    await tester.pumpWidget(const CrossFitTimerApp());
    await tester.pumpAndSettle();

    expect(find.text('CrossFit Timer'), findsOneWidget);
    expect(find.text('_camiloestrada'), findsOneWidget);
    expect(find.text('Iniciar'), findsOneWidget);
    expect(find.text('For Time'), findsOneWidget);
    expect(find.text('AMRAP'), findsOneWidget);
    expect(find.text('EMOM'), findsOneWidget);
    expect(find.text('Tabata'), findsOneWidget);
  });
}
