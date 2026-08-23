import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/translation/all_translation.dart';
import '../../../../helpers/utils/common_methods.dart';
import '../../../../helpers/utils/location_service.dart';
import '../../../custom_widgets/validation/validation_mixin.dart';
import '../../auth/controller/auth_controller.dart';
import '../controller/address_controller.dart';
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

class _AddAddressScreenState extends State<AddAddressScreen>
    with ValidationMixin {
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
  List<Placemark>? placemarks;
  double? currentLat;
  double? currentLng;
  GoogleMapController? gmc;
  final LocationService _locationService = LocationService();

  static const _text = Color(0xFF171A1F);
  static const _muted = Color(0xFF858B94);
  static const _border = Color(0xFFE7EAEE);
  static const _surface = Color(0xFFF8F9FA);
  static const _softOrange = Color(0xFFFFF3E7);

  static const String _cleanLightMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#f7f7f5"}]},
  {"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#6f747b"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#ffffff"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#e7e9eb"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#cfefff"}]}
]
''';

  bool _isArabic(BuildContext context) => context.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    _setupLocationListeners();
    _determinePosition();
  }

  void _setupLocationListeners() {
    _locationService.listenToLocation((locationData) {
      if (locationData.latitude != null && locationData.longitude != null) {
        _updateLocation(locationData.latitude!, locationData.longitude!);
      }
    });
  }

  Future<void> _determinePosition() async {
    try {
      final location = await _locationService.getCurrentLocation();
      if (location?.latitude != null && location?.longitude != null) {
        await _updateLocation(location!.latitude!, location.longitude!);
      }
    } catch (e) {
      log('Failed to get address location: $e');
    }
  }

  Future<void> _updateLocation(double lat, double lng) async {
    if (!mounted) return;
    setState(() {
      currentLat = lat;
      currentLng = lng;
    });

    if (gmc != null) {
      await gmc!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: LatLng(lat, lng), zoom: 14.5),
        ),
      );
    }

    try {
      final result = await placemarkFromCoordinates(lat, lng);
      if (!mounted) return;
      setState(() => placemarks = result);
    } catch (e) {
      log('Address reverse geocoding failed: $e');
    }
  }

  void _openMapPicker() {
    FocusManager.instance.primaryFocus?.unfocus();
    NamedNavigatorImpl.push(
      MapScreen.routeName,
      arguments: MapScreenArgs(
        onBack: (lat, lng) {
          _locationService.pauseLocationStream();
          _updateLocation(lat, lng);
        },
      ),
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    gmc?.dispose();

    _areaNameEc.dispose();
    _apartmentNoEc.dispose();
    _floorNoEc.dispose();
    _streetNameEc.dispose();
    _mobileEc.dispose();
    _badgeEc.dispose();
    _addressNameEc.dispose();

    _areaNameFocusNode.dispose();
    _apartmentNoFocusNode.dispose();
    _floorNoFocusNode.dispose();
    _streetNameFocusNode.dispose();
    _badgeFocusNode.dispose();
    _mobileFocusNode.dispose();
    _addressNameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AddressController(),
      child: Consumer<AddressController>(
        builder: (context, addressController, _) {
          final isArabic = _isArabic(context);
          return Directionality(
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: const Color(0xFFF7F8FA),
              appBar: _appBar(context),
              body: SafeArea(
                top: false,
                child: Form(
                  key: _formKey,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final keyboardOpen =
                          MediaQuery.of(context).viewInsets.bottom > 0;
                      final compact = constraints.maxHeight < 760;
                      final mapHeight = compact ? 155.0 : 205.0;

                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 620),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(
                              14,
                              compact ? 8 : 10,
                              14,
                              compact ? 8 : 10,
                            ),
                            child: Column(
                              children: [
                                _intro(context, compact),
                                if (!keyboardOpen) ...[
                                  SizedBox(height: compact ? 7 : 9),
                                  _mapCard(
                                    context,
                                    addressController,
                                    height: mapHeight,
                                  ),
                                  SizedBox(height: compact ? 7 : 9),
                                ] else ...[
                                  const SizedBox(height: 5),
                                  _compactLocationBar(context),
                                  const SizedBox(height: 6),
                                ],
                                _typeSelector(context, addressController, compact),
                                SizedBox(height: compact ? 6 : 8),
                                Expanded(
                                  child: _formGrid(context, compact),
                                ),
                                SizedBox(height: compact ? 6 : 8),
                                _saveButton(context, addressController, compact),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    final isArabic = _isArabic(context);
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      automaticallyImplyLeading: false,
      toolbarHeight: 60,
      titleSpacing: 12,
      title: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => NamedNavigatorImpl.pop(),
              borderRadius: BorderRadius.circular(22),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  isArabic
                      ? Icons.arrow_forward_rounded
                      : Icons.arrow_back_rounded,
                  color: AppColors.mainAppColor,
                  size: 25,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isArabic ? 'إضافة عنوان' : 'Add address',
            style: const TextStyle(
              color: _text,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _intro(BuildContext context, bool compact) {
    return Row(
      children: [
        Container(
          width: compact ? 38 : 42,
          height: compact ? 38 : 42,
          decoration: BoxDecoration(
            color: _softOrange,
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            Icons.location_on_outlined,
            color: AppColors.mainAppColor,
            size: compact ? 21 : 23,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isArabic(context)
                    ? 'حدد موقع العنوان وأكمل البيانات'
                    : 'Set the location and complete the details',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _text,
                  fontSize: compact ? 14.5 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isArabic(context)
                    ? 'كل البيانات في شاشة واحدة بدون سكرول'
                    : 'All address details on one screen',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _muted,
                  fontSize: compact ? 10 : 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _mapCard(
    BuildContext context,
    AddressController addressController, {
    required double height,
  }) {
    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: currentLat == null || currentLng == null
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.mainAppColor,
                strokeWidth: 2.4,
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: GoogleMap(
                    style: _cleanLightMapStyle,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(currentLat!, currentLng!),
                      zoom: 14.5,
                    ),
                    markers: {
                      Marker(
                        markerId: const MarkerId('addressLocation'),
                        position: LatLng(currentLat!, currentLng!),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueOrange,
                        ),
                      ),
                    },
                    zoomControlsEnabled: false,
                    myLocationButtonEnabled: false,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    onTap: (_) => _openMapPicker(),
                    onMapCreated: (controller) {
                      gmc = controller;
                      if (addressController.addressDetails != null) {
                        controller.animateCamera(
                          CameraUpdate.newLatLng(
                            LatLng(currentLat!, currentLng!),
                          ),
                        );
                      }
                    },
                  ),
                ),
                PositionedDirectional(
                  top: 9,
                  start: 9,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x12000000),
                          blurRadius: 8,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 16,
                          color: AppColors.mainAppColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _isArabic(context)
                              ? 'اضغط لتعديل الموقع'
                              : 'Tap to adjust location',
                          style: const TextStyle(
                            color: _text,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  left: 9,
                  right: 9,
                  bottom: 9,
                  child: _locationInfo(context),
                ),
              ],
            ),
    );
  }

  Widget _locationInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.96),
        borderRadius: BorderRadius.circular(13),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color: AppColors.mainAppColor,
            size: 18,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _resolvedAddress(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _text,
                fontSize: 10.8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (currentLat != null && currentLng != null)
            Text(
              '${currentLat!.toStringAsFixed(4)}, ${currentLng!.toStringAsFixed(4)}',
              style: const TextStyle(
                color: _muted,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _compactLocationBar(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: _openMapPicker,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _border),
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                color: AppColors.mainAppColor,
                size: 19,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  _resolvedAddress(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.edit_location_alt_outlined,
                color: AppColors.mainAppColor,
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _typeSelector(
    BuildContext context,
    AddressController controller,
    bool compact,
  ) {
    final options = <({String value, String ar, String en, IconData icon})>[
      (
        value: 'apartment',
        ar: 'شقة',
        en: 'Apartment',
        icon: Icons.apartment_rounded,
      ),
      (
        value: 'home',
        ar: 'منزل',
        en: 'Home',
        icon: Icons.home_outlined,
      ),
      (
        value: 'office',
        ar: 'مكتب',
        en: 'Office',
        icon: Icons.business_center_outlined,
      ),
    ];

    return Row(
      children: [
        for (int i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 7),
          Expanded(
            child: _typeChip(
              context,
              controller,
              value: options[i].value,
              label: _isArabic(context) ? options[i].ar : options[i].en,
              icon: options[i].icon,
              compact: compact,
            ),
          ),
        ],
      ],
    );
  }

  Widget _typeChip(
    BuildContext context,
    AddressController controller, {
    required String value,
    required String label,
    required IconData icon,
    required bool compact,
  }) {
    final selected = controller.indexSelectedOfficeOrHouseOrApartment == value;
    return Material(
      color: selected ? _softOrange : Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => controller.setIndexSelectedOfficeOrHouseOrApartment(value),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: compact ? 40 : 44,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.mainAppColor : _border,
              width: selected ? 1.2 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: compact ? 17 : 19,
                color: selected ? AppColors.mainAppColor : _muted,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? AppColors.mainAppColor : _text,
                    fontSize: compact ? 11 : 12,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _formGrid(BuildContext context, bool compact) {
    final gap = compact ? 6.0 : 8.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _fieldRow(
          _field(
            context,
            controller: _areaNameEc,
            focusNode: _areaNameFocusNode,
            hint: 'buildingName'.tr,
            icon: Icons.domain_outlined,
            validator: validateEmptyField,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_streetNameFocusNode),
          ),
          _field(
            context,
            controller: _streetNameEc,
            focusNode: _streetNameFocusNode,
            hint: 'street'.tr,
            icon: Icons.signpost_outlined,
            validator: validateEmptyField,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_apartmentNoFocusNode),
          ),
          gap,
        ),
        _fieldRow(
          _field(
            context,
            controller: _apartmentNoEc,
            focusNode: _apartmentNoFocusNode,
            hint: 'apartmentNumber'.tr,
            icon: Icons.door_front_door_outlined,
            keyboardType: TextInputType.number,
            validator: validateEmptyField,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_floorNoFocusNode),
          ),
          _field(
            context,
            controller: _floorNoEc,
            focusNode: _floorNoFocusNode,
            hint: 'theRoleIsOptional'.tr,
            icon: Icons.stairs_outlined,
            keyboardType: TextInputType.number,
            validator: validateEmptyField,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_mobileFocusNode),
          ),
          gap,
        ),
        _fieldRow(
          _field(
            context,
            controller: _mobileEc,
            focusNode: _mobileFocusNode,
            hint: 'mobileNumber'.tr,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) => validatePhone(v, country: _country),
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_addressNameFocusNode),
          ),
          _field(
            context,
            controller: _addressNameEc,
            focusNode: _addressNameFocusNode,
            hint: 'titleLabelIsOptional'.tr,
            icon: Icons.bookmark_border_rounded,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_badgeFocusNode),
          ),
          gap,
        ),
        _field(
          context,
          controller: _badgeEc,
          focusNode: _badgeFocusNode,
          hint: 'optionalDistinctiveSign'.tr,
          icon: Icons.near_me_outlined,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        ),
      ],
    );
  }

  Widget _fieldRow(Widget first, Widget second, double gap) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: first),
        SizedBox(width: gap),
        Expanded(child: second),
      ],
    );
  }

  Widget _field(
    BuildContext context, {
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction ?? TextInputAction.next,
      onFieldSubmitted: onSubmitted,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      style: const TextStyle(
        color: _text,
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: const TextStyle(
          color: _muted,
          fontSize: 11.5,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF9AA0A8)),
        prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 42),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        errorStyle: const TextStyle(fontSize: 8.5, height: .9),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.mainAppColor, width: 1.3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE35B5B)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE35B5B)),
        ),
      ),
    );
  }

  Widget _saveButton(
    BuildContext context,
    AddressController addressController,
    bool compact,
  ) {
    return SizedBox(
      width: double.infinity,
      height: compact ? 48 : 52,
      child: ElevatedButton(
        onPressed: () => _saveAddress(context, addressController),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: AppColors.mainAppColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          _isArabic(context) ? 'حفظ العنوان' : 'Save address',
          style: TextStyle(
            fontSize: compact ? 15 : 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  void _saveAddress(
    BuildContext context,
    AddressController addressController,
  ) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) return;

    final fallback = addressController.addressDetails;
    final lat = currentLat ?? double.tryParse('${fallback?.lat ?? ''}');
    final lng = currentLng ?? double.tryParse('${fallback?.lng ?? ''}');

    if (lat == null || lng == null || lat == 0 || lng == 0) {
      CommonMethods.showError(
        message: _isArabic(context)
            ? 'من فضلك حدد موقع العنوان على الخريطة أولاً'
            : 'Please select the address location on the map first',
      );
      return;
    }

    final place = placemarks?.isNotEmpty == true ? placemarks!.first : null;
    final streetFromMap = (place?.street ?? '').trim();

    context.read<AddressController>().storeAddress(
          areaName: _areaNameEc.text.trim(),
          apartmentNo: _apartmentNoEc.text.trim(),
          floorNo: _floorNoEc.text.trim(),
          streetName: _streetNameEc.text.trim(),
          mobile: _mobileEc.text.trim(),
          addressName: _addressNameEc.text.trim(),
          type: addressController.indexSelectedOfficeOrHouseOrApartment,
          lat: lat,
          lang: lng,
          countryName: place?.country ?? fallback?.countryName ?? '',
          cityName: place?.locality ?? fallback?.cityName ?? '',
          address: streetFromMap.isNotEmpty
              ? streetFromMap
              : (fallback?.address ?? _streetNameEc.text.trim()),
          badge: _badgeEc.text.trim(),
          onSuccess: ({int? userAddressId}) {
            NamedNavigatorImpl.pop();
            context.read<AuthController>().getProfile();
            widget.args.onSuccess.call();
          },
        );
  }

  String _resolvedAddress(BuildContext context) {
    final place = placemarks?.isNotEmpty == true ? placemarks!.first : null;
    final parts = <String>[
      if ((place?.street ?? '').trim().isNotEmpty) place!.street!.trim(),
      if ((place?.subLocality ?? '').trim().isNotEmpty)
        place!.subLocality!.trim(),
      if ((place?.locality ?? '').trim().isNotEmpty) place!.locality!.trim(),
    ];

    if (parts.isNotEmpty) return parts.toSet().join('، ');
    if (currentLat != null && currentLng != null) {
      return '${currentLat!.toStringAsFixed(5)}, ${currentLng!.toStringAsFixed(5)}';
    }
    return _isArabic(context)
        ? 'جاري تحديد موقعك...'
        : 'Locating your address...';
  }
}
