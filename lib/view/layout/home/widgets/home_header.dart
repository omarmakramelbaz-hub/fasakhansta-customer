import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../auth/controller/auth_controller.dart';
import '../../search/screen/search_screen.dart';
import '../controller/home_controller.dart';

class HomeHeader extends StatelessWidget implements PreferredSizeWidget {
  final HomeController controller;

  const HomeHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<AuthController>().profile;
    final address = profile?.userAddresses?.isNotEmpty == true
        ? profile!.userAddresses!.first
        : null;
    final location = [address?.streetName, address?.cityName]
        .where((value) => value != null && value.trim().isNotEmpty)
        .join(' - ');

    return ClipPath(
      clipper: const _SeaHeaderClipper(),
      child: Container(
        height: 214,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF7A00),
              Color(0xFFFF8D00),
              Color(0xFFFFB12B),
              Color(0xFFFFD36A),
            ],
            stops: [0, .38, .72, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _SeaHeaderPainter())),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 22),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SearchButton(
                        onTap: () => NamedNavigatorImpl.push(SearchScreen.routeName),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Text(
                            'ابحث عن منتج أو فرع ...',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: AppTextStyle.text12BS().copyWith(
                              color: Colors.white,
                              fontSize: 12,
                              shadows: const [
                                Shadow(
                                  color: Color(0x55000000),
                                  blurRadius: 4,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        flex: 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.keyboard_arrow_down_rounded,
                                          color: Colors.white,
                                          size: 17,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          'التوصيل إلى',
                                          textDirection: TextDirection.rtl,
                                          style: AppTextStyle.text12BS().copyWith(
                                            color: Colors.white,
                                            fontSize: 11,
                                            shadows: const [
                                              Shadow(
                                                color: Color(0x55000000),
                                                blurRadius: 4,
                                                offset: Offset(0, 1),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      location.isEmpty ? 'اختر العنوان' : location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      style: AppTextStyle.text12BS().copyWith(
                                        color: Colors.white,
                                        fontSize: 10.5,
                                        shadows: const [
                                          Shadow(
                                            color: Color(0x55000000),
                                            blurRadius: 4,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 7),
                            const _LocationButton(),
                          ],
                        ),
                      ),
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

  @override
  Size get preferredSize => const Size.fromHeight(214);
}

class _SearchButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SearchButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
            BoxShadow(
              color: Color(0x66FFFFFF),
              blurRadius: 2,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Icon(
          Icons.search_rounded,
          color: AppColors.mainAppColor,
          size: 29,
        ),
      ),
    );
  }
}

class _LocationButton extends StatelessWidget {
  const _LocationButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x66FFFFFF),
            blurRadius: 2,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: Icon(
        Icons.location_on_outlined,
        color: AppColors.mainAppColor,
        size: 29,
      ),
    );
  }
}

