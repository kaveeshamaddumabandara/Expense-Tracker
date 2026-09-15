import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/widgets/circular_balance_hero.dart';
import 'package:expense_tracker/widgets/trend_chart.dart';
import 'package:expense_tracker/widgets/virtual_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'app_password': '1234',
      'is_password_protection_enabled': true,
      'user_name': 'Arthur',
    });
  });

  testWidgets('Full Offline App Flow: AppLock -> Dashboard -> Analytics -> Add -> Transactions -> Profile & Security',
      (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    tester.view.physicalSize = const Size(1170, 2532); // iPhone dimensions
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    // 1. App loads AppLockScreen
    await tester.pumpWidget(const ExpenseTrackerApp());
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Smart Finance'), findsOneWidget);
    expect(find.text('Unlock App'), findsOneWidget);

    // 2. Unlock App with Passcode
    await tester.enterText(find.byType(TextFormField), '1234');
    await tester.tap(find.text('Unlock App'));
    await tester.pumpAndSettle();

    // 3. Verify Dashboard Tab (Screen 1)
    expect(find.text('Welcome back,'), findsOneWidget);
    expect(find.text('Arthur'), findsOneWidget);
    expect(find.byIcon(Icons.menu_rounded), findsNothing);
    expect(find.text('Activities'), findsNothing);
    expect(find.text('Current Balance'), findsOneWidget);
    expect(find.text('Total Income'), findsOneWidget);
    expect(find.text('Total Expenses'), findsOneWidget);
    expect(find.text('Number of transactions'), findsOneWidget);
    expect(find.text('Recent transactions'), findsOneWidget);
    expect(find.textContaining('LKR'), findsWidgets);
    expect(find.textContaining(r'$'), findsNothing);

    // 4. Navigate to Cards & Analytics Tab (Screen 2 & 3)
    await tester.tap(find.byIcon(Icons.credit_card_rounded));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.byType(CircularBalanceHero), findsOneWidget);
    expect(find.textContaining('LKR'), findsWidgets);
    expect(find.textContaining(r'$'), findsNothing);
    expect(find.text('Assets'), findsOneWidget);
    expect(find.text('Debt'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
    expect(find.byType(FinanceTrendChart), findsOneWidget);
    expect(find.byType(VirtualCardsCarousel), findsOneWidget);
    expect(find.textContaining('My Cards'), findsOneWidget);

    // 5. Navigate to Add / Edit Transaction Tab
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('New Transaction'), findsOneWidget);
    expect(find.text('LKR'), findsOneWidget);
    expect(find.textContaining(r'$'), findsNothing);
    expect(find.text('Expense'), findsWidgets);
    expect(find.text('Income'), findsWidgets);
    expect(find.text('Food & Beverage'), findsWidgets);
    expect(find.text('Save Transaction'), findsOneWidget);

    // 6. Navigate to Transactions Tab
    await tester.tap(find.byIcon(Icons.receipt_long_rounded));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('All Types'), findsOneWidget);
    expect(find.text('Food & Beverage'), findsWidgets);
    expect(find.textContaining('LKR'), findsWidgets);
    expect(find.textContaining(r'$'), findsNothing);

    // 7. Navigate to Profile & Security Tab
    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Profile & Security'), findsOneWidget);
    expect(find.text('Arthur'), findsOneWidget);
    expect(find.textContaining('LKR'), findsWidgets);
    expect(find.textContaining(r'$'), findsNothing);
    expect(find.text('Security & Protection'), findsOneWidget);
    expect(find.text('Password Protection'), findsOneWidget);
    expect(find.text('Lock App Now'), findsOneWidget);
  });
}
