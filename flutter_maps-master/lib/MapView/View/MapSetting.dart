import 'package:flutter/material.dart';
import 'package:flutter_maps/MapView/Controller/MapViewController.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final mapViewController = Get.find<MapviewController>();

class MapSetting extends StatelessWidget {
  final ScrollController controller;

  List<MapType> mapTypeList = [
    MapType.normal,
    MapType.hybrid,
    MapType.terrain,
  ];

  MapSetting({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      children: [
        SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Map Type:",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(width: 10.0),
                  Container(
                      child: Obx(
                    () => DropdownButton(
                      value: mapViewController.mapType.value,
                      onChanged: (MapType? newValue) {
                        mapViewController.mapType.value = newValue!;
                      },
                      items: mapTypeList.map((valueItem) {
                        return DropdownMenuItem(
                            value: valueItem,
                            child: Text(
                              valueItem.toString().split(".")[1],
                              style: TextStyle(fontSize: 20),
                            ));
                      }).toList(),
                    ),
                  ))
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}
