import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/page_container/page_container.dart';
import '../../auth/controller/auth_controller.dart';
import '../../my_account/account_app_bar/account_app_bar.dart';
import '../controller/favorite_controller.dart';
import '../widget/favorite_widget.dart';

class FavoriteScreen extends StatelessWidget {
  static const String routeName = 'FavoriteScreen';
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) {
        return FavoriteController()
          ..initialFavorite()
          ..getFavorite();
      },
      child: Consumer<FavoriteController>(
        builder: (context, favoriteController, _) {
          return Scaffold(
            body: PageContainer(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    CustomAccountAppBar(title: 'favorite'.tr),
                    const SizedBox(height: 22),
                    ApiResponseWidget(
                      apiResponse: favoriteController.favoriteResponse,
                      onReload: favoriteController.getFavorite,
                      isEmpty: favoriteController.favorite.isEmpty,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.whiteColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(34),
                            topRight: Radius.circular(34),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.greyColor.withValues(alpha: 0.2),
                              offset: const Offset(0, -3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              child: Column(
                                children: [
                                  const SizedBox(height: 24),
                                  Row(
                                    children: [
                                      Provider.of<AuthController>(context).profile?.gender == 'male'
                                          ? SvgPicture.asset(AppImages.avatarMale)
                                          : Provider.of<AuthController>(context).profile?.gender == 'female'
                                              ? SvgPicture.asset(AppImages.avatarFemale)
                                              : CircleAvatar(
                                                  backgroundColor: AppColors.mainAppColor,
                                                  child: Text(
                                                    Provider.of<AuthController>(context)
                                                            .profile
                                                            ?.name
                                                            ?.substring(0, 1) ??
                                                        '',
                                                    style: AppTextStyle.text20MW(),
                                                  ),
                                                ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            Provider.of<AuthController>(context).profile?.name ?? '',
                                            style: AppTextStyle.text18MS(),
                                          ),
                                          5.sbH,
                                          Row(
                                            children: [
                                              SvgPicture.asset(AppImages.egyptIcon),
                                              const SizedBox(width: 10),
                                              Text(
                                                Provider.of<AuthController>(context).profile?.areaTitle ?? '',
                                                style: AppTextStyle.text16RG(),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            15.sbH,
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                              child: StaggeredGrid.count(
                                crossAxisCount: 2,
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 1,
                                children: [
                                  ...List.generate(
                                    favoriteController.favorite.length,
                                    (index) => Column(
                                      children: [FavoriteWidget(favoriteModel: favoriteController.favorite[index])],
                                    ),
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
            ),
          );
        },
      ),
    );
  }
}
