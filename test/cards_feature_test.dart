import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/app.dart';
import 'package:expense_tracker/controller.dart';
import 'package:expense_tracker/widgets/virtual_card.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'app_password': '1234',
      'is_password_protection_enabled': true,
      'user_name': 'Arthur',
    });
  });

  group('ExpenseController Card CRUD', () {
    test('Initializes with default seed cards when storage is empty', () async {
      final controller = ExpenseController();
      await controller.initialize();

      expect(controller.cards.length, equals(3));
      expect(controller.cards.first.title, equals('Main Debit'));
      expect(controller.cards.first.cardNumber, equals('6175'));
    });

    test('addCard appends a new card and saves to storage', () async {
      final controller = ExpenseController();
      await controller.initialize();

      final newCard = VirtualCardData(
        title: 'Commercial Platinum',
        cardNumber: '9942',
        balance: 75000.0,
        brand: 'visa',
        gradientIndex: 3,
      );

      await controller.addCard(newCard);

      expect(controller.cards.length, equals(4));
      expect(controller.cards.last.title, equals('Commercial Platinum'));
      expect(controller.cards.last.cardNumber, equals('9942'));
      expect(controller.cards.last.balance, equals(75000.0));
      expect(controller.cards.last.brand, equals('visa'));
    });

    test('deleteCard removes a card by id and updates storage', () async {
      final controller = ExpenseController();
      await controller.initialize();

      final firstCardId = controller.cards.first.id;
      await controller.deleteCard(firstCardId);

      expect(controller.cards.length, equals(2));
      expect(controller.cards.any((c) => c.id == firstCardId), isFalse);
    });
  });

  group('Add & Delete Card UI Widget Flow', () {
    testWidgets('Add card via dialog and delete card with confirmation dialog',
        (WidgetTester tester) async {
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

      // 2. Navigate to Cards tab (index 1)
      await tester.tap(find.byIcon(Icons.credit_card_rounded));
      await tester.pump(const Duration(milliseconds: 400));

      // Verify Cards section header is visible
      expect(find.text('My Cards (3)'), findsOneWidget);
      expect(find.byType(VirtualCardsCarousel), findsOneWidget);

      // 3. Tap the + icon button in My Cards section to open Add Card dialog
      final addCardButton = find.byTooltip('Add Card');
      expect(addCardButton, findsOneWidget);
      await tester.tap(addCardButton);
      await tester.pump(const Duration(milliseconds: 400));

      // 4. Verify Add Card modal sheet opened
      expect(find.text('Add New Card'), findsOneWidget);
      expect(find.text('Card Name / Title'), findsOneWidget);
      expect(find.text('Last 4 Digits'), findsOneWidget);
      expect(find.text('Starting Balance (LKR)'), findsOneWidget);

      // Enter card details
      await tester.enterText(
          find.byKey(const Key('add_card_title_field')), 'Commercial Bank');
      await tester.enterText(
          find.byKey(const Key('add_card_number_field')), '5521');
      await tester.enterText(
          find.byKey(const Key('add_card_balance_field')), '82000.50');
      await tester.pump(const Duration(milliseconds: 200));

      // Select Visa brand
      final visaChip = find.text('Visa').last;
      await tester.ensureVisible(visaChip);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(visaChip);
      await tester.pump(const Duration(milliseconds: 200));

      // Select Sky Blue theme
      final themeChoice = find.text('Sky Blue');
      await tester.ensureVisible(themeChoice);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(themeChoice);
      await tester.pump(const Duration(milliseconds: 200));

      // Scroll to reveal and tap submit button
      final addCardSubmitButton = find.byKey(const Key('add_card_submit_button'));
      await tester.ensureVisible(addCardSubmitButton);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(addCardSubmitButton);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Sheet should be dismissed, and card count should be 4
      expect(find.text('Add New Card'), findsNothing);
      expect(find.text('My Cards (4)'), findsOneWidget);
      expect(find.text('Card "Commercial Bank" added to wallet.'), findsOneWidget);

      // 5. Test Delete Card with Confirmation Dialog
      // Tap delete icon on the card
      final deleteCardIcon = find.byIcon(Icons.delete_outline_rounded).first;
      await tester.tap(deleteCardIcon);
      await tester.pump(const Duration(milliseconds: 300));

      // Verify confirmation dialog shows exact prompt
      expect(find.text('Delete Card'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this card?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);

      // Test Cancel dismissal
      await tester.tap(find.text('Cancel'));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Are you sure you want to delete this card?'), findsNothing);
      expect(find.text('My Cards (4)'), findsOneWidget);

      // Tap delete again and confirm deletion
      await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Are you sure you want to delete this card?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      // Now card count should decrement to 3
      expect(find.text('My Cards (3)'), findsOneWidget);
      expect(find.textContaining('deleted.'), findsOneWidget);
    });
  });
}
