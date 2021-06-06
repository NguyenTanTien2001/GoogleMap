import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_maps/MapView/Controller/MapViewController.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../secrets.dart';

class GoogleMapService {
  late PolylinePoints polylinePoints;

  // Create the polylines for showing the route between two places
  createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    final mapViewController = Get.find<MapviewController>();
    try {
      polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Secrets.API_KEY, // Google Maps API Key
        PointLatLng(startLatitude, startLongitude),
        PointLatLng(destinationLatitude, destinationLongitude),
        travelMode: TravelMode.transit,
      );

      if (result.points.isNotEmpty) {
        result.points.forEach((PointLatLng point) {
          mapViewController.polylineCoordinates
              .add(LatLng(point.latitude, point.longitude));
        });
      } else
        print("result is null");

      PolylineId id = PolylineId('poly');
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.red,
        points: mapViewController.polylineCoordinates,
        width: 3,
      );
      mapViewController.polylines[id] = polyline;
    } catch (e) {
      print(e);
    }
  }
}
