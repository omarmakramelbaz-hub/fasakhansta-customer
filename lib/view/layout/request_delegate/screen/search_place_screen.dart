import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../../../helpers/extensions/extensions.dart';
import '../../../../helpers/routes/app_routers_import.dart';
import '../../../../helpers/theme/app_colors.dart';
import '../../address/model/address_model.dart';
import '../../address/screen/address_screen.dart';
import '../../map/model/place_autocomplete_model/place_autocomplete_model.dart';
import '../../map/utils/map_services.dart';
import '../controller/request_delegate_controller.dart';
import 'select_location_from_map_screen.dart';

class SearchPlaceScreen extends StatefulWidget {
  static const routeName = 'SearchPlaceScreen';

  const SearchPlaceScreen({super.key});

  @override
  State<SearchPlaceScreen> createState() => _SearchPlaceScreenState();
}

class _SearchPlaceScreenState extends State<SearchPlaceScreen> {
  final fromFocusNode = FocusNode();
  final toFocusNode = FocusNode();

  late final MapServices mapServices;
  late final Uuid uuid;
  late RequestDelegateController requestDelegateController;

  Timer? debounce;
  String? sessionToken;
  List<PlaceModel> fromPlaces = [];
  List<PlaceModel> toPlaces = [];
  bool isFromFieldFocused = false;
  bool isToFieldFocused = false;
  bool _listenersBound = false;

  static const _text = Color(0xFF171A1F);
  static const _muted = Color(0xFF8D939C);
  static const _border = Color(0xFFE8EBEF);
  static const _softOrange = Color(0xFFFFF4E8);

  bool _isArabic(BuildContext context) => context.languageCode == 'ar';

  @override
  void initState() {
    super.initState();
    mapServices = MapServices();
    uuid = const Uuid();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    requestDelegateController =
        Provider.of<RequestDelegateController>(context, listen: false);

    if (!_listenersBound) {
      _listenersBound = true;
      requestDelegateController.fromController.addListener(fetchFromPredictions);
      requestDelegateController.toController.addListener(fetchToPredictions);

      if (requestDelegateController.fromController.text.isEmpty &&
          requestDelegateController.fromAddress.isNotEmpty) {
        requestDelegateController.fromController.text =
            requestDelegateController.fromAddress;
      }
    }
  }

