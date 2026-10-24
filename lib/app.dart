import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'core/widgets.dart';
import 'data/app_store.dart';
import 'features/account/account_pages.dart';
import 'features/auth/auth_pages.dart';
import 'features/cameras/camera_pages.dart';
import 'features/cameras/unlock_pages.dart';
import 'features/wallet/add_card_page.dart';
import 'features/wallet/wallet_pages.dart';

class CamshareApp extends StatelessWidget {
  const CamshareApp({super.key, required this.store});
  final AppStore store;
  @override
  Widget build(BuildContext context) => StoreScope(
    store: store,
    child: MaterialApp(
      title: 'Camshare',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      initialRoute: store.signedIn ? '/home' : '/',
      onGenerateRoute: (settings) {
        final page = switch (settings.name) {
          '/' => const WelcomePage(),
          '/signup' => const AuthPage(signUp: true),
          '/login' => const AuthPage(),
          '/home' => const HomePage(),
          '/specification' => const HomePage(specifications: true),
          '/route' => const RoutePage(),
          '/photos' => const PhotosPage(),
          '/scan' => const ScanPage(),
          '/code' => CodePage(initial: settings.arguments as String? ?? ''),
          '/wallet' => const WalletPage(),
          '/promo' => const WalletPage(promo: true),
          '/add-card' => const AddCardPage(),
          '/credit' => const CreditPage(),
          '/payment' => const PaymentPage(),
          '/success' => SuccessPage(credit: settings.arguments == 'credit'),
          '/history' => const HistoryPage(),
          '/settings' => const SettingsPage(),
          _ => const HomePage(),
        };
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => page,
        );
      },
    ),
  );
}
