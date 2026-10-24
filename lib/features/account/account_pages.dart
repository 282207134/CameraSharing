import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String query = '';
  bool highestFirst = false;
  @override
  Widget build(BuildContext context) {
    final items = StoreScope.of(context).rentals
        .where(
          (e) => '${e.camera} ${e.address}'.toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
    if (highestFirst) items.sort((a, b) => b.cents.compareTo(a.cents));
    return PageFrame(
      index: 2,
      dark: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 20, 28, 32),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (v) => setState(() => query = v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search for a history',
                      hintStyle: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                      fillColor: Colors.white.withValues(alpha: .09),
                      prefixIcon: const Icon(Icons.search, color: Colors.white),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  tooltip: highestFirst ? 'Sort by recent' : 'Sort by price',
                  onPressed: () => setState(() => highestFirst = !highestFirst),
                  icon: Icon(
                    highestFirst ? Icons.sort : Icons.filter_alt_outlined,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: RoundPanel(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Handle(),
                  const Text(
                    'History',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: items.isEmpty
                        ? const Center(
                            child: Text(
                              'No rentals found',
                              style: TextStyle(color: C.muted),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: items.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 16),
                            itemBuilder: (context, i) =>
                                RentalCard(rental: items[i]),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RentalCard extends StatelessWidget {
  const RentalCard({super.key, required this.rental});
  final Rental rental;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 54,
          decoration: BoxDecoration(
            color: C.lavender,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('📷', style: TextStyle(fontSize: 20)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rental.camera,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 9),
              _detail(Icons.location_on_outlined, rental.address),
              const SizedBox(height: 9),
              _detail(Icons.schedule, rental.time, small: true),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.payments_outlined, color: C.green, size: 17),
                  const SizedBox(width: 6),
                  Text(
                    money(rental.cents),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _detail(IconData icon, String text, {bool small = false}) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, color: C.muted, size: 16),
      const SizedBox(width: 5),
      Expanded(
        child: Text(
          text,
          style: TextStyle(fontSize: small ? 12 : 13, color: C.muted),
        ),
      ),
    ],
  );
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(),
      confirm = TextEditingController();
  bool initialized = false, busy = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!initialized) {
      final store = StoreScope.of(context);
      name.text = store.name;
      email.text = store.email;
      initialized = true;
    }
  }

  @override
  void dispose() {
    for (final c in [name, email, password, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await StoreScope.of(context).updateProfile(name.text, email.text);
      password.clear();
      confirm.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
        toast(context, 'Profile saved on this device');
      }
    } catch (_) {
      if (mounted) {
        toast(context, 'Could not save your profile. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    index: 3,
    dark: true,
    child: Padding(
      padding: const EdgeInsets.only(top: 36),
      child: SizedBox.expand(
        child: RoundPanel(
          child: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Handle(),
                  const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Start typing your new information',
                    style: TextStyle(color: C.muted, fontSize: 14),
                  ),
                  const SizedBox(height: 30),
                  AppField(
                    controller: name,
                    label: 'NAME',
                    icon: Icons.person_outline,
                    validator: requiredText,
                  ),
                  AppField(
                    controller: email,
                    label: 'EMAIL',
                    icon: Icons.mail_outline,
                    keyboard: TextInputType.emailAddress,
                    validator: emailValidator,
                  ),
                  AppField(
                    controller: password,
                    label: 'NEW PASSWORD',
                    icon: Icons.lock_outline,
                    password: true,
                    validator: (v) =>
                        (v ?? '').isEmpty ? null : passwordValidator(v),
                  ),
                  AppField(
                    controller: confirm,
                    label: 'CONFIRM PASSWORD',
                    icon: Icons.lock_outline,
                    password: true,
                    validator: (v) =>
                        v == password.text ? null : 'Passwords must match',
                  ),
                  const SizedBox(height: 28),
                  PrimaryButton(
                    'Save and Continue',
                    onPressed: busy ? null : save,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
