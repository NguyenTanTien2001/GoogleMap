import 'package:flutter/material.dart';
import 'package:flutter_maps/MapView/Controller/MapViewController.dart';
import 'package:flutter_maps/service/CameraService.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import 'dart:math' show cos, sqrt, asin;

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'GoogleMapService.dart';

class LocationService {
  final GGMapService = Get.find<GoogleMapService>();
  final camService = Get.find<CameraService>();

  //Location Calculate
  double startLatitude = 0.0;
  double startLongitude = 0.0;
  double destinationLatitude = 0.0;
  double destinationLongitude = 0.0;

  //search place
  double findedLatitude = 0.0;
  double findedLongitude = 0.0;

  //Create and place the marker on the map
  Future<bool> makeMarkers(
    String startAddress,
    String destinationAddress,
    String currentAddress,
    Position currentPosition,
  ) async {
    final mapViewController = Get.find<MapviewController>();
    // Retrieving placemarks from addresses
    List<Location> startPlacemark = await locationFromAddress(startAddress);
    List<Location> destinationPlacemark =
        await locationFromAddress(destinationAddress);

    // Use the retrieved coordinates of the current position,
    // instead of the address if the start position is user's
    // current position, as it results in better accuracy.
    startLatitude = startAddress == currentAddress
        ? currentPosition.latitude
        : startPlacemark[0].latitude;

    startLongitude = startAddress == currentAddress
        ? currentPosition.longitude
        : startPlacemark[0].longitude;

    destinationLatitude = destinationPlacemark[0].latitude;
    destinationLongitude = destinationPlacemark[0].longitude;

    String startCoordinatesString = '($startLatitude, $startLongitude)';
    String destinationCoordinatesString =
        '($destinationLatitude, $destinationLongitude)';

    // Start Location Marker
    Marker startMarker = Marker(
      markerId: MarkerId(startCoordinatesString),
      position: LatLng(startLatitude, startLongitude),
      infoWindow: InfoWindow(
        title: 'Start $startCoordinatesString',
        snippet: startAddress,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    // Destination Location Marker
    Marker destinationMarker = Marker(
      markerId: MarkerId(destinationCoordinatesString),
      position: LatLng(destinationLatitude, destinationLongitude),
      infoWindow: InfoWindow(
        title: 'Destination $destinationCoordinatesString',
        snippet: destinationAddress,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    // Adding the markers to the list
    mapViewController.markers.add(startMarker);
    mapViewController.markers.add(destinationMarker);

    print(
      'START COORDINATES: ($startLatitude, $startLongitude)',
    );
    print(
      'DESTINATION COORDINATES: ($destinationLatitude, $destinationLongitude)',
    );
    return true;
  }

  //Create Polylines on the Map
  Future<bool> setupPolyline(GoogleMapController mapController) async {
    // Calculating to check that the position relative
    // to the frame, and pan & zoom the camera accordingly.
    double miny = (startLatitude <= destinationLatitude)
        ? startLatitude
        : destinationLatitude;
    double minx = (startLongitude <= destinationLongitude)
        ? startLongitude
        : destinationLongitude;
    double maxy = (startLatitude <= destinationLatitude)
        ? destinationLatitude
        : startLatitude;
    double maxx = (startLongitude <= destinationLongitude)
        ? destinationLongitude
        : startLongitude;

    double southWestLatitude = miny;
    double southWestLongitude = minx;

    double northEastLatitude = maxy;
    double northEastLongitude = maxx;

    // Accommodate the two locations within the
    // camera view of the map
    camService.cameraLatlngboundUpdate(mapController, northEastLatitude,
        northEastLongitude, southWestLatitude, southWestLongitude, 100.0);

    // Calculating the distance between the start and the end positions
    // with a straight path, without considering any route
    // double distanceInMeters = await Geolocator.bearingBetween(
    //   startLatitude,
    //   startLongitude,
    //   destinationLatitude,
    //   destinationLongitude,
    // );

    await GGMapService.createPolylines(startLatitude, startLongitude,
        destinationLatitude, destinationLongitude);
    return true;
  }

  //calculate the distance using the Polyline
  double distanceCalculate(List<LatLng> polylineCoordinates) {
    double totalDistance = 0.0;

    // Calculating the total distance by adding the distance
    // between small segments
    for (int i = 0; i < polylineCoordinates.length - 1; i++) {
      totalDistance += _coordinateDistance(
        polylineCoordinates[i].latitude,
        polylineCoordinates[i].longitude,
        polylineCoordinates[i + 1].latitude,
        polylineCoordinates[i + 1].longitude,
      );
    }
    return totalDistance;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  //find a place and make marker
  Future<bool> makeMarker(
      String placeName, GoogleMapController mapController) async {
    final mapViewController = Get.find<MapviewController>();
    List<Location> findedPlacemark = await locationFromAddress(placeName);
    print(
        "FindPlaceMent: ${findedPlacemark[0].latitude}, ${findedPlacemark[0].longitude}");
    if (findedPlacemark.isNotEmpty) {
      findedLatitude = findedPlacemark[0].latitude;
      findedLongitude = findedPlacemark[0].longitude;
      String findedCoordinatesString = '($findedLatitude, $findedLongitude)';

      Marker findedMarker = Marker(
        markerId: MarkerId(findedCoordinatesString),
        position: LatLng(findedLatitude, findedLongitude),
        infoWindow: InfoWindow(
          title: '$findedCoordinatesString',
          snippet: placeName,
        ),
        icon: BitmapDescriptor.defaultMarker,
      );

      mapViewController.markers.add(findedMarker);

      print(
        'FINDED COORDINATES: ($findedLatitude, $findedLongitude)',
      );

      camService.cameraPositionUpdate(
          mapController, findedLatitude, findedLongitude, 18.0);

      return true;
    } else
      return false;
  }

  Future<void> pointMarker(
      String pointAddress, double latitude, double longitude) async {
    final mapViewController = Get.find<MapviewController>();
    Marker pointMarker = Marker(
      markerId: MarkerId("($latitude, $longitude)"),
      position: LatLng(latitude, longitude),
      infoWindow: InfoWindow(
        title: '($latitude, $longitude)',
        snippet: pointAddress,
      ),
      icon: BitmapDescriptor.defaultMarker,
    );

    mapViewController.markers.add(pointMarker);

    print(
      'POINT COORDINATES: ($findedLatitude, $findedLongitude)',
    );
  }
}
