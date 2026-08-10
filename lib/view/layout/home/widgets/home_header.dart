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
        height: 218,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.mainAppColor,
              AppColors.mainAppColor.withOpacity(.88),
              const Color(0xFFFFB84D),
              const Color(0xFFFFD58A),
            ],
            stops: const [0, .34, .72, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _SeaHeaderPainter())),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => NamedNavigatorImpl.push(SearchScreen.routeName),
                            borderRadius: BorderRadius.circular(28),
                            child: Container(
                              height: 54,
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.13),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.search_rounded, size: 27, color: Colors.black87),
                                  const SizedBox(width: 9),
                                  Expanded(
                                    child: Text(
                                      'ابحث عن منتج أو فرع ...',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      style: AppTextStyle.text14BS().copyWith(
                                        color: Colors.black54,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.96),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(.12),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.mainAppColor,
                            size: 29,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'التوصيل إلى',
                                  style: AppTextStyle.text12BS().copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  location.isEmpty ? 'اختر العنوان' : location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.end,
                                  style: AppTextStyle.text12BS().copyWith(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 7),
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 29,
                          ),
                          const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 21,
                          ),
                        ],
                      ),
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

  @override
  Size get preferredSize => const Size.fromHeight(218);
}

class _SeaHeaderClipper extends CustomClipper<Path> {
  const _SeaHeaderClipper();

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 22);
    const points = 10;
    final step = size.width / points;
    for (var i = points - 1; i >= 0; i--) {
      final x = i * step;
      final y = size.height - 22 - (i.isEven ? 15 : 0);
      path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SeaHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final sunPaint = Paint()..color = Colors.white.withOpacity(.22);
    canvas.drawCircle(Offset(size.width * .77, 48), 31, sunPaint);

    final softSun = Paint()..color = Colors.white.withOpacity(.08);
    canvas.drawCircle(Offset(size.width * .77, 48), 48, softSun);

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = Colors.white.withOpacity(.30);

    final wave = Path()..moveTo(-25, 135);
    wave.cubicTo(size.width * .12, 108, size.width * .23, 151, size.width * .38, 126);
    wave.cubicTo(size.width * .53, 101, size.width * .66, 151, size.width * .80, 122);
    wave.cubicTo(size.width * .90, 102, size.width * .98, 127, size.width + 25, 108);
    canvas.drawPath(wave, wavePaint);

    final wave2 = Path()..moveTo(-15, 157);
    wave2.cubicTo(size.width * .16, 133, size.width * .30, 171, size.width * .47, 145);
    wave2.cubicTo(size.width * .62, 120, size.width * .75, 169, size.width + 20, 136);
    canvas.drawPath(wave2, wavePaint..strokeWidth = 3.2);

    final foamPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity(.34);
    for (var i = 0; i < 6; i++) {
      canvas.drawCircle(
        Offset(size.width * (.10 + i * .14), 171 + (i.isEven ? 4 : -2)),
        2.5 + (i % 2),
        foamPaint,
      );
    }

    final fishPaint = Paint()..color = Colors.white.withOpacity(.18);
    _drawFish(canvas, Offset(size.width * .23, 86), 36, fishPaint, rotation: -.35);
    _drawFish(canvas, Offset(size.width * .60, 72), 23, fishPaint, rotation: .18);

    final birdPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withOpacity(.65);
    _drawBird(canvas, Offset(size.width * .34, 45), 12, birdPaint);
    _drawBird(canvas, Offset(size.width * .48, 30), 8, birdPaint);

    final boatPaint = Paint()..color = Colors.black.withOpacity(.12);
    final boatY = size.height - 45;
    final boat = Path()
      ..moveTo(size.width * .80, boatY)
      ..lineTo(size.width * .89, boatY)
      ..lineTo(size.width * .87, boatY + 6)
      ..lineTo(size.width * .82, boatY + 6)
      ..close();
    canvas.drawPath(boat, boatPaint);
    canvas.drawRect(
      Rect.fromLTWH(size.width * .845, boatY - 15, 1.5, 15),
      boatPaint,
    );
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
    final body = Path();
    body.moveTo(-length, 0);
    body.quadraticBezierTo(-length * .35, -length * .55, length * .45, 0);
    body.quadraticBezierTo(-length * .35, length * .55, -length, 0);
    body.close();
    canvas.drawPath(body, paint);

    final tail = Path()
      ..moveTo(length * .40, 0)
      ..lineTo(length, -length * .40)
      ..lineTo(length * .88, 0)
      ..lineTo(length, length * .40)
      ..close();
    canvas.drawPath(tail, paint);
    canvas.restore();
  }

  void _drawBird(Canvas canvas, Offset center, double width, Paint paint) {
    final bird = Path()
      ..moveTo(center.dx - width, center.dy)
      ..quadraticBezierTo(center.dx - width * .45, center.dy - width * .55, center.dx, center.dy)
      ..quadraticBezierTo(center.dx + width * .45, center.dy - width * .55, center.dx + width, center.dy);
    canvas.drawPath(bird, paint);
  }

  @override
  bool shouldRepaint(covariant _SeaHeaderPainter oldDelegate) => false;
}