class _SeaHeaderClipper extends CustomClipper<Path> {
  const _SeaHeaderClipper();

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 24);

    final wave = Path();
    wave.moveTo(size.width, size.height - 24);
    wave.cubicTo(
      size.width * .88,
      size.height - 8,
      size.width * .74,
      size.height - 34,
      size.width * .58,
      size.height - 18,
    );
    wave.cubicTo(
      size.width * .43,
      size.height - 2,
      size.width * .27,
      size.height - 35,
      0,
      size.height - 13,
    );
    path.addPath(wave, Offset.zero);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SeaHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .52, 76);

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(.28),
          Colors.white.withOpacity(.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 72));
    canvas.drawCircle(center, 72, glow);

    final sun = Paint()..color = const Color(0xFFFFF2C2).withOpacity(.78);
    canvas.drawCircle(center, 34, sun);

    final horizon = Paint()..color = const Color(0xFFFF9A16).withOpacity(.56);
    final horizonPath = Path()
      ..moveTo(0, 138)
      ..quadraticBezierTo(size.width * .12, 114, size.width * .24, 138)
      ..quadraticBezierTo(size.width * .38, 162, size.width * .52, 134)
      ..quadraticBezierTo(size.width * .67, 107, size.width * .82, 136)
      ..quadraticBezierTo(size.width * .92, 155, size.width, 126)
      ..lineTo(size.width, 214)
      ..lineTo(0, 214)
      ..close();
    canvas.drawPath(horizonPath, horizon);

    final deepLayer = Paint()..color = const Color(0xFFE95300).withOpacity(.34);
    final deepPath = Path()
      ..moveTo(0, 171)
      ..quadraticBezierTo(size.width * .18, 139, size.width * .35, 171)
      ..quadraticBezierTo(size.width * .51, 199, size.width * .67, 166)
      ..quadraticBezierTo(size.width * .83, 139, size.width, 168)
      ..lineTo(size.width, 214)
      ..lineTo(0, 214)
      ..close();
    canvas.drawPath(deepPath, deepLayer);

    _drawWave(
      canvas,
      size,
      y: 148,
      amplitude: 9,
      color: Colors.white.withOpacity(.28),
      width: 1.8,
    );
    _drawWave(
      canvas,
      size,
      y: 170,
      amplitude: 7,
      color: Colors.white.withOpacity(.16),
      width: 1.5,
    );
    _drawWave(
      canvas,
      size,
      y: 190,
      amplitude: 6,
      color: const Color(0xFFFFFFFF).withOpacity(.13),
      width: 1.3,
    );

    final fishPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..color = const Color(0xFFC84A00).withOpacity(.43);
    _drawFish(canvas, Offset(size.width * .52, 53), 27, fishPaint, rotation: -.08);
    _drawFish(canvas, Offset(size.width * .22, 86), 13, fishPaint, rotation: .12);
    _drawFish(canvas, Offset(size.width * .84, 91), 11, fishPaint, rotation: -.06);

    final bubblePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = Colors.white.withOpacity(.48);
    final bubbles = [
      (size.width * .40, 34.0, 4.5),
      (size.width * .47, 20.0, 2.5),
      (size.width * .61, 42.0, 4.0),
      (size.width * .66, 27.0, 2.0),
      (size.width * .79, 52.0, 2.8),
    ];
    for (final bubble in bubbles) {
      canvas.drawCircle(Offset(bubble.$1, bubble.$2), bubble.$3, bubblePaint);
    }

    final birdPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8B3A00).withOpacity(.45);
    _drawBird(canvas, Offset(size.width * .31, 66), 7, birdPaint);
    _drawBird(canvas, Offset(size.width * .70, 70), 6, birdPaint);
  }

  void _drawWave(
    Canvas canvas,
    Size size, {
    required double y,
    required double amplitude,
    required Color color,
    required double width,
  }) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;

    final path = Path()..moveTo(-20, y);
    final period = size.width / 2.6;
    for (var x = -20.0; x <= size.width + 20; x += period) {
      path.cubicTo(
        x + period * .20,
        y - amplitude,
        x + period * .30,
        y - amplitude,
        x + period * .50,
        y,
      );
      path.cubicTo(
        x + period * .70,
        y + amplitude,
        x + period * .80,
        y + amplitude,
        x + period,
        y,
      );
    }
    canvas.drawPath(path, paint);
  }

  void _drawFish(
    Canvas canvas,
    Offset center,
    double length,
    Paint paint, {
    double rotation = 0,
  }) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);

    final body = Path()
      ..moveTo(-length, 0)
      ..quadraticBezierTo(-length * .28, -length * .48, length * .48, 0)
      ..quadraticBezierTo(-length * .28, length * .48, -length, 0)
      ..close();
    canvas.drawPath(body, paint);

    final tail = Path()
      ..moveTo(length * .38, 0)
      ..lineTo(length, -length * .38)
      ..lineTo(length * .86, 0)
      ..lineTo(length, length * .38)
      ..close();
    canvas.drawPath(tail, paint);

    canvas.drawCircle(Offset(-length * .55, -length * .06), 1.4, paint);
    canvas.restore();
  }

  void _drawBird(Canvas canvas, Offset center, double width, Paint paint) {
    final path = Path()
      ..moveTo(center.dx - width, center.dy)
      ..quadraticBezierTo(
        center.dx - width * .45,
        center.dy - width * .5,
        center.dx,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + width * .45,
        center.dy - width * .5,
        center.dx + width,
        center.dy,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SeaHeaderPainter oldDelegate) => false;
}
