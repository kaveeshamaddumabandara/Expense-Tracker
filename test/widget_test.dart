import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/app.dart';

void main() {
  testWidgets('App loads the auth screen', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'app_password': '1234',
      'is_password_protection_enabled': true,
    });

    await tester.pumpWidget(const ExpenseTrackerApp());
    await tester.pump();

    expect(find.text('Welcome back'), findsOneWidget);
  });
}
