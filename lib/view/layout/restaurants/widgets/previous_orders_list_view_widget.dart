import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../custom_widgets/custom_image/custom_network_image.dart';
import '../controller/restaurants_controller.dart';
import '../screen/product_details_screen.dart';

class PreviousOrdersListViewWidget extends StatelessWidget {
  const PreviousOrdersListViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RestaurantsController>(
      builder: (BuildContext context, restaurantsController, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: 144,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemCount: restaurantsController.previousOrders.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  if (restaurantsController.detailsRestaurant?.status == 'closed') {
                    CommonMethods.showError(message: 'thisRestaurantIsClosed'.tr);
                  } else {
                    if (restaurantsController.previousOrders[index].status == 'show') {
                      NamedNavigatorImpl.push(
                        ProductDetailsScreen.routeName,
                        arguments: ProductDetailsDetailsArgs(id: restaurantsController.previousOrders[index].id ?? 0),
                      );
                    } else {
                      CommonMethods.showError(message: 'productNotAvailable'.tr);
                    }
                  }
                },
                child: Row(
                  children: [
                    Column(
                      children: [
                        CustomNetworkImage(
                          imageUrl: restaurantsController.previousOrders[index].productImage ?? '',
                          height: 84,
                          width: 116,
                          radius: 12,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          restaurantsController.previousOrders[index].productName ?? '',
                          style: AppTextStyle.text16RS(),
                        ),
                        const SizedBox(height: 8),
                        if (restaurantsController.previousOrders[index].productPrice != null) ...[
                          restaurantsController.previousOrders[index].status == 'show'
                              ? Text(
                                  'pound'.tr.replaceAll(
                                        '{}',
                                        restaurantsController.previousOrders[index].productPrice.toString(),
                                      ),
                                  style: AppTextStyle.text14RG(),
                                )
                              : Text('notAvailable'.tr, style: AppTextStyle.text16RG()),
                        ],
                      ],
                    ),
                    const SizedBox(width: 5),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
