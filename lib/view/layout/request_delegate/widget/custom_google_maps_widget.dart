import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';

import '../../../../helpers/theme/app_colors.dart';
import '../../../../helpers/utils/location_service.dart';
import '../controller/request_delegate_controller.dart';

class CustomGoogleMapsWidget extends StatefulWidget {
  const CustomGoogleMapsWidget({
    super.key,
    required this.addressLat,
    required this.addressLan,
    this.showCircle,
  });

  final double addressLat;
  final double addressLan;
  final bool? showCircle;

  @override
  State<CustomGoogleMapsWidget> createState() =>
      _CustomGoogleMapsWidgetState();
}

class _CustomGoogleMapsWidgetState extends State<CustomGoogleMapsWidget> {
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

  CameraPosition? initialCameraPosition;
  GoogleMapController? googleMapController;
  Set<Marker> markers = {};
  Set<Circle> circles = {};

  late Location location;
  late LocationService locationService;
  bool isFirstCall = true;

  @override
  void initState() {
    initialCameraPosition = CameraPosition(
      target: LatLng(widget.addressLat, widget.addressLan),
      zoom: 14.5,
    );

    locationService = LocationService();
    initialDelegatesOnMap();
    initCircles();
    setMyLocationMarker();
    super.initState();
  }

  @override
  void dispose() {
    googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      circles: circles,
      zoomControlsEnabled: false,
      style: _cleanLightMapStyle,
      markers: markers,
      mapToolbarEnabled: false,
      compassEnabled: false,
      myLocationButtonEnabled: false,
      minMaxZoomPreference: const MinMaxZoomPreference(10.0, 19.0),
      onMapCreated: (controller) {
        googleMapController = controller;
      },
      initialCameraPosition: initialCameraPosition ??
          CameraPosition(
            target: LatLng(widget.addressLat, widget.addressLan),
            zoom: 14.5,
          ),
    );
  }

  void setMyLocationMarker() async {
    final customMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      'assets/images/markerIcon.png',
      height: 46,
    );
    final myLocationMarker = Marker(
      icon: customMarkerIcon,
      markerId: const MarkerId('my_location'),
      position: LatLng(widget.addressLat, widget.addressLan),
      zIndexInt: 10,
    );
    markers.add(myLocationMarker);
    if (mounted) {
      setState(() {});
    }
  }

  void initCircles() {
    if (widget.showCircle == true) {
      circles.add(
        Circle(
          circleId: const CircleId('currentLocation'),
          center: LatLng(widget.addressLat, widget.addressLan),
          radius: 1000,
          fillColor: AppColors.mainAppColor.withValues(alpha: .08),
          strokeColor: AppColors.mainAppColor.withValues(alpha: .48),
          strokeWidth: 1,
        ),
      );
    }
  }

  void initialDelegatesOnMap() async {
    final requestDelegateController =
        Provider.of<RequestDelegateController>(context, listen: false);
    final acceptedDelegates = requestDelegateController.acceptedDelegate?.delegates;
    final customMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(),
      'assets/images/deliveryRiderV2.png',
      height: 58,
    );

    if (acceptedDelegates != null) {
      for (final delegate in acceptedDelegates) {
        final lat = double.tryParse(delegate.lat.toString());
        final lng = double.tryParse(delegate.lng.toString());
        if (lat == null || lng == null || lat == 0 || lng == 0) continue;

        markers.add(
          Marker(
            markerId: MarkerId(delegate.id.toString()),
            position: LatLng(lat, lng),
            icon: customMarkerIcon,
            zIndexInt: 8,
            infoWindow: InfoWindow(
              title: delegate.name,
              snippet: delegate.name,
            ),
          ),
        );
      }
      if (mounted) {
        setState(() {});
      }
    }
  }
}
