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
        height: 228,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.mainAppColor,
              const Color(0xFFFF7A00),
              const Color(0xFFFFB33D),
              const Color(0xFFFFD98A),
            ],
            stops: const [0, .42, .78, 1],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _SeaHeaderPainter())),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 6,
                        child: InkWell(
                          onTap: () => NamedNavigatorImpl.push(SearchScreen.routeName),
                          borderRadius: BorderRadius.circular(18),
                          child: Row(
                            children: [
                              _HeaderIconBox(
                                icon: Icons.search_rounded,
                                onTap: () => NamedNavigatorImpl.push(SearchScreen.routeName),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Text(
                                  'ابحث عن منتج أو فرع ...',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: AppTextStyle.text14BS().copyWith(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'التوصيل إلى',
                                    textDirection: TextDirection.rtl,
                                    style: AppTextStyle.text12BS().copyWith(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    location.isEmpty ? 'اختر العنوان' : location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                    style: AppTextStyle.text12BS().copyWith(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 7),
                            _HeaderIconBox(icon: Icons.location_on_outlined),
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
  Size get preferredSize => const Size.fromHeight(228);
}

class _HeaderIconBox extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _HeaderIconBox({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: 54,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.12),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.mainAppColor, size: 31),
    );
    return onTap == null ? box : GestureDetector(onTap: onTap, child: box);
  }
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
      final y = size.height - 22 - (i.isEven ? 16 : 0);
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
    final sun = Paint()..color = const Color(0xFFFFF2B8).withOpacity(.75);
    canvas.drawCircle(Offset(size.width * .52, 82), 35, sun);

    final glow = Paint()..color = Colors.white.withOpacity(.08);
    canvas.drawCircle(Offset(size.width * .52, 82), 53, glow);

    final mountainBack = Paint()..color = const Color(0xFFFF9A16).withOpacity(.85);
    final back = Path()
      ..moveTo(0, 154)
      ..lineTo(size.width * .13, 100)
      ..lineTo(size.width * .27, 150)
      ..lineTo(size.width * .40, 105)
      ..lineTo(size.width * .54, 153)
      ..lineTo(size.width * .68, 108)
      ..lineTo(size.width * .83, 150)
      ..lineTo(size.width, 96)
      ..lineTo(size.width, 205)
      ..lineTo(0, 205)
      ..close();
    canvas.drawPath(back, mountainBack);

    final mountainFront = Paint()..color = const Color(0xFFE94F00).withOpacity(.9);
    final front = Path()
      ..moveTo(0, 176)
      ..lineTo(size.width * .16, 130)
      ..lineTo(size.width * .29, 177)
      ..lineTo(size.width * .44, 128)
      ..lineTo(size.width * .59, 179)
      ..lineTo(size.width * .75, 133)
      ..lineTo(size.width * .88, 176)
      ..lineTo(size.width, 140)
      ..lineTo(size.width, 220)
      ..lineTo(0, 220)
      ..close();
    canvas.drawPath(front, mountainFront);

    final snow = Paint()..color = Colors.white.withOpacity(.82);
    _drawTriangle(canvas, size.width * .16, 130, 20, snow);
    _drawTriangle(canvas, size.width * .44, 128, 21, snow);
    _drawTriangle(canvas, size.width * .75, 133, 19, snow);

    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(.34);
    final wave = Path()..moveTo(-20, 158);
    wave.cubicTo(size.width * .13, 136, size.width * .24, 170, size.width * .38, 146);
    wave.cubicTo(size.width * .53, 121, size.width * .66, 168, size.width * .81, 140);
    wave.cubicTo(size.width * .90, 125, size.width * .97, 147, size.width + 20, 128);
    canvas.drawPath(wave, wavePaint);

    final fishPaint = Paint()..color = const Color(0xFFD84A00).withOpacity(.48);
    _drawFish(canvas, Offset(size.width * .51, 54), 34, fishPaint, rotation: -.08);
    _drawFish(canvas, Offset(size.width * .27, 83), 16, fishPaint, rotation: .12);
    _drawFish(canvas, Offset(size.width * .84, 94), 13, fishPaint, rotation: .04);

    final bubblePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white.withOpacity(.65);
    for (final item in [
      (size.width * .40, 35, 5.0),
      (size.width * .48, 20, 3.0),
      (size.width * .60, 43, 4.0),
      (size.width * .64, 25, 2.0),
    ]) {
      canvas.drawCircle(Offset(item.$1, item.$2), item.$3, bubblePaint);
    }

    final birdPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF8B3A00).withOpacity(.55);
    _drawBird(canvas, Offset(size.width * .30, 65), 8, birdPaint);
    _drawBird(canvas, Offset(size.width * .70, 70), 7, birdPaint);
  }

  void _drawTriangle(Canvas canvas, double x, double y, double h, Paint paint) {
    final path = Path()
      ..moveTo(x, y)
      ..lineTo(x - h, y + h * 1.8)
      ..lineTo(x + h, y + h * 1.8)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawFish(Canvas canvas, Offset center, double length, Paint paint, {double rotation = 0}) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    final body = Path()
      ..moveTo(-length, 0)
      ..quadraticBezierTo(-length * .25, -length * .48, length * .48, 0)
      ..quadraticBezierTo(-length * .25, length * .48, -length, 0)
      ..close();
    canvas.drawPath(body, paint);
    final tail = Path()
      ..moveTo(length * .38, 0)
      ..lineTo(length, -length * .38)
      ..lineTo(length * .88, 0)
      ..lineTo(length, length * .38)
      ..close();
    canvas.drawPath(tail, paint);
    canvas.restore();
  }

  void _drawBird(Canvas canvas, Offset center, double width, Paint paint) {
    final path = Path()
      ..moveTo(center.dx - width, center.dy)
      ..quadraticBezierTo(center.dx - width * .45, center.dy - width * .5, center.dx, center.dy)
      ..quadraticBezierTo(center.dx + width * .45, center.dy - width * .5, center.dx + width, center.dy);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SeaHeaderPainter oldDelegate) => false;
}
