import 'package:flutter_test/flutter_test.dart';
import 'package:kitoapp/app.dart';

void main() {
  testWidgets('App loads login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const KitoApp());
    await tester.pumpAndSettle();

    expect(find.byType(KitoApp), findsOneWidget);
  });
}
