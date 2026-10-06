import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deslugify/main.dart';
import 'package:deslugify/screens/auth_store.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Fresh install opens the login screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DeslugifyApp());
    await tester.pumpAndSettle();

    expect(find.text('Deslugify'), findsWidgets);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  test('Demo account signs in and restores its session', () async {
    final user = await AuthStore.signIn(
      AuthStore.demoEmail,
      AuthStore.demoPassword,
    );

    expect(user?.name, 'Justine Berdejo');
    expect(user?.email, '423000470@ntc.edu.ph');
    expect((await AuthStore.currentUser())?.email, AuthStore.demoEmail);
  });
}
