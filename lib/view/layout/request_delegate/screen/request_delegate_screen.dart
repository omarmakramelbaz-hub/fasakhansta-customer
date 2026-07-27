import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_image/custom_image.dart';
import '../../../custom_widgets/custom_loading/custom_loading.dart';
import '../../../custom_widgets/custom_loading/custom_shimmer.dart';
import '../../../custom_widgets/custom_payment_web_view/custom_payment_web_view.dart';
import '../bottom_sheet/payment_rd_bottom_sheet.dart';
import '../bottom_sheet/rd_details_bottom_sheet.dart';
import '../controller/request_delegate_controller.dart';
import '../widget/custom_map_animated_container.dart';
import 'show_delegate_on_map_screen.dart';

class RequestDelegateScreen extends StatefulWidget {
  static const String routeName = 'RequestDelegateScreen';

  const RequestDelegateScreen({super.key});

  @override
  State<RequestDelegateScreen> createState() => _RequestDelegateScreenState();
}

class _RequestDelegateScreenState extends State<RequestDelegateScreen> with WidgetsBindingObserver {
  double? containerHeight;
  Timer? resetTimer;
  List<Placemark>? placemarks;
  double? currentLat;
  double? currentLng;
  GoogleMapController? gmc;
  Set<Marker> markers = {};
  String? _mapStyle;
  bool isLocationLoaded = false;
  bool isCheckingLocation = false;
  bool isMapInteracting = false;
  Timer? _debounce;

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          log('Location permissions are denied.');
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      _updateLocation(position.latitude, position.longitude);
    } catch (e) {
      log('Failed to get location: $e');
    }
  }

  void _updateLocation(double lat, double lng) async {
    final requestDelegateController = Provider.of<RequestDelegateController>(context, listen: false);
    requestDelegateController.reset();

    setState(() {
      currentLat = lat;
      currentLng = lng;
      markers.clear();
      markers.add(Marker(markerId: const MarkerId('currentLocation'), position: LatLng(lat, lng)));
    });

    // Ensure controller fetches data after location update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestDelegateController.initialDelegatesOnMap();

      requestDelegateController.getDelegatesOnMap(lat: currentLat.toString(), lan: currentLng.toString()).then((
        value,
      ) async {
        final delegatesOnMap = requestDelegateController.delegatesOnMap;

        // Check if shippingOrderId exists
        if (delegatesOnMap?.shippingOrderId != null && delegatesOnMap?.shippingOrderId != 0) {
          log('Shipping order ID found: ${delegatesOnMap?.shippingOrderId}');

          // Set the order ID and navigate
          requestDelegateController.setOrderId(delegatesOnMap?.shippingOrderId ?? 0);

          log('Navigating to ShowDelegateOnMapScreen');
          ///////////////////////////////////////////////////// re comment later /////////////////////////////////////////////////
          NamedNavigatorImpl.push(
            ShowDelegateOnMapScreen.routeName,
            arguments: ShowDelegateOnMapArgs(
              orderId: delegatesOnMap?.shippingOrderId,
              fee: int.parse(delegatesOnMap?.orderData?.actualPrice.toString() ?? '0'),
              kmPrice: int.parse('${delegatesOnMap?.shippingKmPrice}'),
              shippingPercentage: int.parse('${delegatesOnMap?.shippingMinPricePrecentage}'),
              distance: num.parse('${requestDelegateController.distance ?? 0}'),
            ),
          );
        } else {
          log('No shipping order ID found. Skipping navigation.');
          requestDelegateController.setDistance(0.0);
        }

        // Add markers for user data if available
        if (delegatesOnMap?.userData != null) {
          var customMarkerIcon = await BitmapDescriptor.asset(
            const ImageConfiguration(),
            'assets/images/motorcycleImage.png',
            height: 50,
          );
          var myMarker = delegatesOnMap?.userData!.map(
            (userModel) => Marker(
              icon: customMarkerIcon,
              markerId: MarkerId(userModel.id.toString()),
              position: LatLng(double.parse(userModel.lat!), double.parse(userModel.lng!)),
            ),
          );
          markers.addAll(myMarker!);
          setState(() {});
        }
      });
    });
    requestDelegateController.reset();
    // Updating map camera and placemarks
    if (gmc != null) {
      gmc!.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
    }

    placemarks = await placemarkFromCoordinates(lat, lng);
    requestDelegateController.setFromLat(lat.toString());
    requestDelegateController.setFromLan(lng.toString());
    requestDelegateController.setFromAddress(
      '${placemarks![0].locality}, ${placemarks![0].country} ${placemarks![0].street}',
    );

    setState(() {
      isLocationLoaded = true;
    });
  }

  void _onMapTap(LatLng latLng) async {
    final requestDelegateController = Provider.of<RequestDelegateController>(context, listen: false);
    var customMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      'assets/images/motorcycleImage.png',
      height: 50,
    );
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _updateLocation(latLng.latitude, latLng.longitude);
      // requestDelegateController.setFromLat(latLng.latitude.toString());
      // requestDelegateController.setFromLan(latLng.longitude.toString());
      requestDelegateController.getDelegatesOnMap(lat: latLng.latitude.toString(), lan: latLng.longitude.toString());

      if (requestDelegateController.delegatesOnMap?.userData != null) {
        var myMarker = requestDelegateController.delegatesOnMap?.userData!.map(
          (userModel) => Marker(
            icon: customMarkerIcon,
            markerId: MarkerId(userModel.id.toString()),
            position: LatLng(double.parse(userModel.lat!), double.parse(userModel.lng!)),
          ),
        );
        markers.addAll(myMarker!);
        setState(() {});
      }
    });

    if (gmc != null) {
      gmc!.animateCamera(CameraUpdate.newLatLng(LatLng(latLng.latitude, latLng.longitude)));
    }

    setState(() {
      markers.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    initMapStyle();
    WidgetsBinding.instance.addObserver(this);
    _determinePosition();
  }

  void initMapStyle() async {
    var mapStyle = await DefaultAssetBundle.of(context).loadString('assets/map_styles/dark_map_style.json');
    setState(() {
      _mapStyle = mapStyle;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    resetTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recheckLocationServices();
    }
  }

  Future<void> _recheckLocationServices() async {
    setState(() {
      isCheckingLocation = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (serviceEnabled) {
      await _determinePosition();
    } else {
      log('Location services are still disabled.');
    }

    setState(() {
      isCheckingLocation = false;
    });
  }

  void _setContainerHeight(double height) {
    setState(() {
      containerHeight = height;
    });
  }

  void _startResetTimer() {
    resetTimer?.cancel();
    resetTimer = Timer(const Duration(seconds: 3), () {
      _setContainerHeight(context.height * 0.35);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestDelegateController>(
      builder: (context, requestDelegateController, _) {
        if (isLocationLoaded) {
          return Scaffold(
            backgroundColor: AppColors.blackColor,
            body: Stack(
              children: [
                GestureDetector(
                  onTapDown: (_) => _setContainerHeight(0),
                  onTapUp: (_) => _setContainerHeight(context.height * 0.35),
                  onTapCancel: () => _startResetTimer(),
                  child: isLocationLoaded
                      ? GoogleMap(
                          mapType: MapType.normal,
                          onTap: _onMapTap,
                          markers: markers,
                          style: _mapStyle,
                          onMapCreated: (GoogleMapController controller) {
                            gmc = controller;
                            if (currentLat != null && currentLng != null) {
                              gmc!.animateCamera(CameraUpdate.newLatLng(LatLng(currentLat!, currentLng!)));
                            }
                          },
                          initialCameraPosition: CameraPosition(
                            target: LatLng(currentLat ?? 0, currentLng ?? 0),
                            zoom: 14,
                          ),
                          zoomControlsEnabled: false,
                        )
                      : const Center(child: CustomLoading()),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: context.languageCode == 'ar' ? 10 : null,
                  left: context.languageCode == 'ar' ? null : 10,
                  child: InkWell(
                    onTap: () => NamedNavigatorImpl.pop(),
                    child: RotatedBox(
                      quarterTurns: context.languageCode == 'ar' ? 0 : 2,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.blackColor, shape: BoxShape.circle),
                        child: Icon(Icons.arrow_back, color: AppColors.mainAppColor),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: ApiResponseWidget(
                    loadingWidget: CustomShimmer(
                      height: context.height * 0.35,
                      width: double.infinity,
                      radius: 15,
                      fillColor: AppColors.lightDarkColor,
                      shimmerColor: AppColors.lightMainAppColor,
                    ),
                    apiResponse: requestDelegateController.delegateOnMapApiResponse,
                    onReload: () => requestDelegateController.getDelegatesOnMap(
                      lat: currentLat.toString(),
                      lan: currentLng.toString(),
                    ),
                    isEmpty: requestDelegateController.delegatesOnMap?.userData == null,
                    child: CustomMapAnimatedContainer(containerHeight: containerHeight),
                  ),
                ),
              ],
            ),
            bottomNavigationBar: _buildBottomNavigationBar(requestDelegateController),
          );
        } else {
          return const Center(child: CustomLoading());
        }
      },
    );
  }

  Widget _buildBottomNavigationBar(RequestDelegateController controller) {
    if (containerHeight == 0) {
      return const SizedBox();
    } else {
      return Container(
        color: AppColors.blackColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
          child: Row(
            children: [
              IconButton(
                icon: const CustomImage(path: AppImages.discretionRDIcon, type: ImageType.svg),
                onPressed: () {
                  Utils.showAppBottomSheet(
                    ChangeNotifierProvider.value(
                      value: controller,
                      child: RDDetailsBottomSheet(requestDelegateController: controller),
                    ),
                  );
                },
              ),
              Expanded(
                child: CustomButton(
                  onPressed: () {
                    _onConfirmOrder(controller);
                  },
                  text: 'confirmOrder'.tr,
                ),
              ),
              IconButton(
                icon: const CustomImage(path: AppImages.paymentRDIcon, type: ImageType.svg),
                onPressed: () {
                  Utils.showAppBottomSheet(
                    ChangeNotifierProvider.value(
                      value: controller,
                      child: PaymentRDBottomSheet(requestDelegateController: controller),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  void _onConfirmOrder(RequestDelegateController controller) {
    final shippingKmPrice = double.tryParse('${controller.delegatesOnMap?.shippingKmPrice}') ?? 0;
    final expectedPrice = controller.calculateDeliveryPrice(kmPrice: shippingKmPrice).toString();
    final bool serviceActivated = controller.delegatesOnMap?.goDriveBlock == 0;

    if (controller.isDataValid()) {
      if (!serviceActivated) {
        CommonMethods.showError(message: 'callAdminToActivateService'.tr);
      } else {
        controller.createNewShippingOrder(
          fromLat: controller.fromLat ?? '',
          fromLng: controller.fromLan ?? '',
          fromAddress: controller.fromAddress,
          toLat: controller.toLat ?? '',
          toLng: controller.toLan ?? '',
          toAddress: controller.toAddress,
          description: controller.descriptionEC.text,
          actualPrice: controller.actualPrice ?? expectedPrice,
          expectedPrice: expectedPrice,
          paymentType: controller.selectedPayment,
          onSuccess: () {
            if (controller.selectedPayment == 'cash' || controller.selectedPayment == 'wallet') {
              NamedNavigatorImpl.push(
                ShowDelegateOnMapScreen.routeName,
                arguments: ShowDelegateOnMapArgs(
                  orderId: controller.orderId,
                  fee: int.parse(controller.actualPrice ?? '0'),
                  kmPrice: int.parse('${controller.delegatesOnMap?.shippingKmPrice}'),
                  shippingPercentage: int.parse('${controller.delegatesOnMap?.shippingMinPricePrecentage}'),
                  distance: num.parse('${controller.distance}'),
                ),
              );
              controller.reset();
            }
          },
          onHadeLink: (link) {
            if (controller.selectedPayment != 'cash') {
              NamedNavigatorImpl.push(
                CustomPaymentWebViewScreen.routeName,
                arguments: PaymentArgs(
                  url: link,
                  onFailed: () {
                    CommonMethods.showError(message: 'paymentFailed'.tr);
                  },
                  onSuccess: () {
                    NamedNavigatorImpl.push(
                      ShowDelegateOnMapScreen.routeName,
                      arguments: ShowDelegateOnMapArgs(
                        orderId: controller.orderId,
                        fee: int.parse(controller.actualPrice ?? '0'),
                        kmPrice: int.parse('${controller.delegatesOnMap?.shippingKmPrice}'),
                        shippingPercentage: int.parse('${controller.delegatesOnMap?.shippingMinPricePrecentage}'),
                        distance: num.parse('${controller.distance}'),
                      ),
                    );
                    controller.reset();
                  },
                ),
              );
            }
          },
        );
      }
    } else if (controller.descriptionEC.text.isEmpty) {
      Utils.showAppBottomSheet(
        ChangeNotifierProvider.value(
            value: controller, child: RDDetailsBottomSheet(requestDelegateController: controller)),
      );
    } else {
      CommonMethods.showToast(message: 'confirmDataNotEmpty'.tr);
    }
  }
}
