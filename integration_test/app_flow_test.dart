import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ssma/main.dart' as app; // your package
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create customer and make sale (Add-button submit)', (WidgetTester tester) async {
    // Start app
    app.main();
    await tester.pumpAndSettle();

    // --- Debug dump (concise) ---
    final root = tester.binding.renderViewElement;
    if (root != null) {
      final dump = root.toStringDeep();
      final maxChars = 12 * 1000; // 12k chars max to avoid huge logs
      if (dump.length <= maxChars) {
        print('\n====== BEGIN WIDGET TREE DUMP ======');
        print(dump);
        print('======= END WIDGET TREE DUMP =======\n');
      } else {
        print('\n====== BEGIN WIDGET TREE DUMP (truncated) ======');
        print(dump.substring(0, maxChars));
        print('... (truncated) ...');
        print('======= END WIDGET TREE DUMP =======\n');
      }
    }

    await tester.pumpAndSettle(const Duration(seconds: 1));

    // --- Navigate to Customers screen (fallbacks) ---
    Finder navCustomersFinder = find.byKey(const Key('nav_customers'));
    if (tester.any(navCustomersFinder) == false) navCustomersFinder = find.text('Customers');
    if (tester.any(navCustomersFinder) == false) navCustomersFinder = find.byIcon(Icons.people);
    if (tester.any(navCustomersFinder) == false) {
      fail('Could not find the customers navigation control. Add Key("nav_customers") to your nav widget.');
    }
    await tester.tap(navCustomersFinder);
    await tester.pumpAndSettle();

    // --- Open Add Customer (floating/add button) ---
    Finder addCust = find.byKey(const Key('add_customer_button'));
    if (tester.any(addCust) == false) addCust = find.byTooltip('Add');
    if (tester.any(addCust) == false) addCust = find.text('Add Customer');
    if (tester.any(addCust) == false) addCust = find.byIcon(Icons.add);
    expect(tester.any(addCust), isTrue, reason: 'Add customer control not found.');
    await tester.tap(addCust);
    await tester.pumpAndSettle();

    // --- Fill the form ---
    final nameField = find.byKey(const Key('customer_name_field'));
    final phoneField = find.byKey(const Key('customer_phone_field'));

    if (tester.any(nameField) == false) {
      final textFields = find.byType(TextField);
      expect(textFields, findsWidgets, reason: 'No TextFields found for customer form.');
      await tester.enterText(textFields.at(0), 'TestUser');
      if (tester.widgetList(textFields).length > 1) {
        await tester.enterText(textFields.at(1), '9999999999');
      }
    } else {
      await tester.enterText(nameField, 'TestUser');
      if (tester.any(phoneField)) await tester.enterText(phoneField, '9999999999');
    }

    await tester.pumpAndSettle();

    // --- Find the Add/Submit control (we treat Add as the submit here) ---
    Finder submitBtn = find.byKey(const Key('save_customer_button')); // still try common "save" key
    if (tester.any(submitBtn) == false) submitBtn = find.text('Add');
    if (tester.any(submitBtn) == false) submitBtn = find.text('Create');
    if (tester.any(submitBtn) == false) submitBtn = find.text('Done');
    if (tester.any(submitBtn) == false) submitBtn = find.widgetWithText(ElevatedButton, 'Add');
    if (tester.any(submitBtn) == false) submitBtn = find.widgetWithText(TextButton, 'Add');
    if (tester.any(submitBtn) == false) submitBtn = find.byTooltip('Add');
    if (tester.any(submitBtn) == false) submitBtn = find.byIcon(Icons.check);
    if (tester.any(submitBtn) == false) submitBtn = find.byIcon(Icons.add); // maybe final add button is icon-only

    // If still not found, provide helpful log and fail
    if (tester.any(submitBtn) == false) {
      final short = root?.toStringShort() ?? '<no root>';
      final deep = root?.toStringDeep() ?? '<no deep>';
      final truncatedDeep = deep.length > 8000 ? deep.substring(0, 8000) + '\n... (truncated) ...' : deep;
      print('\n=== Could not find any Add/submit control ===');
      print('Tried keys/text/icons: Key(save_customer_button), "Add","Create","Done", ElevatedButton/TextButton with text, tooltip, icons (check/add).');
      print('Widget tree short:\n$short\n');
      print('Widget tree deep (truncated):\n$truncatedDeep\n');
      fail('Add/submit button not found. Add a Key(\'save_customer_button\') or Key(\'add_customer_button\') to your submit control for stable tests.');
    }

    // --- Tap submit and verify the new customer appears ---
    await tester.tap(submitBtn);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('TestUser'), findsOneWidget, reason: 'Saved customer not visible in list.');
  }, timeout: Timeout(Duration(minutes: 5)));
}
