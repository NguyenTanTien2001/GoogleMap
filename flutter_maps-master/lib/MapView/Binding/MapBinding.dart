import 'package:flutter_maps/MapView/Controller/MapViewController.dart';
import 'package:flutter_maps/service/CameraService.dart';
import 'package:flutter_maps/service/GoogleMapService.dart';
import 'package:flutter_maps/service/LocationService.dart';
import 'package:flutter_maps/service/Places_Service.dart';
import 'package:get/get.dart';

class MapBinding extends Bindings {
  @override
  void dependencies() {
    //Service
    Get.put(GoogleMapService());
    Get.put(PlacesService());
    Get.put(CameraService());
    Get.put(LocationService());

    //Controller
    Get.put(MapviewController());
  }
}
