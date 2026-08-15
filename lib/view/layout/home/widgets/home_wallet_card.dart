import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../wallet/controller/wallet_controller.dart';
import '../../wallet/screen/wallet_screen.dart';

class HomeWalletCard extends StatefulWidget {
  const HomeWalletCard({super.key});

  @override
  State<HomeWalletCard> createState() => _HomeWalletCardState();
}

class _HomeWalletCardState extends State<HomeWalletCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<WalletController>();
      if (controller.wallet == null) controller.getWallet();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WalletController>(
      builder: (context, controller, _) {
        return _WalletContent(balance: controller.wallet?.balance ?? 0);
      },
    );
  }
}

class _WalletContent extends StatelessWidget {
  final double balance;

  const _WalletContent({required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(30, 0, 30, 14),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF151515),
            Color(0xFF252525),
            Color(0xFF0D0D0D),
          ],
          stops: [0, .52, 1],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFF171717), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
          BoxShadow(
            color: Color(0x22FFFFFF),
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: CustomPaint(
          painter: _LeatherWalletPainter(),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _LeatherWalletBadge(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المحفظة',
                        style: AppTextStyle.text15BS().copyWith(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        'الرصيد الحالي',
                        style: AppTextStyle.text12BS().copyWith(
                          color: const Color(0xFFB9B9B9),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            balance.toStringAsFixed(2),
                            style: AppTextStyle.text20BS().copyWith(
                              fontSize: 29,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              'جنيه',
                              style: AppTextStyle.text16MS().copyWith(
                                color: const Color(0xFFD2D2D2),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: _WalletButton(
                              title: 'شحن المحفظة',
                              filled: true,
                              icon: Icons.add_rounded,
                              onTap: () => NamedNavigatorImpl.push(WalletScreen.routeName),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _WalletButton(
                              title: 'تفاصيل المحفظة',
                              filled: false,
                              icon: Icons.receipt_long_outlined,
                              onTap: () => NamedNavigatorImpl.push(WalletScreen.routeName),
                            ),
                          ),
                        ],
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
}

/// Adds a subtle, deterministic natural-leather grain and real-looking
/// orange saddle stitching without requiring an image asset.
class _LeatherWalletPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final texturePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = .65
      ..color = const Color(0xFFB9B9B9).withValues(alpha: .085);

    // Fine irregular grain: short, broken lines spread across the leather.
    for (var i = 0; i < 135; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final length = 2.5 + random.nextDouble() * 7.5;
      final angle = random.nextDouble() * math.pi;
      final end = Offset(
        x + math.cos(angle) * length,
        y + math.sin(angle) * length * .45,
      );
      canvas.drawLine(Offset(x, y), end, texturePaint);
    }

    // Larger natural cracks with a few small branches.
    final crackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1
      ..color = const Color(0xFF000000).withValues(alpha: .28);
    final highlightPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = .55
      ..color = const Color(0xFFD8D8D8).withValues(alpha: .09);

    for (var i = 0; i < 20; i++) {
      final start = Offset(
        8 + random.nextDouble() * (size.width - 16),
        7 + random.nextDouble() * (size.height - 14),
      );
      final angle = random.nextDouble() * math.pi * 2;
      final path = Path()..moveTo(start.dx, start.dy);
      var point = start;

      final segments = 2 + random.nextInt(3);
      for (var s = 0; s < segments; s++) {
        final length = 8 + random.nextDouble() * 15;
        final turn = (random.nextDouble() - .5) * .9;
        final nextAngle = angle + turn + (s * .08);
        point = Offset(
          point.dx + math.cos(nextAngle) * length,
          point.dy + math.sin(nextAngle) * length * .55,
        );
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, crackPaint);

      if (random.nextBool()) {
        final branch = Path()
          ..moveTo(point.dx, point.dy)
          ..lineTo(
            point.dx + (random.nextDouble() - .5) * 20,
            point.dy + (random.nextDouble() - .5) * 13,
          );
        canvas.drawPath(branch, crackPaint);
      }

      canvas.drawPath(
        path.shift(const Offset(.7, .7)),
        highlightPaint,
      );
    }

    _paintStitching(canvas, size);
  }

  void _paintStitching(Canvas canvas, Size size) {
    final stitchPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(5.5, 5.5, size.width - 11, size.height - 11),
          const Radius.circular(20),
        ),
      );

    final stitchPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.5
      ..color = const Color(0xFFFF8A00).withValues(alpha: .9);

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = .65
      ..color = const Color(0xFFFFB04A).withValues(alpha: .45);

    for (final metric in stitchPath.computeMetrics()) {
      var distance = 0.0;
      const stitchLength = 5.0;
      const gap = 4.0;
      while (distance < metric.length) {
        final end = math.min(distance + stitchLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), stitchPaint);
        canvas.drawPath(
          metric.extractPath(distance + .4, math.min(end - .4, metric.length)),
          innerPaint,
        );
        distance += stitchLength + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LeatherWalletBadge extends StatelessWidget {
  const _LeatherWalletBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF191919),
        border: Border.all(color: const Color(0xFF3D3D3D), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
          BoxShadow(
            color: Color(0x22FFFFFF),
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(68, 68),
            painter: _BadgeStitchPainter(),
          ),
          Container(
            width: 48,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E0E),
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: const Color(0xFF5B5B5B), width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 7,
                  offset: Offset(0, 4),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.account_balance_wallet_rounded,
            color: Color(0xFFFF8A00),
            size: 28,
          ),
          Positioned(
            bottom: 12,
            right: 13,
            child: Container(
              width: 9,
              height: 9,
              decoration: const BoxDecoration(
                color: Color(0xFFFFA000),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeStitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addOval(Rect.fromCircle(center: size.center(Offset.zero), radius: 30));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2
      ..color = const Color(0xFFFF8A00).withValues(alpha: .65);

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + 4, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 8;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WalletButton extends StatelessWidget {
  final String title;
  final bool filled;
  final IconData icon;
  final VoidCallback onTap;

  const _WalletButton({
    required this.title,
    required this.filled,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 16),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            maxLines: 1,
            softWrap: false,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: filled ? const Color(0xFFFF7A00) : const Color(0xFF1B1B1B),
          foregroundColor: filled ? Colors.white : const Color(0xFFFFA31A),
          side: BorderSide(
            color: filled ? const Color(0xFFFF7A00) : const Color(0xFF6A6A6A),
            width: 1.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          visualDensity: VisualDensity.compact,
          textStyle: AppTextStyle.text12BS().copyWith(fontSize: 11),
        ),
      ),
    );
  }
}
