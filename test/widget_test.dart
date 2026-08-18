import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/main.dart';

void main() {
  testWidgets('App starts with splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NobaroApp());
    expect(find.text('Nobaro'), findsWidgets);
  });
}
