import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/utils.dart';
import '../../../custom_widgets/api_response_widget/api_response_widget.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
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

class _RequestDelegateScreenState extends State<RequestDelegateScreen>
    with WidgetsBindingObserver {
  double? containerHeight;
  Timer? resetTimer;
  Timer? _debounce;
  List<Placemark>? placemarks;
  double? currentLat;
  double? currentLng;
  GoogleMapController? gmc;
  Set<Marker> markers = {};
  bool isLocationLoaded = false;
  bool isCheckingLocation = false;

  double get _panelHeight => context.height * 0.62;

  Future<void> _determinePosition() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          log('Location permissions are denied.');
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition();
      await _updateLocation(position.latitude, position.longitude);
    } catch (e) {
      log('Failed to get location: $e');
    }
  }

  Future<void> _updateLocation(double lat, double lng) async {
    final controller =
        Provider.of<RequestDelegateController>(context, listen: false);
    controller.reset();

    if (!mounted) return;
    setState(() {
      currentLat = lat;
      currentLng = lng;
      markers
        ..clear()
        ..add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),
        );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.initialDelegatesOnMap();
      controller
          .getDelegatesOnMap(
            lat: currentLat.toString(),
            lan: currentLng.toString(),
          )
          .then((_) async {
        final delegatesOnMap = controller.delegatesOnMap;

        if (delegatesOnMap?.shippingOrderId != null &&
            delegatesOnMap?.shippingOrderId != 0) {
          controller.setOrderId(delegatesOnMap?.shippingOrderId ?? 0);
          NamedNavigatorImpl.push(
            ShowDelegateOnMapScreen.routeName,
            arguments: ShowDelegateOnMapArgs(
              orderId: delegatesOnMap?.shippingOrderId,
              fee: int.parse(
                delegatesOnMap?.orderData?.actualPrice.toString() ?? '0',
              ),
              kmPrice: int.parse('${delegatesOnMap?.shippingKmPrice}'),
              shippingPercentage: int.parse(
                '${delegatesOnMap?.shippingMinPricePrecentage}',
              ),
              distance: num.parse('${controller.distance ?? 0}'),
            ),
          );
        } else {
          controller.setDistance(0.0);
        }

        if (delegatesOnMap?.userData != null) {
          final customMarkerIcon = await BitmapDescriptor.asset(
            const ImageConfiguration(),
            'assets/images/motorcycleImage.png',
            height: 50,
          );
          final delegateMarkers = delegatesOnMap!.userData!.map(
            (userModel) => Marker(
              icon: customMarkerIcon,
              markerId: MarkerId(userModel.id.toString()),
              position: LatLng(
                double.parse(userModel.lat!),
                double.parse(userModel.lng!),
              ),
            ),
          );
          markers.addAll(delegateMarkers);
          if (mounted) setState(() {});
        }
      });
    });

    controller.reset();

    if (gmc != null) {
      await gmc!.animateCamera(
        CameraUpdate.newLatLng(LatLng(lat, lng)),
      );
    }

    controller.setFromLat(lat.toString());
    controller.setFromLan(lng.toString());

    try {
      placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks != null && placemarks!.isNotEmpty) {
        controller.setFromAddress(
          '${placemarks![0].locality}, ${placemarks![0].country} ${placemarks![0].street}',
        );
      } else {
        controller.setFromAddress(
          '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
        );
      }
    } catch (e) {
      log('Reverse geocoding failed: $e');
      controller.setFromAddress(
        '${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
      );
    }

    if (!mounted) return;
    setState(() {
      isLocationLoaded = true;
    });
  }

  void _onMapTap(LatLng latLng) async {
    final controller =
        Provider.of<RequestDelegateController>(context, listen: false);
    final customMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      'assets/images/motorcycleImage.png',
      height: 50,
    );

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _updateLocation(latLng.latitude, latLng.longitude);
      controller.getDelegatesOnMap(
        lat: latLng.latitude.toString(),
        lan: latLng.longitude.toString(),
      );

      if (controller.delegatesOnMap?.userData != null) {
        final delegateMarkers = controller.delegatesOnMap!.userData!.map(
          (userModel) => Marker(
            icon: customMarkerIcon,
            markerId: MarkerId(userModel.id.toString()),
            position: LatLng(
              double.parse(userModel.lat!),
              double.parse(userModel.lng!),
            ),
          ),
        );
        markers.addAll(delegateMarkers);
        if (mounted) setState(() {});
      }
    });

    if (gmc != null) {
      gmc!.animateCamera(CameraUpdate.newLatLng(latLng));
    }
  }

  Set<Marker> _visibleMarkers(RequestDelegateController controller) {
    final result = Set<Marker>.from(markers);
    final toLat = double.tryParse(controller.toLat ?? '');
    final toLng = double.tryParse(controller.toLan ?? '');
    if (toLat != null && toLng != null) {
      result.add(
        Marker(
          markerId: const MarkerId('deliveryDestination'),
          position: LatLng(toLat, toLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }
    return result;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _determinePosition();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    resetTimer?.cancel();
    _debounce?.cancel();
    gmc?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recheckLocationServices();
    }
  }

  Future<void> _recheckLocationServices() async {
    if (!mounted) return;
    setState(() => isCheckingLocation = true);

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (serviceEnabled) {
      await _determinePosition();
    } else {
      log('Location services are still disabled.');
    }

    if (!mounted) return;
    setState(() => isCheckingLocation = false);
  }

  void _setContainerHeight(double height) {
    if (!mounted) return;
    setState(() => containerHeight = height);
  }

  void _startResetTimer() {
    resetTimer?.cancel();
    resetTimer = Timer(const Duration(seconds: 3), () {
      _setContainerHeight(_panelHeight);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestDelegateController>(
      builder: (context, controller, _) {
        if (!isLocationLoaded) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CustomLoading()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              GestureDetector(
                onTapDown: (_) => _setContainerHeight(0),
                onTapUp: (_) => _setContainerHeight(_panelHeight),
                onTapCancel: _startResetTimer,
                child: GoogleMap(
                  mapType: MapType.normal,
                  onTap: _onMapTap,
                  markers: _visibleMarkers(controller),
                  onMapCreated: (mapController) {
                    gmc = mapController;
                    if (currentLat != null && currentLng != null) {
                      gmc!.animateCamera(
                        CameraUpdate.newLatLng(
                          LatLng(currentLat!, currentLng!),
                        ),
                      );
                    }
                  },
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLat ?? 0, currentLng ?? 0),
                    zoom: 14,
                  ),
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  mapToolbarEnabled: false,
                  compassEnabled: false,
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 11,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        context.languageCode == 'ar' ? 'الدليفري' : 'Delivery',
                        style: const TextStyle(
                          color: Color(0xFF181C22),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                right: context.languageCode == 'ar' ? 12 : null,
                left: context.languageCode == 'ar' ? null : 12,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => NamedNavigatorImpl.pop(),
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.mainAppColor.withOpacity(.25),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 14,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Icon(
                        context.languageCode == 'ar'
                            ? Icons.arrow_forward_rounded
                            : Icons.arrow_back_rounded,
                        color: AppColors.mainAppColor,
                        size: 25,
                      ),
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
                    height: _panelHeight,
                    width: double.infinity,
                    radius: 30,
                    fillColor: Colors.white,
                    shimmerColor: const Color(0xFFF3F4F6),
                  ),
                  apiResponse: controller.delegateOnMapApiResponse,
                  onReload: () => controller.getDelegatesOnMap(
                    lat: currentLat.toString(),
                    lan: currentLng.toString(),
                  ),
                  isEmpty: controller.delegatesOnMap?.userData == null,
                  child: CustomMapAnimatedContainer(
                    containerHeight: containerHeight,
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNavigationBar(controller),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(RequestDelegateController controller) {
    if (containerHeight == 0) return const SizedBox();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 18,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(
            children: [
              _bottomActionButton(
                icon: Icons.notes_rounded,
                onPressed: () {
                  Utils.showAppBottomSheet(
                    ChangeNotifierProvider.value(
                      value: controller,
                      child: RDDetailsBottomSheet(
                        requestDelegateController: controller,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: CustomButton(
                    onPressed: () => _onConfirmOrder(controller),
                    text: 'confirmOrder'.tr,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _bottomActionButton(
                icon: Icons.account_balance_wallet_outlined,
                onPressed: () {
                  Utils.showAppBottomSheet(
                    ChangeNotifierProvider.value(
                      value: controller,
                      child: PaymentRDBottomSheet(
                        requestDelegateController: controller,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(17),
            border: Border.all(color: const Color(0xFFE7E9ED)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x10000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: const Color(0xFF252A31), size: 25),
        ),
      ),
    );
  }

  void _onConfirmOrder(RequestDelegateController controller) {
    final shippingKmPrice =
        double.tryParse('${controller.delegatesOnMap?.shippingKmPrice}') ?? 0;
    final expectedPrice =
        controller.calculateDeliveryPrice(kmPrice: shippingKmPrice).toString();
    final serviceActivated = controller.delegatesOnMap?.goDriveBlock == 0;

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
            if (controller.selectedPayment == 'cash' ||
                controller.selectedPayment == 'wallet') {
              NamedNavigatorImpl.push(
                ShowDelegateOnMapScreen.routeName,
                arguments: ShowDelegateOnMapArgs(
                  orderId: controller.orderId,
                  fee: int.parse(controller.actualPrice ?? '0'),
                  kmPrice: int.parse(
                    '${controller.delegatesOnMap?.shippingKmPrice}',
                  ),
                  shippingPercentage: int.parse(
                    '${controller.delegatesOnMap?.shippingMinPricePrecentage}',
                  ),
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
                        kmPrice: int.parse(
                          '${controller.delegatesOnMap?.shippingKmPrice}',
                        ),
                        shippingPercentage: int.parse(
                          '${controller.delegatesOnMap?.shippingMinPricePrecentage}',
                        ),
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
          value: controller,
          child: RDDetailsBottomSheet(
            requestDelegateController: controller,
          ),
        ),
      );
    } else {
      CommonMethods.showToast(message: 'confirmDataNotEmpty'.tr);
    }
  }
}
