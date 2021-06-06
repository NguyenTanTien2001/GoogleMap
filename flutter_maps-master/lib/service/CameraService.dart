import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'GoogleMapService.dart';

class CameraService {
  CameraPosition initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  final GGMapService = Get.find<GoogleMapService>();

  void cameraPositionUpdate(GoogleMapController mapController, double latitude,
      double longitude, double zoomLevel) {
    try {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: zoomLevel,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }

  void cameraLatlngboundUpdate(
      GoogleMapController mapController,
      double northEastLatitude,
      double northEastLongitude,
      double southWestLatitude,
      double southWestLongitude,
      double zoomLevel) {
    try {
      mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            northeast: LatLng(northEastLatitude, northEastLongitude),
            southwest: LatLng(southWestLatitude, southWestLongitude),
          ),
          zoomLevel,
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
