import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera_sharing/data/app_store.dart';
import 'package:camera_sharing/features/wallet/add_card_page.dart';

void main() {
  test(
    'promo is normalized, rejects invalid codes and can only be used once',
    () async {
      final store = AppStore();
      expect(await store.applyPromo('WRONG'), false);
      expect(store.balance, 7201);
      expect(await store.applyPromo(' camshare1578 '), true);
      expect(store.balance, 8201);
      expect(await store.applyPromo('CAMSHARE1578'), false);
      expect(store.balance, 8201);
    },
  );
  test('top-up uses integer cents', () async {
    final store = AppStore()..credit = 28;
    await store.topUp();
    expect(store.balance, 10001);
  });
  test(
    'rental blocks invalid codes, insufficient balance and duplicate rentals',
    () async {
      final store = AppStore();
      expect(await store.unlock('12'), false);
      store.balance = 409;
      expect(await store.unlock('5712'), false);
      store.balance = 410;
      expect(await store.unlock('5712'), true);
      expect(await store.unlock('5712'), false);
      await store.finishRental();
      expect(store.balance, 0);
      expect(store.rentals.first.camera, 'Canon 750D');
      expect(store.rentals.length, 5);
      await store.finishRental();
      expect(store.balance, 0);
      expect(store.rentals.length, 5);
    },
  );
  test('serialized card contains only last four digits', () async {
    String saved = '';
    final store = AppStore(save: (value) async => saved = value);
    await store.addCard('4242 4242 4242 4242');
    await store.addCard('4242424242424242');
    final data = jsonDecode(saved) as Map<String, dynamic>;
    expect(data['cards'], ['1035', '5648', '4242']);
    expect(saved.contains('4242424242424242'), false);
    expect(data.containsKey('password'), false);
    expect(data.containsKey('cvv'), false);
  });
  test('card form catches invalid numbers and expired dates', () {
    expect(cardNumberValidator('4242 4242 4242 4242'), null);
    expect(cardNumberValidator('4242 4242 4242 4243'), isNotNull);
    expect(cardNumberValidator('4242'), isNotNull);
    expect(expiryValidator('12/30', now: DateTime(2026, 10, 24)), null);
    expect(expiryValidator('10/26', now: DateTime(2026, 10, 24)), null);
    expect(expiryValidator('09/26', now: DateTime(2026, 10, 24)), isNotNull);
    expect(expiryValidator('13/30'), isNotNull);
  });
}
