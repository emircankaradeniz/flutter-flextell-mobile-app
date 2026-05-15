import 'package:flutter_test/flutter_test.dart';
import 'package:flextell_case_study/app.dart';

void main() {
  testWidgets('Flextell login screen renders', (tester) async {
    await tester.pumpWidget(const FlextellApp());
    await tester.pump();

    expect(find.text('Flextell OAuth2 Case Study'), findsOneWidget);
    expect(find.text('Flextell ile giriş yap'), findsOneWidget);
  });
}
