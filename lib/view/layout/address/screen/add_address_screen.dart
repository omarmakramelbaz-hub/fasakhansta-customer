import 'dart:async';
import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/images/app_images.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/theme/app_text_style.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/location_service.dart';
import '../../../custom_widgets/buttons/custom_button.dart';
import '../../../custom_widgets/custom_form_field/custom_form_field.dart';
import '../../../custom_widgets/custom_loading/custom_loading.dart';
import '../../../custom_widgets/page_container/page_container.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/address_controller.dart';
import '../widget/change_adress_widget.dart';
import '../widget/circle_avatar_widget.dart';
import '../widget/type_address_widget.dart';
import 'map_screen.dart';

class AddAddressArgs {
  final VoidCallback onSuccess;
  AddAddressArgs({required this.onSuccess});
}

class AddAddressScreen extends StatefulWidget {
  final AddAddressArgs args;
  static const String routeName = 'AddAddressScreen';
  const AddAddressScreen({super.key, required this.args});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> with WidgetsBindingObserver, ValidationMixin {
  final _formKey = GlobalKey<FormState>();
  final _areaNameEc = TextEditingController();
  final _apartmentNoEc = TextEditingController();
  final _floorNoEc = TextEditingController();
  final _streetNameEc = TextEditingController();
  final _mobileEc = TextEditingController();
  final _badgeEc = TextEditingController();
  final _addressNameEc = TextEditingController();

  final _areaNameFocusNode = FocusNode();
  final _apartmentNoFocusNode = FocusNode();
  final _floorNoFocusNode = FocusNode();
  final _streetNameFocusNode = FocusNode();
  final _badgeFocusNode = FocusNode();
  final _mobileFocusNode = FocusNode();
  final _addressNameFocusNode = FocusNode();

  Country? _country;

  StreamSubscription<Position>? positionStream;
  List<Placemark>? placemarks;
  double? currentLat;
  double? currentLng;
  GoogleMapController? gmc;
  Set<Marker> markers = {};
  // Timer? _debounce;

  final LocationService _locationService = LocationService();
  // LocationData? _currentLocation;

  Future<void> _determinePosition() async {
    try {
      final location = await _locationService.getCurrentLocation();
      if (location != null) {
        _updateLocation(location.latitude!, location.longitude!);
      }
    } catch (e) {
      log('Failed to get location: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _setupLocationListeners();
    _determinePosition();
    WidgetsBinding.instance.addObserver(this);
  }

  void _setupLocationListeners() {
    _locationService.listenToLocation((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        _updateLocation(locationData.latitude!, locationData.longitude!);
      }
    });
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }

  // In _AddAddressScreenState
  void _updateLocation(double lat, double lng) async {
    setState(() {
      currentLat = lat;
      currentLng = lng;
      markers.clear();
      markers.add(Marker(markerId: const MarkerId('currentLocation'), position: LatLng(lat, lng)));
    });

    if (gmc != null) {
      gmc!.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
    }

    placemarks = await placemarkFromCoordinates(lat, lng);
    setState(() {
      // log(placemarks![0].locality.toString());
      // log(placemarks![0].country.toString());
    });
  }

  // Future<void> _resumeLocationTracking() async {
  //   _locationService.resumeLocationStream();
  //   await _determinePosition();
  // }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) => AddressController(),
      child: Consumer<AddressController>(
        builder: (context, addressController, _) {
          final authController = Provider.of<AuthController>(context);
          return Form(
            key: _formKey,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: AppColors.whiteColor,
                centerTitle: false,
                automaticallyImplyLeading: false,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => NamedNavigatorImpl.pop(),
                        child: SvgPicture.asset(AppImages.backIosIcon),
                      ),
                      const SizedBox(width: 24),
                      Text('addresses'.tr, style: AppTextStyle.text18BS()),
                    ],
                  ),
                ),
              ),
              body: PageContainer(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                    padding: const EdgeInsets.all(5),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatarWidget(
                              gender: authController.profile?.gender,
                              name: authController.profile?.name,
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authController.profile?.name ?? '',
                                  style: AppTextStyle.text18MS(),
                                ),
                                5.sbH,
                                Row(
                                  children: [
                                    SvgPicture.asset(AppImages.egyptIcon),
                                    const SizedBox(width: 10),
                                    Text(
                                      Provider.of<AuthController>(
                                            context,
                                            listen: false,
                                          ).profile?.areaTitle ??
                                          '',
                                      style: AppTextStyle.text16RG(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
                            child: SizedBox(
                              height: context.height * 0.5,
                              child: currentLat != null && currentLng != null
                                  ? GoogleMap(
                                      onTap: (latlng) {
                                        // _updateLocation(
                                        //     latlng.latitude,
                                        //     latlng.longitude);
                                        NamedNavigatorImpl.push(
                                          MapScreen.routeName,
                                          arguments: MapScreenArgs(
                                            onBack: (lat, lng) {
                                              _locationService.pauseLocationStream();
                                              _updateLocation(lat, lng);
                                            },
                                          ),
                                        );
                                      },
                                      markers: {
                                        Marker(
                                          markerId: const MarkerId('currentLocation'),
                                          position: LatLng(currentLat!, currentLng!),
                                        ),
                                      },
                                      mapType: MapType.normal,
                                      onMapCreated: (GoogleMapController controller) {
                                        gmc = controller;
                                        if (addressController.addressDetails != null) {
                                          gmc!.animateCamera(
                                            CameraUpdate.newLatLng(LatLng(currentLat!, currentLng!)),
                                          );
                                        }
                                      },
                                      initialCameraPosition: CameraPosition(
                                        target: LatLng(currentLat!, currentLng!),
                                        zoom: 12,
                                      ),
                                    )
                                  : const Center(child: CustomLoading()),
                            ),
                          ),
                        ),
                        10.sbH,
                        ChangeAddressWidget(addressController: addressController, placemarks: placemarks),
                        const TypeAddressWidget(),
                        const SizedBox(height: 16),
                        CustomFormField(
                          controller: _areaNameEc,
                          validator: validateEmptyField,
                          hintText: 'buildingName'.tr,
                          focusNode: _areaNameFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_apartmentNoFocusNode);
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: CustomFormField(
                                controller: _apartmentNoEc,
                                validator: validateEmptyField,
                                keyboardType: TextInputType.number,
                                hintText: 'apartmentNumber'.tr,
                                focusNode: _apartmentNoFocusNode,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_floorNoFocusNode);
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: CustomFormField(
                                controller: _floorNoEc,
                                validator: validateEmptyField,
                                keyboardType: TextInputType.number,
                                hintText: 'theRoleIsOptional'.tr,
                                focusNode: _floorNoFocusNode,
                                onFieldSubmitted: (_) {
                                  FocusScope.of(context).requestFocus(_streetNameFocusNode);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomFormField(
                          controller: _streetNameEc,
                          validator: validateEmptyField,
                          hintText: 'street'.tr,
                          focusNode: _streetNameFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_badgeFocusNode);
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomFormField(
                          controller: _badgeEc,
                          hintText: 'optionalDistinctiveSign'.tr,
                          focusNode: _badgeFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_mobileFocusNode);
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomFormField(
                          validator: (v) => validatePhone(v, country: _country),
                          controller: _mobileEc,
                          keyboardType: TextInputType.number,
                          hintText: 'mobileNumber'.tr,
                          country: _country,
                          focusNode: _mobileFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context).requestFocus(_addressNameFocusNode);
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomFormField(
                          controller: _addressNameEc,
                          focusNode: _addressNameFocusNode,
                          hintText: 'titleLabelIsOptional'.tr,
                        ),
                        15.sbH,
                        CustomButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AddressController>().storeAddress(
                                    areaName: _areaNameEc.text,
                                    apartmentNo: _apartmentNoEc.text,
                                    floorNo: _floorNoEc.text,
                                    streetName: _streetNameEc.text,
                                    mobile: _mobileEc.text,
                                    addressName: _addressNameEc.text,
                                    type: addressController.indexSelectedOfficeOrHouseOrApartment == 'office'
                                        ? 'office'
                                        : addressController.indexSelectedOfficeOrHouseOrApartment == 'home'
                                            ? 'home'
                                            : 'apartment',
                                    lat: currentLat ??
                                        double.parse(addressController.addressDetails?.lat.toString() ?? '0'),
                                    lang: currentLng ??
                                        double.parse(addressController.addressDetails?.lng.toString() ?? '0'),
                                    countryName:
                                        placemarks![0].country ?? addressController.addressDetails?.countryName ?? '',
                                    cityName:
                                        placemarks![0].locality ?? addressController.addressDetails?.cityName ?? '',
                                    address: placemarks![0].street ?? addressController.addressDetails?.address ?? '',
                                    badge: _badgeEc.text,
                                    onSuccess: ({int? userAddressId}) {
                                      NamedNavigatorImpl.pop();
                                      context.read<AuthController>().getProfile();
                                      widget.args.onSuccess.call();
                                    },
                                  );
                            }
                          },
                          text: 'addAddress'.tr,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
