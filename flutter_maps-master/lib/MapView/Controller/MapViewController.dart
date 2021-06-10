// Method for retrieving the current location
import 'package:flutter/material.dart';
import 'package:flutter_maps/model/place_search.dart';
import 'package:flutter_maps/service/CameraService.dart';
import 'package:flutter_maps/service/LocationService.dart';
import 'package:flutter_maps/service/Places_Service.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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
  RxString findedAddress = ''.obs;
  RxString pointAddress = ''.obs;

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
      await getCurrentAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the current address
  getCurrentAddress() async {
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

  //Method for retrieving the point address
  Future<void> getPointAddress(double latitude, double longitude) async {
    pointAddress.value = "";
    try {
      List<Placemark> p = await placemarkFromCoordinates(latitude, longitude);

      Placemark place = p[0];
      pointAddress.value =
          "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
      print(pointAddress.value);
      //startAddressController.value.text = currentAddress.value;
      //startAddress.value = currentAddress.value;
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> calculateDistance() async {
    try {
      if (await locationService.makeMarkers(
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

  Future<bool> findPlace(String placeName) async {
    print(placeName);
    if (placeName != "") {
      if (markers.isNotEmpty) {
        markers.clear();
      }
      if (polylines.isNotEmpty) {
        polylines.clear();
      }
      if (polylineCoordinates.isNotEmpty) {
        polylineCoordinates.clear();
      }
      placeDistance.value = "";
      if (await locationService.makeMarker(placeName, mapController))
        return true;
    }
    return false;
  }

  Future<void> addMarker(LatLng pos) async {
    await getPointAddress(pos.latitude, pos.longitude);
    if (markers.isNotEmpty) {
      markers.clear();
    }
    if (polylines.isNotEmpty) {
      polylines.clear();
    }
    if (polylineCoordinates.isNotEmpty) {
      polylineCoordinates.clear();
    }
    placeDistance.value = "";
    await locationService.pointMarker(
        pointAddress.value, pos.latitude, pos.longitude);
  }
}
