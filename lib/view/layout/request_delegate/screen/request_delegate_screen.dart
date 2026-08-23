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
  Timer? _debounce;
  List<Placemark>? placemarks;
  double? currentLat;
  double? currentLng;
  GoogleMapController? gmc;
  BitmapDescriptor? _orangePinIcon;
  Set<Marker> markers = {};
  bool isLocationLoaded = false;
  bool isCheckingLocation = false;

  double get _panelHeight => context.height * 0.64;

  static const String _cleanLightMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#f7f7f5"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#6f747b"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#ffffff"}]},
  {"featureType":"administrative","elementType":"geometry.stroke","stylers":[{"color":"#e4e5e7"}]},
  {"featureType":"landscape","elementType":"geometry","stylers":[{"color":"#f8f8f6"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#e6e8ea"}]},
  {"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#fbfbfb"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#f1f2f3"}]},
  {"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#9a9ea5"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#cfefff"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#5d8da5"}]}
]
''';

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

    _orangePinIcon ??= await BitmapDescriptor.asset(
      const ImageConfiguration(),
      'assets/images/deliveryLocationPin.png',
      height: 42,
    );

    if (!mounted) return;
    setState(() {
      currentLat = lat;
      currentLng = lng;
      markers
        ..removeWhere((marker) => marker.markerId.value == 'currentLocation')
        ..add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(lat, lng),
            icon: _orangePinIcon ??
                BitmapDescriptor.defaultMarkerWithHue(
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
          try {
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
          } catch (e) {
            log('Failed to load delegate marker image: $e');
          }
        }
      });
    });

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

    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _updateLocation(latLng.latitude, latLng.longitude);
      controller.getDelegatesOnMap(
        lat: latLng.latitude.toString(),
        lan: latLng.longitude.toString(),
      );
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
          icon: _orangePinIcon ??
              BitmapDescriptor.defaultMarkerWithHue(
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
              GoogleMap(
                mapType: MapType.normal,
                onTap: _onMapTap,
                markers: _visibleMarkers(controller),
                style: _cleanLightMapStyle,
                padding: EdgeInsets.only(bottom: _panelHeight * .25),
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
                  zoom: 14.5,
                ),
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.96),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(color: const Color(0xFFF0F1F3)),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
                            blurRadius: 18,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Text(
                        context.languageCode == 'ar' ? 'الدليفري' : 'Delivery',
                        style: const TextStyle(
                          color: Color(0xFF171A1F),
                          fontSize: 17,
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
                    borderRadius: BorderRadius.circular(25),
                    child: Ink(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.mainAppColor.withOpacity(.28),
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x18000000),
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
                    radius: 34,
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
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 10),
          child: Row(
            children: [
              _bottomActionButton(
                icon: Icons.account_balance_wallet_outlined,
                label: context.languageCode == 'ar' ? 'الدفع' : 'Payment',
                onPressed: () => _openPaymentSheet(controller),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _onConfirmOrder(controller),
                    borderRadius: BorderRadius.circular(18),
                    child: Ink(
                      height: 56,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        gradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color(0xFFFF9A2F), Color(0xFFFF6800)],
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33FF7200),
                            blurRadius: 16,
                            offset: Offset(0, 7),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'confirmOrder'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _bottomActionButton(
                icon: Icons.tune_rounded,
                label: context.languageCode == 'ar' ? 'تفاصيل' : 'Details',
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _bottomActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 62,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE7E9ED)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0D000000),
                blurRadius: 11,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFF252A31), size: 22),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF5D626A),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openPaymentSheet(RequestDelegateController controller) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: controller,
        child: PaymentRDBottomSheet(requestDelegateController: controller),
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
      CommonMethods.showError(
        message: context.languageCode == 'ar'
            ? 'من فضلك اكتب الغرض المطلوب توصيله أولاً'
            : 'Please enter the item to be delivered first',
      );
    } else {
      CommonMethods.showToast(message: 'confirmDataNotEmpty'.tr);
    }
  }
}
