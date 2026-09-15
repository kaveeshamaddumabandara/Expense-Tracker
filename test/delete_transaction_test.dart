import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/widgets/transaction_tile.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'app_password': '1234',
      'is_password_protection_enabled': true,
      'user_name': 'Arthur',
    });
  });

  testWidgets('Delete Transaction with Confirmation Dialog flow', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. Launch app and unlock
    await tester.pumpWidget(const ExpenseTrackerApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), '1234');
    await tester.tap(find.text('Unlock App'));
    await tester.pumpAndSettle();

    // 2. We should see Recent transactions on the Dashboard
    expect(find.text('Recent transactions'), findsOneWidget);
    expect(find.byType(AppTransactionTile), findsWidgets);

    // Find the first delete icon button
    final deleteButtonFinder = find.byIcon(Icons.delete_outline_rounded).first;
    expect(deleteButtonFinder, findsOneWidget);

    // 3. Tap delete icon button to trigger dialog
    await tester.tap(deleteButtonFinder);
    await tester.pumpAndSettle();

    // 4. Verify confirmation dialog appears with exact text
    expect(find.text('Delete Transaction'), findsOneWidget);
    expect(
      find.text('Are you sure you want to delete this transaction?'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    // 5. Test Cancel dismissal
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to delete this transaction?'), findsNothing);
    expect(find.byType(AppTransactionTile), findsWidgets);

    // 6. Tap delete again and confirm deletion
    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('Are you sure you want to delete this transaction?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    // Dialog closed
    expect(find.text('Are you sure you want to delete this transaction?'), findsNothing);
  });
}
