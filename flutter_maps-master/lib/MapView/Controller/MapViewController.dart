// Method for retrieving the current location
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/model/place_search.dart';
import 'package:flutter_maps/service/CameraService.dart';
import 'package:flutter_maps/service/LocationService.dart';
import 'package:flutter_maps/service/Places_Service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_maps/secrets.dart';

class MapviewController extends GetxController {
  final panelHeight = 293.0.obs;

  final camService = Get.find<CameraService>();
  final locationService = Get.find<LocationService>();
  final placeService = Get.find<PlacesService>();

  //map controlls
  RxMap<PolylineId, Polyline> polylines = RxMap();
  RxList<LatLng> polylineCoordinates = RxList();
  RxSet<Marker> markers = RxSet();
  Rx<MapType> mapType = MapType.normal.obs;

  final startAddressController = TextEditingController().obs;
  final destinationAddressController = TextEditingController().obs;

  final startAddressFocusNode = FocusNode();
  final desrinationAddressFocusNode = FocusNode();

  RxString currentAddress = ''.obs;
  RxString startAddress = ''.obs;
  RxString destinationAddress = ''.obs;

  RxString placeDistance = ''.obs;

  late RxList<PlaceSearch> searchResults = RxList();

  late GoogleMapController mapController;
  Position currentPosition = Position(
      longitude: 0.0,
      latitude: 0.0,
      timestamp: null,
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0);
  Future<void> getCurrentLocation() async {
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      currentPosition = position;
      print('CURRENT POS: $currentPosition');
      camService.cameraPositionUpdate(
          mapController, position.latitude, position.longitude, 18.0);
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await placemarkFromCoordinates(
          currentPosition.latitude, currentPosition.longitude);

      Placemark place = p[0];
      currentAddress.value =
          "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
      print(currentAddress);
      //startAddressController.value.text = currentAddress.value;
      //startAddress.value = currentAddress.value;
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> calculateDistance() async {
    try {
      if (await locationService.makeMarker(
          startAddress.value,
          destinationAddress.value,
          currentAddress.value,
          currentPosition)) await locationService.setupPolyline(mapController);

      placeDistance.value = locationService
          .distanceCalculate(polylineCoordinates)
          .toStringAsFixed(2);
      print('DISTANCE: ${placeDistance.value} km');

      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  void findPlace(String placeName) async {
    searchResults.value = await placeService.getAutocomplete(placeName);
  }
}