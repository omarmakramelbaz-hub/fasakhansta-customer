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
    final address = profile?.userAddresses?.isNotEmpty == true ? profile!.userAddresses!.first : null;
    final location = [address?.streetName, address?.cityName]
        .where((value) => value != null && value.trim().isNotEmpty)
        .join(' - ');
    final imageUrl = controller.headerImageUrl;

    return ClipPath(
      clipper: const _SeaHeaderClipper(),
      child: Container(
        height: 214,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF7A00), Color(0xFFFF8D00), Color(0xFFFFB12B), Color(0xFFFFD36A)],
            stops: [0, .38, .72, 1],
          ),
          image: imageUrl == null
              ? null
              : DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
        ),
        child: Stack(
          children: [
            if (imageUrl != null)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(.25), Colors.black.withOpacity(.08), AppColors.mainAppColor.withOpacity(.45)],
                    ),
                  ),
                ),
              )
            else
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
                      _SearchButton(onTap: () => NamedNavigatorImpl.push(SearchScreen.routeName)),
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
                            style: AppTextStyle.text12BS().copyWith(color: Colors.white, fontSize: 12, shadows: const [Shadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 1))]),
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
                                        const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 17),
                                        const SizedBox(width: 2),
                                        Text('التوصيل إلى', textDirection: TextDirection.rtl, style: AppTextStyle.text12BS().copyWith(color: Colors.white, fontSize: 11, shadows: const [Shadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 1))])),
                                      ],
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      location.isEmpty ? 'اختر العنوان' : location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      style: AppTextStyle.text12BS().copyWith(color: Colors.white, fontSize: 10.5, shadows: const [Shadow(color: Color(0x55000000), blurRadius: 4, offset: Offset(0, 1))]),
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
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6)), BoxShadow(color: Color(0x66FFFFFF), blurRadius: 2, offset: Offset(0, -1))]),
          child: Icon(Icons.search_rounded, color: AppColors.mainAppColor, size: 29),
        ),
      );
}

class _LocationButton extends StatelessWidget {
  const _LocationButton();
  @override
  Widget build(BuildContext context) => Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 12, offset: Offset(0, 6)), BoxShadow(color: Color(0x66FFFFFF), blurRadius: 2, offset: Offset(0, -1))]),
        child: Icon(Icons.location_on_outlined, color: AppColors.mainAppColor, size: 29),
      );
}

class _SeaHeaderClipper extends CustomClipper<Path> {
  const _SeaHeaderClipper();

  @override
  Path getClip(Size size) {
    final height = size.height;
    final width = size.width;

    // Three sharp wave vertices along the bottom edge.
    return Path()
      ..moveTo(0, 0)
      ..lineTo(width, 0)
      ..lineTo(width, height - 16)
      ..lineTo(width * .75, height - 2)
      ..lineTo(width * .50, height - 28)
      ..lineTo(width * .25, height - 2)
      ..lineTo(0, height - 16)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _SeaHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * .52, 76);
    final glow = Paint()..shader = RadialGradient(colors: [Colors.white.withOpacity(.28), Colors.white.withOpacity(.08), Colors.transparent]).createShader(Rect.fromCircle(center: center, radius: 72));
    canvas.drawCircle(center, 72, glow);
    canvas.drawCircle(center, 34, Paint()..color = const Color(0xFFFFF2C2).withOpacity(.78));
    final horizon = Paint()..color = const Color(0xFFFF9A16).withOpacity(.56);
    final horizonPath = Path()..moveTo(0, 138)..quadraticBezierTo(size.width * .12, 114, size.width * .24, 138)..quadraticBezierTo(size.width * .38, 162, size.width * .52, 134)..quadraticBezierTo(size.width * .67, 107, size.width * .82, 136)..quadraticBezierTo(size.width * .92, 155, size.width, 126)..lineTo(size.width, 214)..lineTo(0, 214)..close();
    canvas.drawPath(horizonPath, horizon);
    final deepLayer = Paint()..color = const Color(0xFFE95300).withOpacity(.34);
    final deepPath = Path()..moveTo(0, 171)..quadraticBezierTo(size.width * .18, 139, size.width * .35, 171)..quadraticBezierTo(size.width * .51, 199, size.width * .67, 166)..quadraticBezierTo(size.width * .83, 139, size.width, 168)..lineTo(size.width, 214)..lineTo(0, 214)..close();
    canvas.drawPath(deepPath, deepLayer);
  }
  @override
  bool shouldRepaint(covariant _SeaHeaderPainter oldDelegate) => false;
}
