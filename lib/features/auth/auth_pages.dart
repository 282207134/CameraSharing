import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    navigation: false,
    child: FillScroll(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 30, 28, 44),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Image.asset(
              'assets/images/welcome-camera.png',
              width: 260,
              height: 260,
            ),
            const SizedBox(height: 64),
            const Text(
              'Welcome To Camshare',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 24),
            const Text(
              'Please turn on your GPS so that we can find your nearest camera store and provide you an overall better experience.',
              textAlign: TextAlign.center,
              style: TextStyle(color: C.muted, fontSize: 15, height: 1.65),
            ),
            const SizedBox(height: 32),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.circle, size: 6, color: Colors.black26),
                SizedBox(width: 10),
                Icon(Icons.circle, size: 7, color: C.purple),
                SizedBox(width: 10),
                Icon(Icons.circle, size: 6, color: Colors.black26),
              ],
            ),
            const Spacer(flex: 3),
            const SizedBox(height: 40),
            PrimaryButton(
              'Let’s Get Started',
              onPressed: () => go(context, '/signup'),
            ),
          ],
        ),
      ),
    ),
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key, this.signUp = false});
  final bool signUp;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(),
      confirm = TextEditingController();
  bool busy = false;
  @override
  void dispose() {
    for (final c in [name, email, password, confirm]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await StoreScope.of(
        context,
      ).signIn(email.text, userName: widget.signUp ? name.text : null);
      if (mounted) tab(context, '/home');
    } catch (_) {
      if (mounted) {
        toast(context, 'Could not save your profile. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> socialDemo() async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Try Camshare'),
        content: const Text(
          'Social sign-in is not connected in this preview. Continue with a local demo profile?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Try demo'),
          ),
        ],
      ),
    );
    if (accepted == true && mounted) {
      await StoreScope.of(context).signIn('demo@camshare.app');
      if (mounted) tab(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.signUp ? 'Sign Up' : 'Log In';
    return PageFrame(
      navigation: false,
      child: FillScroll(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 32),
          child: Form(
            key: form,
            child: Column(
              children: [
                Image.asset('assets/images/logo.png', width: 124, height: 40),
                SizedBox(height: widget.signUp ? 38 : 84),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 26),
                if (widget.signUp)
                  AppField(
                    controller: name,
                    label: 'User name',
                    icon: Icons.person_outline,
                    validator: requiredText,
                  ),
                AppField(
                  controller: email,
                  label: 'Email address',
                  icon: Icons.mail_outline,
                  keyboard: TextInputType.emailAddress,
                  validator: emailValidator,
                ),
                AppField(
                  controller: password,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  password: true,
                  validator: passwordValidator,
                ),
                if (widget.signUp)
                  AppField(
                    controller: confirm,
                    label: 'Confirm password',
                    icon: Icons.lock_outline,
                    password: true,
                    validator: (v) =>
                        v == password.text ? null : 'Passwords must match',
                  ),
                if (!widget.signUp)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Demo account'),
                          content: const Text(
                            'This preview uses local profiles. Enter any valid email and a password with at least 6 characters to continue.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Got it'),
                            ),
                          ],
                        ),
                      ),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(fontSize: 13, color: C.muted),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                PrimaryButton(
                  busy ? 'Please wait…' : title,
                  onPressed: busy ? null : submit,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () =>
                      go(context, widget.signUp ? '/login' : '/signup'),
                  child: Text(
                    widget.signUp
                        ? 'Already have an account? Log In'
                        : 'Don’t have an account? Sign Up',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const Spacer(),
                const SizedBox(height: 38),
                PrimaryButton(
                  'Continue With Facebook',
                  color: const Color(0xFF4267A9),
                  icon: Icons.facebook,
                  onPressed: socialDemo,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  height: 55,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: socialDemo,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E4EA)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'G',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text(
                          'Continue With Google',
                          style: TextStyle(color: C.muted, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
