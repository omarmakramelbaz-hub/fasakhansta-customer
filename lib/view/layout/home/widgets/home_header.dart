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
        height: 176,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.mainAppColor,
              AppColors.mainAppColor.withOpacity(.92),
              AppColors.mainAppColor.withOpacity(.82),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SeaHeaderPainter(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 38, 16, 28),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: InkWell(
                      onTap: () => NamedNavigatorImpl.push(SearchScreen.routeName),
                      borderRadius: BorderRadius.circular(22),
                      child: Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(.10),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.search_rounded,
                              size: 34,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'ابحث عن منتج أو فرع ...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
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
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 5,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'التوصيل إلى',
                                style: AppTextStyle.text12BS().copyWith(color: Colors.white),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                location.isEmpty ? 'اختر العنوان' : location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                                style: AppTextStyle.text12BS().copyWith(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.white,
                          size: 38,
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
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(176);
}

class _SeaHeaderClipper extends CustomClipper<Path> {
  const _SeaHeaderClipper();

  @override
  Path getClip(Size size) {
    final path = Path()..moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height - 18);
    const points = 9;
    final step = size.width / points;
    for (var i = points - 1; i >= 0; i--) {
      final x = i * step;
      final y = size.height - 18 - (i.isEven ? 13 : 0);
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
    final wavePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withOpacity(.22);

    final wave = Path()..moveTo(-20, 105);
    wave.cubicTo(size.width * .12, 82, size.width * .23, 124, size.width * .38, 98);
    wave.cubicTo(size.width * .52, 73, size.width * .63, 119, size.width * .78, 92);
    wave.cubicTo(size.width * .88, 75, size.width * .96, 98, size.width + 20, 80);
    canvas.drawPath(wave, wavePaint);

    final wave2 = Path()..moveTo(-10, 126);
    wave2.cubicTo(size.width * .18, 105, size.width * .30, 138, size.width * .47, 113);
    wave2.cubicTo(size.width * .62, 92, size.width * .72, 137, size.width + 15, 105);
    canvas.drawPath(wave2, wavePaint..strokeWidth = 3);

    final fishPaint = Paint()..color = Colors.white.withOpacity(.10);
    _drawFish(canvas, Offset(size.width * .18, 70), 42, fishPaint);
    _drawFish(canvas, Offset(size.width * .70, 52), 24, fishPaint);
    _drawFish(canvas, Offset(size.width * .87, 82), 18, fishPaint);

    final bubblePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = Colors.white.withOpacity(.34);
    canvas.drawCircle(Offset(size.width * .60, 48), 5, bubblePaint);
    canvas.drawCircle(Offset(size.width * .63, 37), 3, bubblePaint);
    canvas.drawCircle(Offset(size.width * .65, 58), 2, bubblePaint);
  }

  void _drawFish(Canvas canvas, Offset center, double length, Paint paint) {
    final body = Path();
    body.moveTo(center.dx - length, center.dy);
    body.quadraticBezierTo(center.dx - length * .35, center.dy - length * .55, center.dx + length * .45, center.dy);
    body.quadraticBezierTo(center.dx - length * .35, center.dy + length * .55, center.dx - length, center.dy);
    body.close();
    canvas.drawPath(body, paint);

    final tail = Path()
      ..moveTo(center.dx + length * .40, center.dy)
      ..lineTo(center.dx + length, center.dy - length * .40)
      ..lineTo(center.dx + length * .88, center.dy)
      ..lineTo(center.dx + length, center.dy + length * .40)
      ..close();
    canvas.drawPath(tail, paint);
  }

  @override
  bool shouldRepaint(covariant _SeaHeaderPainter oldDelegate) => false;
}
