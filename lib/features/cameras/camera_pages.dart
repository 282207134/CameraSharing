import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/models.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.specifications = false});
  final bool specifications;
  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return PageFrame(
      child: LayoutBuilder(
        builder: (context, box) => Stack(
          children: [
            const Positioned.fill(child: MapBackground()),
            if (!specifications) ...[
              Positioned(
                top: 10,
                left: 0,
                right: 0,
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 104,
                    height: 36,
                  ),
                ),
              ),
              ...List.generate(
                3,
                (i) => Positioned(
                  left: box.maxWidth * [.14, .8, .1][i],
                  top: box.maxHeight * [.15, .1, .41][i],
                  child: Semantics(
                    label: 'Select ${cameras[i].name}',
                    button: true,
                    child: GestureDetector(
                      onTap: () => store.selectCamera(i),
                      child: const CameraPin(),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: box.maxHeight * .33,
                left: box.maxWidth * .5,
                child: const LocationDot(),
              ),
              Positioned(
                right: 28,
                bottom: box.maxHeight * .43 + 18,
                child: FloatingActionButton.small(
                  heroTag: 'locate',
                  tooltip: 'Find nearest camera',
                  backgroundColor: Colors.white,
                  elevation: 0,
                  onPressed: () {
                    store.selectCamera(0);
                    toast(context, 'Showing cameras near your demo location');
                  },
                  child: const Icon(Icons.my_location, color: C.purple),
                ),
              ),
            ],
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height:
                    (box.maxHeight *
                            (specifications
                                ? .92
                                : store.activeCamera != null
                                ? .57
                                : .43))
                        .clamp(
                          store.activeCamera != null ? 400.0 : 300.0,
                          box.maxHeight,
                        ),
                child: RoundPanel(
                  color: C.navy,
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      const Handle(dark: true),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: CameraSummary(
                          onDetails: specifications
                              ? () => Navigator.pop(context)
                              : () => go(context, '/specification'),
                        ),
                      ),
                      const SizedBox(height: 22),
                      Padding(
                        padding: const EdgeInsets.only(left: 95, right: 28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () => go(context, '/photos'),
                              child: Text(
                                specifications ? 'Photos' : 'Camera Photos',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            GestureDetector(
                              onTap: () => go(context, '/photos'),
                              child: Row(
                                children: List.generate(
                                  4,
                                  (i) => Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: i < 3 ? 10 : 0,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: AspectRatio(
                                          aspectRatio: 1,
                                          child: Image.asset(
                                            'assets/images/camera-${i + 1}.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (specifications) ...[
                        const SizedBox(height: 28),
                        Expanded(
                          child: RoundPanel(
                            child: SingleChildScrollView(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Handle(),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(
                                      Icons.info_outline,
                                      color: C.purple,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ...[
                                    '24.2 Mega Pixels CMOS',
                                    'Easily connect and share WI-FI/NFC',
                                    'Up to 5.0 frames per second',
                                    'Hybrid CMOS AF III',
                                    'Various angle LCD (for multi view)',
                                    'EOS movie full HD up to 1080p',
                                  ].asMap().entries.map(
                                    (e) => Padding(
                                      padding: const EdgeInsets.only(
                                        left: 66,
                                        bottom: 22,
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 6,
                                            ),
                                            child: Icon(
                                              Icons.circle,
                                              size: 8,
                                              color: [
                                                Colors.amber,
                                                Colors.redAccent,
                                                Colors.indigo,
                                                Colors.blue,
                                                Colors.indigo,
                                                Colors.indigo,
                                              ][e.key],
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              e.value,
                                              style: const TextStyle(
                                                color: C.muted,
                                                fontSize: 14,
                                              ),
                                            ),
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
                      ] else ...[
                        const Spacer(),
                        if (store.activeCamera != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(28, 12, 28, 18),
                            child: PrimaryButton(
                              'Return ${store.activeCamera!.name}',
                              color: C.green,
                              icon: Icons.check_circle_outline,
                              onPressed: () async {
                                await store.finishRental();
                                if (context.mounted) {
                                  toast(
                                    context,
                                    'Camera returned · ${money(410)} charged',
                                  );
                                  tab(context, '/history');
                                }
                              },
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CameraSummary extends StatelessWidget {
  const CameraSummary({super.key, required this.onDetails});
  final VoidCallback onDetails;
  @override
  Widget build(BuildContext context) {
    final camera = StoreScope.of(context).camera;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onDetails,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: .08),
            ),
            child: const Icon(Icons.circle, color: Colors.white, size: 14),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onDetails,
                child: Text(
                  camera.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: C.muted,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      camera.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: C.muted, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${camera.distance} distance   |   ${camera.minutes} min',
                      style: const TextStyle(
                        color: C.muted,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 48,
                    height: 32,
                    child: IconButton(
                      tooltip: 'Route to Store',
                      padding: EdgeInsets.zero,
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => go(context, '/route'),
                      icon: const Icon(
                        Icons.alt_route_rounded,
                        color: C.purple,
                        size: 21,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class MapBackground extends StatelessWidget {
  const MapBackground({super.key});
  @override
  Widget build(BuildContext context) => ClipRect(
    child: OverflowBox(
      maxHeight: double.infinity,
      alignment: Alignment.topCenter,
      child: Image.asset(
        'assets/images/map.png',
        width: MediaQuery.sizeOf(context).width * 1.18,
        fit: BoxFit.fitWidth,
        alignment: Alignment.topCenter,
      ),
    ),
  );
}

class CameraPin extends StatelessWidget {
  const CameraPin({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 36,
    height: 44,
    child: Stack(
      alignment: Alignment.topCenter,
      children: [
        const Positioned(
          bottom: 0,
          child: Icon(Icons.arrow_drop_down, color: C.purple, size: 36),
        ),
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: C.purple, width: 3),
          ),
          child: const Center(
            child: Text('📷', style: TextStyle(fontSize: 17)),
          ),
        ),
      ],
    ),
  );
}

class LocationDot extends StatelessWidget {
  const LocationDot({super.key});
  @override
  Widget build(BuildContext context) => Container(
    width: 56,
    height: 56,
    decoration: BoxDecoration(
      color: C.purple.withValues(alpha: .07),
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: C.purple.withValues(alpha: .12),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.circle, color: C.purple, size: 15),
      ),
    ),
  );
}

class RoutePage extends StatelessWidget {
  const RoutePage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    child: LayoutBuilder(
      builder: (context, box) => Stack(
        children: [
          const Positioned.fill(child: MapBackground()),
          const PageHeader('Route to Store'),
          Positioned(
            left: box.maxWidth * .32,
            top: 90,
            width: box.maxWidth * .53,
            height: box.maxHeight * .37,
            child: CustomPaint(painter: RoutePainter()),
          ),
          Positioned(
            left: box.maxWidth * .29,
            top: 90,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                color: C.purple,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                '4 min',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: RoundPanel(
              color: C.navy,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Handle(dark: true),
                  ...['YOUR LOCATION', 'STORE LOCATION'].asMap().entries.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 22),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.radio_button_checked,
                            color: C.purple,
                            size: 17,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  e.value,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: C.muted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  e.key == 0
                                      ? 'RX Bekari, Rikabibazar, Sylhet'
                                      : StoreScope.of(context).camera.address,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PrimaryButton(
                    'Scan to unlock',
                    color: C.green,
                    icon: Icons.qr_code_scanner,
                    onPressed: () => go(context, '/scan'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(0, 35)
      ..lineTo(size.width * .55, 35)
      ..lineTo(size.width * .44, size.height * .87)
      ..lineTo(size.width * .88, size.height * .95);
    canvas.drawPath(
      path,
      Paint()
        ..color = C.purple
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke,
    );
    for (final offset in [
      const Offset(0, 35),
      Offset(size.width * .88, size.height * .95),
    ]) {
      canvas.drawCircle(offset, 7, Paint()..color = C.purple);
      canvas.drawCircle(offset, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant RoutePainter oldDelegate) => false;
}

class PhotosPage extends StatelessWidget {
  const PhotosPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    dark: true,
    child: Padding(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Handle(dark: true),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Camera Photos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              IconButton(
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Expanded(
            child: SingleChildScrollView(
              child: Semantics(
                label: 'Camera photo collection',
                image: true,
                child: Image.asset(
                  'assets/images/photo-grid.png',
                  width: double.infinity,
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
