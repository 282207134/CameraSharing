import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key, this.promo = false});
  final bool promo;
  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final promo = TextEditingController();
  bool busy = false;
  @override
  void dispose() {
    promo.dispose();
    super.dispose();
  }

  Future<void> apply() async {
    setState(() => busy = true);
    final store = StoreScope.of(context);
    try {
      final applied = await store.applyPromo(promo.text);
      if (mounted) {
        toast(
          context,
          applied
              ? '\$10.00 promo credit added'
              : store.promoUsed
              ? 'This promo has already been used'
              : 'Promo code not recognized',
        );
        if (applied) tab(context, '/wallet');
      }
    } catch (_) {
      if (mounted) {
        toast(context, 'Could not save promo credit. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return PageFrame(
      index: 1,
      child: FillScroll(
        child: Column(
          children: [
            const PageHeader('Payment Method'),
            const SizedBox(height: 12),
            const Text(
              'Current Balance',
              style: TextStyle(color: C.muted, fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              money(store.balance),
              key: const ValueKey('balance'),
              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: BankCard(last4: store.cards.last),
            ),
            if (!widget.promo) ...[
              const SizedBox(height: 18),
              WalletAction(
                'Add New Card',
                icon: Icons.credit_card,
                color: const Color(0xFF00CDBA),
                route: '/add-card',
              ),
              WalletAction(
                'Add Credit',
                icon: Icons.euro,
                color: Colors.deepOrangeAccent,
                route: '/credit',
              ),
            ],
            const Spacer(),
            const SizedBox(height: 28),
            RoundPanel(
              color: C.navy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Handle(dark: true),
                  if (widget.promo) ...[
                    const Text(
                      'Add Promo Code',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter your promo code below',
                      style: TextStyle(color: C.muted, fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: promo,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        hintText: 'CAMSHARE1578',
                        prefixIcon: Icon(Icons.card_giftcard, color: C.purple),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => toast(
                          context,
                          'Try CAMSHARE1578 for \$10.00 demo credit',
                        ),
                        child: const Text(
                          'Don’t have a promo code?',
                          style: TextStyle(color: C.muted, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    PrimaryButton(
                      'Apply Promo Code',
                      color: C.green,
                      onPressed: busy ? null : apply,
                    ),
                  ] else
                    SizedBox(
                      width: double.infinity,
                      height: 62,
                      child: OutlinedButton(
                        onPressed: () => go(context, '/promo'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: .1),
                          side: const BorderSide(color: C.muted),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Add Promo Code',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 17,
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BankCard extends StatelessWidget {
  const BankCard({super.key, required this.last4});
  final String last4;
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Mastercard ending $last4',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 319 / 131,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF7000E3), Color(0xFF8E20FF)],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
              ),
            ),
            Image.asset(
              'assets/images/bank-card-background.png',
              fit: BoxFit.fill,
            ),
            Positioned(
              left: 16,
              top: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF493659),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const BankMark(),
              ),
            ),
            const Positioned(
              left: 16,
              bottom: 34,
              child: Text(
                'Mastercard',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 12,
              child: Text(
                '**** **** **** $last4',
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class WalletAction extends StatelessWidget {
  const WalletAction(
    this.label, {
    super.key,
    required this.icon,
    required this.color,
    required this.route,
  });
  final String label, route;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(28, 0, 28, 16),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => go(context, route),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: .2),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: C.background,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add,
                  color: Color(0xFF9295A5),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class CreditPage extends StatefulWidget {
  const CreditPage({super.key});
  @override
  State<CreditPage> createState() => _CreditPageState();
}

class _CreditPageState extends State<CreditPage> {
  bool colorful = false;
  static const amounts = [20, 28, 35, 42, 50, 57, 64, 85, 100];
  static const names = [
    'Regular',
    'Popular',
    'Gold',
    'Pro',
    'Best Value',
    'Premium',
    'Mercury',
    'Bronze',
    'Diamond',
  ];
  static const colors = [
    Colors.deepOrangeAccent,
    C.purple,
    Colors.cyan,
    Colors.pinkAccent,
    Colors.blue,
    Colors.orange,
    Colors.deepPurpleAccent,
    C.green,
    Colors.redAccent,
  ];
  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return PageFrame(
      index: 1,
      child: Column(
        children: [
          const PageHeader('Add Credit'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 64, vertical: 18),
            child: Text(
              'Choose an amount from below and press continue',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 1.6, color: C.muted),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    mainAxisExtent: 118,
                  ),
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: List.generate(9, (i) {
                    final selected = amounts[i] == store.credit;
                    final filled = colorful || selected;
                    return Semantics(
                      selected: selected,
                      button: true,
                      label: '${amounts[i]} dollars ${names[i]}',
                      child: GestureDetector(
                        key: ValueKey('credit-${amounts[i]}'),
                        onTap: () => setState(() => store.credit = amounts[i]),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: filled ? colors[i] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? C.purple
                                  : const Color(0xFFE9EAF0),
                              width: selected ? 2 : 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: filled
                                    ? colors[i].withValues(alpha: .15)
                                    : Colors.black.withValues(alpha: .02),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                selected
                                    ? Icons.check_circle
                                    : Icons.monetization_on,
                                color: filled ? Colors.white70 : colors[i],
                                size: 18,
                              ),
                              const Spacer(),
                              FittedBox(
                                child: Text(
                                  '\$${amounts[i]}',
                                  style: TextStyle(
                                    color: filled ? Colors.white : C.text,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                names[i],
                                maxLines: 1,
                                style: TextStyle(
                                  color: filled ? Colors.white70 : C.muted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 30),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Change amount style',
                  onPressed: () => setState(() => colorful = !colorful),
                  style: IconButton.styleFrom(
                    backgroundColor: C.lavender,
                    padding: const EdgeInsets.all(16),
                  ),
                  icon: const Icon(Icons.palette_outlined, color: C.purple),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: PrimaryButton(
                    'Continue to Payment',
                    onPressed: () => go(context, '/payment'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});
  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int selected = 0;
  bool busy = false;
  Future<void> pay() async {
    setState(() => busy = true);
    try {
      await StoreScope.of(context).topUp();
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/success',
          arguments: 'credit',
        );
      }
    } catch (_) {
      if (mounted) toast(context, 'Could not save payment. Please try again.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return PageFrame(
      index: 1,
      dark: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 42),
        child: RoundPanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const Handle(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Select a Card',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap to select a card from below',
                        style: TextStyle(fontSize: 14, color: C.muted),
                      ),
                      const SizedBox(height: 28),
                      ...store.cards.asMap().entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: CardChoice(
                            last4: e.value,
                            selected: selected == e.key,
                            onTap: () => setState(() => selected = e.key),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      PrimaryButton(
                        busy ? 'Adding credit…' : 'Make Payment Now',
                        color: C.green,
                        onPressed: busy ? null : pay,
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Demo credit · ${money(store.credit * 100)}',
                          style: const TextStyle(color: C.muted, fontSize: 13),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
              RoundPanel(
                color: C.navy,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Handle(dark: true),
                    const Text(
                      'Recent Payments',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const BankMark(),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Mastercard\n•••• 1211',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            money(store.credit * 100),
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CardChoice extends StatelessWidget {
  const CardChoice({
    super.key,
    required this.last4,
    required this.selected,
    required this.onTap,
  });
  final String last4;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mastercard',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const BankMark(),
                      const SizedBox(width: 12),
                      Text(
                        '••••  $last4',
                        style: const TextStyle(color: C.muted, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? C.green : C.muted,
            ),
          ],
        ),
      ),
    ),
  );
}

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key, this.credit = false});
  final bool credit;
  @override
  Widget build(BuildContext context) => PageFrame(
    index: 1,
    child: FillScroll(
      padding: const EdgeInsets.fromLTRB(28, 65, 28, 50),
      child: Column(
        children: [
          const SizedBox(height: 26),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 26),
            child: Text(
              credit
                  ? 'Your credit has been added successfully.'
                  : 'Your credit card has been added successfully.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ),
          const Spacer(),
          Image.asset('assets/images/success.png', width: 280, height: 255),
          const Spacer(),
          PrimaryButton(
            credit ? 'Back to Wallet' : 'Buy Credit Now',
            color: C.green,
            onPressed: () =>
                credit ? tab(context, '/wallet') : go(context, '/credit'),
          ),
        ],
      ),
    ),
  );
}
