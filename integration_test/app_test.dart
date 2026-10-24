import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera_sharing/app.dart';
import 'package:camera_sharing/data/app_store.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('complete rental, wallet and profile flow with screenshots', (
    tester,
  ) async {
    const key = 'camshare.integration.v1';
    await SharedPreferencesAsync().remove(key);
    final store = await AppStore.load(storageKey: key);
    await tester.pumpWidget(CamshareApp(store: store));
    Future<void> settle() async {
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }

    Future<void> tap(Finder finder) async {
      ScaffoldMessenger.of(
        tester.element(find.byType(Scaffold).first),
      ).removeCurrentSnackBar();
      await settle();
      await tester.ensureVisible(finder.first);
      await tester.tap(finder.first);
      await settle();
    }

    Future<void> shot(String name) async {
      ScaffoldMessenger.of(
        tester.element(find.byType(Scaffold).first),
      ).clearSnackBars();
      await settle();
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await binding.takeScreenshot(name);
    }

    Future<void> field(String label, String value) async {
      await tester.enterText(find.widgetWithText(TextFormField, label), value);
    }

    Future<void> hideKeyboard() async {
      FocusManager.instance.primaryFocus?.unfocus();
      await settle();
    }

    Future<void> nav(String name) => tap(find.byKey(ValueKey('nav-$name')));

    await shot('01-welcome');
    await tap(find.text('Let’s Get Started'));
    await shot('02-sign-up');
    await tap(find.text('Already have an account? Log In'));
    await shot('03-login');
    await field('Email address', 'sobuj@camshare.app');
    await field('Password', 'camshare123');
    await hideKeyboard();
    await tap(find.widgetWithText(FilledButton, 'Log In'));
    expect(store.signedIn, true);
    await shot('04-home');
    await tap(find.text('Canon 750D'));
    await shot('05-specification');
    await tap(find.text('Photos'));
    await shot('17-photos');
    await tap(find.byTooltip('Back'));
    await tap(find.byTooltip('Route to Store'));
    await shot('06-route');
    await tap(find.text('Scan to unlock'));
    await shot('07-scan');
    await tap(find.text('Put Camera Code'));
    await tap(find.byKey(const ValueKey('key-5')));
    await tap(find.byKey(const ValueKey('key-7')));
    await shot('08-code');
    await tap(find.byKey(const ValueKey('key-1')));
    await tap(find.byKey(const ValueKey('key-2')));
    await shot('09-code-ready');
    await tap(find.text('Unlock Camera'));
    expect(store.activeCamera, isNotNull);
    await tap(find.text('Return Canon 750D'));
    expect(store.activeCamera, isNull);
    expect(store.balance, 6791);
    await shot('18-history');
    await tester.enterText(find.byType(TextField), 'Nikon');
    await settle();
    expect(find.text('Sony HX6'), findsNothing);
    await tester.enterText(find.byType(TextField), '');
    await hideKeyboard();
    await nav('wallet');
    await shot('10-wallet');
    await tap(find.text('Add New Card'));
    await field('CARD HOLDER NAME', 'Soumitro Sobuj');
    await field('CARD NUMBER', '4242 4242 4242 4242');
    await field('EXPIRY DATE', '12/30');
    await field('CVV', '123');
    await hideKeyboard();
    await shot('11-add-card');
    await tap(find.text('Save Card Details'));
    expect(store.cards.last, '4242');
    await shot('13-success');
    await tap(find.text('Buy Credit Now'));
    await shot('14-credit');
    await tap(find.byTooltip('Change amount style'));
    await tap(find.byKey(const ValueKey('credit-28')));
    await shot('15-credit-selected');
    await tap(find.text('Continue to Payment'));
    await shot('12-payment');
    await tap(find.text('Make Payment Now'));
    expect(store.balance, 9591);
    await tap(find.text('Back to Wallet'));
    await tap(find.text('Add Promo Code'));
    await tester.enterText(find.byType(TextField), 'CAMSHARE1578');
    await hideKeyboard();
    await shot('16-promo');
    await tap(find.text('Apply Promo Code'));
    expect(store.balance, 10591);
    await nav('settings');
    await shot('19-settings');
    await field('NAME', 'Camshare Explorer');
    await hideKeyboard();
    await tap(find.text('Save and Continue'));
    final restored = await AppStore.load(storageKey: key);
    expect(restored.name, 'Camshare Explorer');
    expect(restored.balance, 10591);
    expect(restored.cards.last, '4242');
    expect(restored.rentals.length, 5);
    expect(restored.promoUsed, true);
    await SharedPreferencesAsync().remove(key);
    await nav('home');
  });
}
