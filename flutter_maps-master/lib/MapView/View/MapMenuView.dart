import 'package:flutter/material.dart';
import 'package:flutter_maps/MapView/Controller/MapViewController.dart';
import 'package:flutter_maps/service/Places_Service.dart';
import 'package:get/get.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

final mapViewController = Get.find<MapviewController>();
final placeService = Get.find<PlacesService>();

class MenuView extends StatelessWidget {
  final ScrollController controller;
  final PanelController panelController;

  Widget _textField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required String hint,
    required double width,
    required Icon prefixIcon,
    Widget? suffixIcon,
    required Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        focusNode: focusNode,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey.shade400,
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue.shade300,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  MenuView({
    Key? key,
    required this.controller,
    required this.panelController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    return ListView(
      controller: controller,
      padding: EdgeInsets.zero,
      children: [
        // Show the place input fields & button for
        // showing the route
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              width: width * 0.9,
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 10),
                    Obx(() => _textField(
                        label: 'Start',
                        hint: 'Choose starting point',
                        prefixIcon: Icon(Icons.looks_one),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.my_location),
                          onPressed: () {
                            mapViewController.startAddressController.value
                                .text = mapViewController.currentAddress.value;
                            mapViewController.startAddress.value =
                                mapViewController.currentAddress.value;
                            print(mapViewController.currentAddress);
                          },
                        ),
                        controller:
                            mapViewController.startAddressController.value,
                        focusNode: mapViewController.startAddressFocusNode,
                        width: width,
                        locationCallback: (String value) {
                          mapViewController.startAddress.value = value;
                          //mapViewController.findPlace(value);
                        })),
                    SizedBox(height: 10),
                    Obx(() => _textField(
                        label: 'Destination',
                        hint: 'Choose destination',
                        prefixIcon: Icon(Icons.looks_two),
                        controller: mapViewController
                            .destinationAddressController.value,
                        focusNode:
                            mapViewController.desrinationAddressFocusNode,
                        width: width,
                        locationCallback: (String value) {
                          mapViewController.destinationAddress.value = value;
                        })),
                    SizedBox(height: 10),
                    Visibility(
                      visible:
                          // ignore: unnecessary_null_comparison
                          mapViewController.placeDistance.value == null
                              ? false
                              : true,
                      child: Obx(() => Text(
                            "DISTANCE: ${mapViewController.placeDistance.value} km",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ),
                    SizedBox(height: 5),
                    ElevatedButton(
                      onPressed: (mapViewController.startAddress.value != '' &&
                              mapViewController.destinationAddress.value != '')
                          ? () async {
                              mapViewController.startAddressFocusNode.unfocus();
                              mapViewController.desrinationAddressFocusNode
                                  .unfocus();
                              if (mapViewController.markers.isNotEmpty) {
                                print("marker is not empty");
                                mapViewController.markers.clear();
                              }
                              if (mapViewController.polylines.isNotEmpty) {
                                print("polyline is not empty");
                                mapViewController.polylines.clear();
                              }
                              if (mapViewController
                                  .polylineCoordinates.isNotEmpty) {
                                print("polyline coordinates is not empty");
                                mapViewController.polylineCoordinates.clear();
                              }
                              mapViewController.placeDistance.value = "";

                              mapViewController
                                  .calculateDistance()
                                  .then((isCalculated) {
                                if (isCalculated) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Distance Calculated Sucessfully'),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Error Calculating Distance'),
                                    ),
                                  );
                                }
                              });
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Show Route'.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.blue.shade300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
