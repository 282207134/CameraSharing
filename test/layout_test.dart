import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera_sharing/app.dart';
import 'package:camera_sharing/data/app_store.dart';
import 'package:camera_sharing/data/models.dart';

void main() {
  setUpAll(() async {
    final loader = FontLoader('DMSans')
      ..addFont(rootBundle.load('assets/fonts/DMSans.ttf'));
    await loader.load();
  });
  for (final size in [
    const Size(375, 812),
    const Size(402, 874),
    const Size(320, 568),
  ]) {
    testWidgets(
      'all pages fit ${size.width.toInt()} x ${size.height.toInt()}',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = AppStore();
        await tester.pumpWidget(CamshareApp(store: store));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        for (final route in [
          '/signup',
          '/login',
          '/home',
          '/specification',
          '/route',
          '/photos',
          '/scan',
          '/code',
          '/wallet',
          '/promo',
          '/add-card',
          '/credit',
          '/payment',
          '/success',
          '/history',
          '/settings',
        ]) {
          final navigator = tester.state<NavigatorState>(
            find.byType(Navigator),
          );
          navigator.pushNamed(route);
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull, reason: route);
        }
        store.activeCamera = cameras.first;
        tester.state<NavigatorState>(find.byType(Navigator)).pushNamed('/home');
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'active rental');
      },
    );
  }
}
