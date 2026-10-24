import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import 'wallet_pages.dart';

String? cardNumberValidator(String? value) {
  final digits = (value ?? '').replaceAll(RegExp(r'\s'), '');
  if (!RegExp(r'^\d{13,19}$').hasMatch(digits)) {
    return 'Enter a valid card number';
  }
  int sum = 0;
  for (int i = 0; i < digits.length; i++) {
    int n = int.parse(digits[digits.length - 1 - i]);
    if (i.isOdd) {
      n *= 2;
      if (n > 9) n -= 9;
    }
    sum += n;
  }
  return sum % 10 == 0 ? null : 'Check your card number';
}

String? expiryValidator(String? value, {DateTime? now}) {
  final match = RegExp(r'^(\d{2})/(\d{2})$').firstMatch(value ?? '');
  if (match == null) return 'Use MM/YY';
  final month = int.parse(match[1]!), year = 2000 + int.parse(match[2]!);
  final current = now ?? DateTime.now();
  return month >= 1 && month <= 12 && DateTime(year, month + 1).isAfter(current)
      ? null
      : 'Card has expired';
}

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});
  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final form = GlobalKey<FormState>();
  final holder = TextEditingController(),
      number = TextEditingController(),
      expiry = TextEditingController(),
      cvv = TextEditingController();
  bool busy = false;
  @override
  void dispose() {
    for (final c in [holder, number, expiry, cvv]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await StoreScope.of(context).addCard(number.text);
      number.clear();
      cvv.clear();
      if (mounted) Navigator.pushReplacementNamed(context, '/success');
    } catch (_) {
      if (mounted) {
        toast(context, 'Could not save your card. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    index: 1,
    child: Column(
      children: [
        const PageHeader('Add New Card'),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 18, 28, 28),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Add your details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 7),
                  const Text(
                    'Start typing to add your card',
                    style: TextStyle(fontSize: 14, color: C.muted),
                  ),
                  const SizedBox(height: 30),
                  AppField(
                    controller: holder,
                    label: 'CARD HOLDER NAME',
                    icon: Icons.person_outline,
                    validator: requiredText,
                  ),
                  AppField(
                    controller: number,
                    label: 'CARD NUMBER',
                    icon: Icons.tag,
                    keyboard: TextInputType.number,
                    hint: '4242 4242 4242 4242',
                    validator: cardNumberValidator,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: AppField(
                          controller: expiry,
                          label: 'EXPIRY DATE',
                          hint: 'MM/YY',
                          keyboard: TextInputType.datetime,
                          validator: expiryValidator,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: AppField(
                          controller: cvv,
                          label: 'CVV',
                          keyboard: TextInputType.number,
                          password: true,
                          validator: (v) =>
                              RegExp(r'^\d{3,4}$').hasMatch(v ?? '')
                              ? null
                              : 'Use 3 or 4 digits',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  PrimaryButton(
                    'Save Card Details',
                    color: C.green,
                    onPressed: busy ? null : save,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Use a test card for this local preview.',
                    style: TextStyle(color: C.muted, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (MediaQuery.viewInsetsOf(context).bottom == 0)
          RoundPanel(
            color: C.navy,
            child: Column(
              children: [
                const Handle(dark: true),
                CardChoice(
                  last4: StoreScope.of(context).cards.last,
                  selected: true,
                  onTap: () => tab(context, '/wallet'),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}