  void fetchFromPredictions() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 250), () async {
      if (!mounted) return;
      final input = requestDelegateController.fromController.text.trim();
      if (input.length < 2) {
        fromPlaces = [];
        if (mounted) setState(() {});
        return;
      }
      sessionToken ??= uuid.v4();
      await mapServices.getPredictions(
        input: input,
        sesstionToken: sessionToken!,
        places: fromPlaces,
      );
      if (mounted) setState(() {});
    });
  }

  void fetchToPredictions() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 250), () async {
      if (!mounted) return;
      final input = requestDelegateController.toController.text.trim();
      if (input.length < 2) {
        toPlaces = [];
        if (mounted) setState(() {});
        return;
      }
      sessionToken ??= uuid.v4();
      await mapServices.getPredictions(
        input: input,
        sesstionToken: sessionToken!,
        places: toPlaces,
      );
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    debounce?.cancel();
    if (_listenersBound) {
      requestDelegateController.fromController
          .removeListener(fetchFromPredictions);
      requestDelegateController.toController.removeListener(fetchToPredictions);
    }
    fromFocusNode.dispose();
    toFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RequestDelegateController>(
      builder: (context, controller, _) {
        return Directionality(
          textDirection:
              _isArabic(context) ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: const Color(0xFFFAFAFA),
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: Column(
                children: [
                  _header(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      child: Column(
                        children: [
                          _locationCard(
                            context: context,
                            controller: controller,
                            isFrom: true,
                          ),
                          if (isFromFieldFocused && fromPlaces.isNotEmpty)
                            _predictions(context, controller, fromPlaces, true),
                          const SizedBox(height: 12),
                          _locationCard(
                            context: context,
                            controller: controller,
                            isFrom: false,
                          ),
                          if (isToFieldFocused && toPlaces.isNotEmpty)
                            _predictions(context, controller, toPlaces, false),
                          const SizedBox(height: 12),
                          _savedAddressesCard(context, controller),
                          const SizedBox(height: 12),
                          _privacyCard(context),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: SafeArea(
              top: false,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                child: SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _confirm(controller),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppColors.mainAppColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      _isArabic(context)
                          ? 'تأكيد العناوين'
                          : 'Confirm addresses',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
      child: Row(
        children: [
          _roundIcon(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isArabic(context)
                      ? 'تحديد العناوين'
                      : 'Set addresses',
                  style: const TextStyle(
                    color: _text,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _isArabic(context)
                      ? 'حدد موقعك الحالي وعنوان التوصيل'
                      : 'Set your current and delivery locations',
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Image.asset(
            'assets/images/deliveryRiderV2.png',
            width: 64,
            height: 54,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }

  Widget _locationCard({
    required BuildContext context,
    required RequestDelegateController controller,
    required bool isFrom,
  }) {
    final textController =
        isFrom ? controller.fromController : controller.toController;
    final focusNode = isFrom ? fromFocusNode : toFocusNode;
    final lat = isFrom ? controller.fromLat : controller.toLat;
    final lng = isFrom ? controller.fromLan : controller.toLan;
    final title = isFrom
        ? (_isArabic(context) ? 'موقعي الحالي' : 'Current location')
        : (_isArabic(context) ? 'التوصيل إلى' : 'Deliver to');
    final hint = isFrom
        ? (_isArabic(context)
            ? 'اكتب موقع الاستلام'
            : 'Enter pickup location')
        : (_isArabic(context)
            ? 'اختر أو ابحث عن عنوان التوصيل'
            : 'Choose or search delivery address');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _softOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isFrom
                      ? Icons.my_location_rounded
                      : Icons.location_on_outlined,
                  color: AppColors.mainAppColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (isFrom)
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: Color(0xFF25C862),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Focus(
            onFocusChange: (focused) {
              setState(() {
                if (isFrom) {
                  isFromFieldFocused = focused;
                  if (focused) isToFieldFocused = false;
                } else {
                  isToFieldFocused = focused;
                  if (focused) isFromFieldFocused = false;
                }
              });
            },
            child: TextField(
              controller: textController,
              focusNode: focusNode,
              maxLines: 2,
              minLines: 1,
              style: const TextStyle(
                color: _text,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                suffixIcon: textController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: textController.clear,
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFFADB2BA),
                          size: 18,
                        ),
                      ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: AppColors.mainAppColor,
                    width: 1.3,
                  ),
                ),
              ),
            ),
          ),
          if (lat != null &&
              lng != null &&
              lat.isNotEmpty &&
              lng.isNotEmpty) ...[
            const SizedBox(height: 7),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                '${_shortCoordinate(lat)}, ${_shortCoordinate(lng)}',
                style: const TextStyle(
                  color: _muted,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                FocusManager.instance.primaryFocus?.unfocus();
                NamedNavigatorImpl.push(
                  SelectLocationFromMapScreen.routeName,
                  arguments:
                      SelectLocationFromMapScreenArgs(isFromAddress: isFrom),
                );
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: _softOrange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      color: AppColors.mainAppColor,
                      size: 19,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _isArabic(context)
                          ? 'اختر من الخريطة'
                          : 'Choose from map',
                      style: TextStyle(
                        color: AppColors.mainAppColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _predictions(
    BuildContext context,
    RequestDelegateController controller,
    List<PlaceModel> places,
    bool isFrom,
  ) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: _cardDecoration(),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: places.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, color: _border),
        itemBuilder: (context, index) {
          final place = places[index];
          return ListTile(
            dense: true,
            leading: Icon(
              Icons.location_on_outlined,
              color: AppColors.mainAppColor,
              size: 20,
            ),
            title: Text(
              place.description ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _text,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              final details =
                  await mapServices.getPlaceDetails(placeId: place.placeId!);
              final location = details.geometry?.location;
              if (location == null) return;

              if (isFrom) {
                controller.setFromController(details.formattedAddress ?? '');
                controller.setFromLat(location.lat.toString());
                controller.setFromLan(location.lng.toString());
                controller.setFromLatLng(LatLng(location.lat!, location.lng!));
                fromPlaces = [];
                isFromFieldFocused = false;
              } else {
                controller.setToController(details.formattedAddress ?? '');
                controller.setToLat(location.lat.toString());
                controller.setToLan(location.lng.toString());
                controller.setToLatLng(LatLng(location.lat!, location.lng!));
                toPlaces = [];
                isToFieldFocused = false;
              }

              sessionToken = null;
              FocusManager.instance.primaryFocus?.unfocus();
              if (mounted) setState(() {});
            },
          );
        },
      ),
    );
  }

  Widget _savedAddressesCard(
    BuildContext context,
    RequestDelegateController controller,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _chooseSavedAddress(context, controller),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: _cardDecoration(),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _softOrange,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.list_alt_rounded,
                  color: AppColors.mainAppColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isArabic(context)
                          ? 'العناوين المحفوظة'
                          : 'Saved addresses',
                      style: const TextStyle(
                        color: _text,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _isArabic(context)
                          ? 'اختر عنوانًا محفوظًا للتوصيل'
                          : 'Choose a saved delivery address',
                      style: const TextStyle(color: _muted, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_left_rounded,
                color: Color(0xFFADB2BA),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _chooseSavedAddress(
    BuildContext context,
    RequestDelegateController controller,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final selected = await Navigator.of(context).push<AddressModel>(
      MaterialPageRoute(
        builder: (_) => const AddressScreen(selectForDelivery: true),
      ),
    );

    if (!mounted || selected == null) return;

    final lat = double.tryParse((selected.lat ?? '').trim());
    final lng = double.tryParse((selected.lng ?? '').trim());

    if (lat == null || lng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFFFF4E8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          content: Text(
            _isArabic(context)
                ? 'هذا العنوان لا يحتوي على موقع محدد. عدّله وأضف الموقع أولًا.'
                : 'This saved address has no location. Edit it and add a map location first.',
            style: const TextStyle(
              color: _text,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
      return;
    }

    final label = _savedAddressLabel(selected);
    controller.setToController(label);
    controller.setToAddress(label);
    controller.setToLat(lat.toString());
    controller.setToLan(lng.toString());
    controller.setToLatLng(LatLng(lat, lng));

    toPlaces = [];
    isToFieldFocused = false;
    sessionToken = null;

    controller.calculateDistance(
      kmPrice: controller.delegatesOnMap?.shippingKmPrice ?? 0,
    );
    controller.calculateDeliveryPrice(
      kmPrice: controller.delegatesOnMap?.shippingKmPrice ?? 0,
    );

    if (mounted) setState(() {});
  }

  String _savedAddressLabel(AddressModel address) {
    final directAddress = (address.address ?? '').trim();
    if (directAddress.isNotEmpty) return directAddress;

    final parts = <String>[
      if ((address.streetName ?? '').trim().isNotEmpty)
        address.streetName!.trim(),
      if ((address.areaName ?? '').trim().isNotEmpty) address.areaName!.trim(),
      if ((address.cityName ?? address.cityname ?? '').trim().isNotEmpty)
        (address.cityName ?? address.cityname)!.trim(),
      if ((address.countryName ?? '').trim().isNotEmpty)
        address.countryName!.trim(),
      if ((address.floorNo ?? '').trim().isNotEmpty)
        '${_isArabic(context) ? 'الدور' : 'Floor'} ${address.floorNo!.trim()}',
      if ((address.apartmentNo ?? '').trim().isNotEmpty)
        '${_isArabic(context) ? 'شقة' : 'Apt'} ${address.apartmentNo!.trim()}',
    ];

    return parts.toSet().join(' - ');
  }

  Widget _privacyCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softOrange,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: AppColors.mainAppColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isArabic(context) ? 'خصوصيتك تهمنا' : 'Your privacy matters',
                  style: const TextStyle(
                    color: _text,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _isArabic(context)
                      ? 'نستخدم موقعك فقط لتحسين تجربة التوصيل ووصول طلبك بدقة.'
                      : 'Your location is used only to improve delivery accuracy.',
                  style: const TextStyle(
                    color: Color(0xFF6F747C),
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundIcon({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      shadowColor: const Color(0x22000000),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: AppColors.mainAppColor, size: 23),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: _border),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0D000000),
          blurRadius: 14,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  String _shortCoordinate(String value) {
    final number = double.tryParse(value);
    return number?.toStringAsFixed(5) ?? value;
  }

  void _confirm(RequestDelegateController controller) {
    controller.setFromAddress(controller.fromController.text.trim());
    controller.setToAddress(controller.toController.text.trim());

    if (controller.fromLatLng != null) {
      controller.setFromLat(controller.fromLatLng!.latitude.toString());
      controller.setFromLan(controller.fromLatLng!.longitude.toString());
    }
    if (controller.toLatLng != null) {
      controller.setToLat(controller.toLatLng!.latitude.toString());
      controller.setToLan(controller.toLatLng!.longitude.toString());
    }

    controller.calculateDistance(
      kmPrice: controller.delegatesOnMap?.shippingKmPrice ?? 0,
    );
    controller.calculateDeliveryPrice(
      kmPrice: controller.delegatesOnMap?.shippingKmPrice ?? 0,
    );

    log('delivery distance ${controller.distance}');
    Navigator.of(context).pop();
  }
}
