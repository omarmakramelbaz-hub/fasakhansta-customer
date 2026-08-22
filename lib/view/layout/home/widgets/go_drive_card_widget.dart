import 'package:flutter/material.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/hive/hive_methods.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../request_delegate/screen/request_delegate_screen.dart';
import '../controller/home_controller.dart';

class GoDriveCardWidget extends StatelessWidget {
  final HomeController controller;

  const GoDriveCardWidget({super.key, required this.controller});

  void _openRequestDelegate(BuildContext context) {
    if (HiveMethods.getToken() == null) {
      CommonMethods.showError(message: 'youMustLoginFirst'.tr);
      return;
    }
    Navigator.of(context).pushNamed(RequestDelegateScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 16),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openRequestDelegate(context),
        child: Container(
          height: 210,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.mainAppColor.withValues(alpha: .52),
              width: 1.15,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF102033).withValues(alpha: .07),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned(
                left: -36,
                top: -48,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.mainAppColor.withValues(alpha: .035),
                  ),
                ),
              ),
              Row(
                textDirection: TextDirection.ltr,
                children: [
                  Expanded(
                    flex: 59,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 8, 13),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.mainAppColor,
                                      const Color(0xFFFF8A1F),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.mainAppColor
                                          .withValues(alpha: .20),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  'جديد',
                                  style: AppTextStyle.text11BS().copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              8.sbW,
                              Expanded(
                                child: Text(
                                  'Go Drive',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTextStyle.text18BS().copyWith(
                                    color: const Color(0xFF102033),
                                    fontSize: 22,
                                    letterSpacing: -.25,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          3.sbH,
                          Text(
                            'خدمة توصيل',
                            style: AppTextStyle.text16BS().copyWith(
                              color: AppColors.mainAppColor,
                              fontSize: 18,
                            ),
                          ),
                          5.sbH,
                          Text(
                            'اطلب مندوب في أي وقت ومن أي مكان',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.text12MS().copyWith(
                              color: const Color(0xFF747A82),
                              height: 1.35,
                            ),
                          ),
                          const Spacer(),
                          const Row(
                            children: [
                              _FeatureChip(
                                icon: Icons.bolt_rounded,
                                label: 'سريع',
                              ),
                              SizedBox(width: 5),
                              _FeatureChip(
                                icon: Icons.shield_outlined,
                                label: 'آمن',
                              ),
                              SizedBox(width: 5),
                              _FeatureChip(
                                icon: Icons.near_me_outlined,
                                label: 'مباشر',
                              ),
                            ],
                          ),
                          9.sbH,
                          Container(
                            width: double.infinity,
                            height: 43,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.mainAppColor,
                                  const Color(0xFFFF871B),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.mainAppColor
                                      .withValues(alpha: .18),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 27,
                                  height: 27,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 17,
                                    color: Colors.white,
                                  ),
                                ),
                                8.sbW,
                                Text(
                                  'اطلب مندوب',
                                  style: AppTextStyle.text14BS().copyWith(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 41,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(3, 10, 10, 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFFFF8F1),
                              Color(0xFFFFF3E7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(23),
                          border: Border.all(
                            color: AppColors.mainAppColor.withValues(alpha: .10),
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Positioned(
                              top: 13,
                              right: 13,
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: .05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.location_on_rounded,
                                  color: AppColors.mainAppColor,
                                  size: 22,
                                ),
                              ),
                            ),
                            const Positioned.fill(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(5, 27, 5, 2),
                                child: _GoDriveIllustration(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.mainAppColor.withValues(alpha: .12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: AppColors.mainAppColor),
            3.sbW,
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.text10RG().copyWith(
                  color: const Color(0xFF303640),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GoDriveIllustration extends StatelessWidget {
  const _GoDriveIllustration();

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: CustomPaint(
        painter: _GoDriveIllustrationPainter(),
      ),
    );
  }
}

class _GoDriveIllustrationPainter extends CustomPainter {
  const _GoDriveIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const baseWidth = 220.0;
    const baseHeight = 170.0;
    final sx = size.width / baseWidth;
    final sy = size.height / baseHeight;

    canvas.save();
    canvas.scale(sx, sy);

    final cityPaint = Paint()..color = const Color(0xFFFFEAD8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(16, 94, 19, 49),
        const Radius.circular(3),
      ),
      cityPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(39, 79, 22, 64),
        const Radius.circular(3),
      ),
      cityPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(161, 87, 18, 56),
        const Radius.circular(3),
      ),
      cityPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(183, 71, 22, 72),
        const Radius.circular(3),
      ),
      cityPaint,
    );

    final cloudPaint = Paint()..color = const Color(0xFFFFE3CA);
    canvas.drawCircle(const Offset(35, 36), 10, cloudPaint);
    canvas.drawCircle(const Offset(48, 31), 14, cloudPaint);
    canvas.drawCircle(const Offset(64, 38), 9, cloudPaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(25, 36, 50, 13),
        const Radius.circular(7),
      ),
      cloudPaint,
    );

    final shadowPaint = Paint()..color = const Color(0x1A102033);
    canvas.drawOval(
      const Rect.fromLTWH(54, 148, 135, 11),
      shadowPaint,
    );

    final linePaint = Paint()
      ..color = const Color(0xFFFFA24A)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(12, 86), const Offset(45, 86), linePaint);
    canvas.drawLine(const Offset(20, 98), const Offset(45, 98), linePaint);
    canvas.drawLine(const Offset(29, 110), const Offset(45, 110), linePaint);

    final wheelPaint = Paint()..color = const Color(0xFF252B33);
    final tireHighlight = Paint()..color = const Color(0xFF59616B);
    final hubPaint = Paint()..color = const Color(0xFFFF8A16);
    final hubCenter = Paint()..color = Colors.white;

    for (final center in [const Offset(79, 135), const Offset(171, 135)]) {
      canvas.drawCircle(center, 20, wheelPaint);
      canvas.drawCircle(center, 13, tireHighlight);
      canvas.drawCircle(center, 8, hubCenter);
      canvas.drawCircle(center, 3.5, hubPaint);
    }

    final orange = Paint()..color = const Color(0xFFFF7900);
    final orangeDark = Paint()..color = const Color(0xFFE85F00);
    final orangeLight = Paint()..color = const Color(0xFFFFA22E);
    final dark = Paint()..color = const Color(0xFF20262D);
    final skin = Paint()..color = const Color(0xFFFFC49B);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(47, 64, 51, 48),
        const Radius.circular(7),
      ),
      orange,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(52, 69, 41, 7),
        const Radius.circular(4),
      ),
      orangeLight,
    );
    canvas.drawRect(const Rect.fromLTWH(47, 96, 51, 6), orangeDark);

    final scooterBody = Path()
      ..moveTo(69, 111)
      ..quadraticBezierTo(92, 101, 120, 105)
      ..quadraticBezierTo(149, 108, 158, 121)
      ..lineTo(169, 130)
      ..lineTo(154, 130)
      ..quadraticBezierTo(142, 120, 122, 121)
      ..lineTo(88, 121)
      ..quadraticBezierTo(76, 121, 69, 111)
      ..close();
    canvas.drawPath(scooterBody, orange);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(93, 113, 61, 13),
        const Radius.circular(6),
      ),
      orangeDark,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(91, 91, 38, 9),
        const Radius.circular(5),
      ),
      dark,
    );

    final frontShield = Path()
      ..moveTo(153, 92)
      ..quadraticBezierTo(172, 91, 180, 105)
      ..lineTo(184, 127)
      ..lineTo(170, 127)
      ..lineTo(161, 104)
      ..close();
    canvas.drawPath(frontShield, orange);

    final forkPaint = Paint()
      ..color = const Color(0xFF333A43)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(168, 103), const Offset(171, 124), forkPaint);

    final handlePaint = Paint()
      ..color = const Color(0xFF242A31)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(158, 83), const Offset(174, 80), handlePaint);
    canvas.drawLine(const Offset(174, 80), const Offset(178, 86), handlePaint);
    canvas.drawCircle(const Offset(177, 86), 3.5, dark);

    final legPath = Path()
      ..moveTo(122, 91)
      ..quadraticBezierTo(140, 96, 148, 109)
      ..lineTo(158, 128)
      ..lineTo(147, 132)
      ..lineTo(131, 112)
      ..lineTo(113, 104)
      ..close();
    canvas.drawPath(legPath, dark);

    final bodyPath = Path()
      ..moveTo(106, 61)
      ..quadraticBezierTo(126, 57, 139, 71)
      ..lineTo(151, 94)
      ..quadraticBezierTo(140, 102, 121, 97)
      ..lineTo(103, 89)
      ..quadraticBezierTo(99, 73, 106, 61)
      ..close();
    canvas.drawPath(bodyPath, orangeDark);

    final armPaint = Paint()
      ..color = const Color(0xFFE85F00)
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(132, 72), const Offset(158, 84), armPaint);

    canvas.drawCircle(const Offset(159, 84), 5.5, skin);

    canvas.drawCircle(const Offset(116, 49), 13, skin);
    canvas.drawArc(
      const Rect.fromLTWH(101, 33, 31, 24),
      3.15,
      3.12,
      true,
      orange,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(111, 40, 23, 7),
        const Radius.circular(4),
      ),
      dark,
    );
    canvas.drawCircle(const Offset(124, 51), 1.4, dark);

    final neckPaint = Paint()
      ..color = const Color(0xFFFFC49B)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(113, 58), const Offset(111, 65), neckPaint);

    final boxMarkPaint = Paint()
      ..color = Colors.white.withValues(alpha: .88)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(63, 85), const Offset(83, 85), boxMarkPaint);
    canvas.drawLine(const Offset(67, 92), const Offset(83, 92), boxMarkPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _GoDriveIllustrationPainter oldDelegate) => false;
}
