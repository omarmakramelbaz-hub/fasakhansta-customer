import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../../../custom_widgets/page_container/page_container.dart';
import '../controller/favorite_controller.dart';
import '../model/favorite_model.dart';

class FavoriteScreen extends StatelessWidget {
  static const String routeName = 'FavoriteScreen';
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FavoriteController()
        ..initialFavorite()
        ..getFavorite(),
      child: Consumer<FavoriteController>(
        builder: (context, controller, _) {
          return Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
            body: SafeArea(
              child: PageContainer(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: Row(
                        children: [
                          _circleButton(
                            icon: Icons.arrow_back_ios_new_rounded,
                            onTap: () => Navigator.maybePop(context),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                Text('المفضلة', style: AppTextStyle.text24MS()),
                                const SizedBox(height: 3),
                                Text(
                                  'مطاعمك المفضلة دائماً في انتظارك',
                                  style: AppTextStyle.text13RG(),
                                ),
                              ],
                            ),
                          ),
                          _circleButton(
                            icon: Icons.favorite_border_rounded,
                            iconColor: AppColors.mainAppColor,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ApiResponseWidget(
                        apiResponse: controller.favoriteResponse,
                        onReload: controller.getFavorite,
                        isEmpty: controller.favorite.isEmpty,
                        child: RefreshIndicator(
                          color: AppColors.mainAppColor,
                          onRefresh: controller.getFavorite,
                          child: ListView(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            children: [
                              _favoritesBanner(),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Text('إجمالي المفضلة ', style: AppTextStyle.text16MS()),
                                  Text(
                                    '${controller.favorite.length}',
                                    style: AppTextStyle.text18MS().copyWith(color: AppColors.mainAppColor),
                                  ),
                                  Text(' مطعم', style: AppTextStyle.text16MS()),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
                                    decoration: BoxDecoration(
                                      color: AppColors.whiteColor,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: AppColors.borderColor),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.tune_rounded, size: 18),
                                        const SizedBox(width: 7),
                                        Text('ترتيب', style: AppTextStyle.text13MS()),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: controller.favorite.length,
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 10,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: .68,
                                ),
                                itemBuilder: (_, index) => _FavoriteCard(
                                  model: controller.favorite[index],
                                  onRemove: () => controller.addOrRemoveToWishlist(
                                    id: controller.favorite[index].id ?? 0,
                                    onSuccess: () {},
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              _browseBanner(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color? iconColor,
  }) {
    return Material(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 50,
          height: 50,
          child: Icon(icon, color: iconColor ?? AppColors.mainAppColor, size: 24),
        ),
      ),
    );
  }

  static Widget _favoritesBanner() {
    return Container(
      height: 132,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0E5),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.mainAppColor,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('كل ما تحبه.. في مكان واحد', style: AppTextStyle.text18MS()),
                const SizedBox(height: 7),
                Text(
                  'احتفظ بالمطاعم التي تحبها للوصول إليها بسهولة',
                  style: AppTextStyle.text13RG(),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          const Icon(Icons.favorite_rounded, color: Colors.white70, size: 48),
        ],
      ),
    );
  }

  static Widget _browseBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.shopping_bag_outlined, color: AppColors.mainAppColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('عايز تكتشف أماكن جديدة؟', style: AppTextStyle.text15MS()),
                const SizedBox(height: 4),
                Text('تصفح الفروع واكتشف المزيد من المطاعم', style: AppTextStyle.text12RG()),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppColors.mainAppColor.withValues(alpha: .25)),
            ),
            child: Text('تصفح الفروع', style: AppTextStyle.text12MS().copyWith(color: AppColors.mainAppColor)),
          ),
        ],
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteModel model;
  final VoidCallback onRemove;

  const _FavoriteCard({required this.model, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10, offset: Offset(0, 3))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CustomNetworkImage(
                imageUrl: model.bgImage?.isNotEmpty == true ? model.bgImage! : (model.logo ?? ''),
                height: 132,
                width: double.infinity,
                radius: 0,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 9,
                left: 9,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onRemove,
                    child: const SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(Icons.favorite_rounded, color: Color(0xFFF45113), size: 21),
                    ),
                  ),
                ),
              ),
              if ((model.status ?? '').isNotEmpty)
                Positioned(
                  top: 10,
                  right: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.mainAppColor,
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(model.status!, style: AppTextStyle.text10MW()),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 11),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(model.name ?? '', style: AppTextStyle.text15MS(), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, color: Color(0xFFFFB000), size: 16),
                    const SizedBox(width: 3),
                    Text('${model.avgRate ?? 0}', style: AppTextStyle.text12MS()),
                    const Spacer(),
                    const Icon(Icons.access_time_rounded, size: 15, color: Colors.grey),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        model.deliveryTime ?? '',
                        style: AppTextStyle.text11RG(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  model.address ?? '',
                  style: AppTextStyle.text11RG(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
