import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';

class ScanPage extends StatelessWidget {
  const ScanPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    dark: true,
    child: Padding(
      padding: const EdgeInsets.only(top: 36),
      child: RoundPanel(
        child: FillScroll(
          child: Column(
            children: [
              const Handle(),
              const SizedBox(height: 16),
              const Text(
                'Scan QR Code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              const Text(
                'Align QR code within the frame to scan the right side of the camera',
                textAlign: TextAlign.center,
                style: TextStyle(color: C.muted, fontSize: 14, height: 1.6),
              ),
              const Spacer(),
              const SizedBox(height: 36),
              GestureDetector(
                onTap: () => go(context, '/code', arguments: '5712'),
                child: Semantics(
                  label: 'Scan demo camera code',
                  button: true,
                  child: SizedBox(
                    width: 238,
                    height: 238,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.asset('assets/images/qr.png', width: 200),
                        const Positioned.fill(
                          child: CustomPaint(painter: ScanPainter()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              const SizedBox(height: 24),
              const Text(
                'Scanning Code…',
                style: TextStyle(color: C.muted, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              const SizedBox(height: 36),
              PrimaryButton(
                'Put Camera Code',
                onPressed: () => go(context, '/code'),
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    ),
  );
}

class ScanPainter extends CustomPainter {
  const ScanPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = C.purple
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final x in [0.0, size.width]) {
      for (final y in [0.0, size.height]) {
        canvas.drawPath(
          Path()
            ..moveTo(x == 0 ? 12 : x - 12, y)
            ..lineTo(x, y)
            ..lineTo(x, y == 0 ? 12 : y - 12),
          paint,
        );
      }
    }
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * .55)
        ..quadraticBezierTo(
          size.width / 2,
          size.height * .36,
          size.width,
          size.height * .55,
        ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant ScanPainter oldDelegate) => false;
}

class CodePage extends StatefulWidget {
  const CodePage({super.key, this.initial = ''});
  final String initial;
  @override
  State<CodePage> createState() => _CodePageState();
}

class _CodePageState extends State<CodePage> {
  late String code = widget.initial;
  bool busy = false;
  Future<void> unlock() async {
    setState(() => busy = true);
    final store = StoreScope.of(context);
    try {
      final unlocked = await store.unlock(code);
      if (!mounted) return;
      if (unlocked) {
        tab(context, '/home');
        toast(context, '${store.camera.name} unlocked · Return it from Home');
      } else {
        toast(
          context,
          store.activeCamera != null
              ? 'Return your current camera first'
              : 'At least \$4.10 balance is required',
        );
      }
    } catch (_) {
      if (mounted) {
        toast(context, 'Could not save the rental. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    dark: true,
    child: Padding(
      padding: const EdgeInsets.only(top: 36),
      child: FillScroll(
        child: RoundPanel(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              const Handle(),
              const SizedBox(height: 16),
              const Text(
                'Put Camera Code',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter the number under the QR code',
                style: TextStyle(fontSize: 14, color: C.muted),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  height: 72,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      ...List.generate(
                        4,
                        (i) => Expanded(
                          child: Center(
                            child: Text(
                              i < code.length ? code[i] : '•',
                              key: ValueKey('code-digit-$i'),
                              style: TextStyle(
                                fontSize: 27,
                                color: i < code.length
                                    ? C.text
                                    : Colors.black26,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Clear camera code',
                        onPressed: () => setState(() => code = ''),
                        icon: const Icon(Icons.restart_alt, color: C.purple),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              RoundPanel(
                color: C.navy,
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 28),
                child: Column(
                  children: [
                    SizedBox(
                      height:
                          (MediaQuery.sizeOf(context).width - 56) / 3 / 1.9 * 4,
                      child: GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.9,
                        children: [
                          ...List.generate(
                            9,
                            (i) => TextButton(
                              key: ValueKey('key-${i + 1}'),
                              onPressed: () {
                                if (code.length < 4) {
                                  setState(() => code += '${i + 1}');
                                }
                              },
                              child: Text(
                                '${i + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(),
                          TextButton(
                            key: const ValueKey('key-0'),
                            onPressed: () {
                              if (code.length < 4) {
                                setState(() => code += '0');
                              }
                            },
                            child: const Text(
                              '0',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Delete digit',
                            onPressed: () {
                              if (code.isNotEmpty) {
                                setState(
                                  () =>
                                      code = code.substring(0, code.length - 1),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.backspace_outlined,
                              size: 22,
                              color: C.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      'Unlock Camera',
                      color: C.green,
                      icon: Icons.lock_open_outlined,
                      onPressed: code.length == 4 && !busy ? unlock : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
