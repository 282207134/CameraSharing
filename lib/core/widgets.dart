import 'package:flutter/material.dart';
import '../data/app_store.dart';
import 'theme.dart';

class StoreScope extends InheritedNotifier<AppStore> {
  const StoreScope({super.key, required AppStore store, required super.child})
    : super(notifier: store);
  static AppStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}

void go(BuildContext context, String route, {Object? arguments}) =>
    Navigator.of(context).pushNamed(route, arguments: arguments);
void tab(BuildContext context, String route) =>
    Navigator.of(context).pushNamedAndRemoveUntil(route, (_) => false);
void toast(BuildContext context, String message) =>
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.color = C.purple,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 58,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withValues(alpha: .35),
        disabledForegroundColor: Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 14),
            ],
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.child,
    this.index = 0,
    this.dark = false,
    this.navigation = true,
    this.resize = true,
  });
  final Widget child;
  final int index;
  final bool dark, navigation, resize;
  @override
  Widget build(BuildContext context) => Scaffold(
    resizeToAvoidBottomInset: resize,
    backgroundColor: dark ? C.navy : C.background,
    body: SafeArea(bottom: false, child: child),
    bottomNavigationBar:
        navigation && MediaQuery.viewInsetsOf(context).bottom == 0
        ? CamNavigation(index: index)
        : null,
  );
}

class CamNavigation extends StatelessWidget {
  const CamNavigation({super.key, required this.index});
  final int index;
  @override
  Widget build(BuildContext context) {
    const labels = ['Home', 'Wallet', 'History', 'Settings'];
    const routes = ['/home', '/wallet', '/history', '/settings'];
    const icons = [
      Icons.home_rounded,
      Icons.account_balance_wallet_outlined,
      Icons.history_rounded,
      Icons.settings_outlined,
    ];
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              4,
              (i) => IconButton(
                key: ValueKey('nav-${routes[i].substring(1)}'),
                tooltip: labels[i],
                onPressed: () => tab(context, routes[i]),
                icon: Icon(
                  icons[i],
                  size: 27,
                  color: i == index ? C.purple : const Color(0xFF9295A5),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget {
  const PageHeader(this.title, {super.key, this.back = true, this.action});
  final String title;
  final bool back;
  final Widget? action;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 76,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: C.text,
          ),
        ),
        if (back)
          Positioned(
            left: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                tooltip: 'Back',
                icon: const Icon(Icons.chevron_left_rounded),
                onPressed: () => Navigator.of(context).canPop()
                    ? Navigator.pop(context)
                    : tab(context, '/home'),
              ),
            ),
          ),
        if (action != null) Positioned(right: 24, child: action!),
      ],
    ),
  );
}

class Handle extends StatelessWidget {
  const Handle({super.key, this.dark = false});
  final bool dark;
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      margin: const EdgeInsets.only(top: 20, bottom: 26),
      width: 38,
      height: 5,
      decoration: BoxDecoration(
        color: dark ? Colors.white24 : const Color(0x2E000000),
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

class RoundPanel extends StatelessWidget {
  const RoundPanel({
    super.key,
    required this.child,
    this.color = C.background,
    this.padding = const EdgeInsets.fromLTRB(28, 0, 28, 28),
  });
  final Widget child;
  final Color color;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: padding,
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
    ),
    child: child,
  );
}

class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.password = false,
    this.validator,
    this.keyboard,
    this.hint,
  });
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool password;
  final String? Function(String?)? validator;
  final TextInputType? keyboard;
  final String? hint;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: TextFormField(
      controller: controller,
      obscureText: password,
      validator: validator,
      keyboardType: keyboard,
      autocorrect: !password,
      enableSuggestions: !password,
      style: const TextStyle(fontSize: 15, color: C.text),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon, color: C.purple, size: 20),
      ),
    ),
  );
}

String? requiredText(String? value) =>
    value == null || value.trim().isEmpty ? 'This field is required' : null;
String? emailValidator(String? value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
    ? null
    : 'Enter a valid email address';
String? passwordValidator(String? value) =>
    (value?.length ?? 0) >= 6 ? null : 'Use at least 6 characters';

class BankMark extends StatelessWidget {
  const BankMark({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 30,
    height: 22,
    child: Stack(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFFF553B),
            shape: BoxShape.circle,
          ),
        ),
        Positioned(
          left: 12,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFFFC62B).withValues(alpha: .9),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Fills tall screens and scrolls naturally on compact screens or with a keyboard.
class FillScroll extends StatelessWidget {
  const FillScroll({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: box.maxHeight),
        child: IntrinsicHeight(
          child: Padding(padding: padding, child: child),
        ),
      ),
    ),
  );
}
