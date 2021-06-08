import 'package:flutter/material.dart';
import 'package:flutter_maps/MapView/Controller/MapViewController.dart';
import 'package:flutter_maps/MapView/View/MapSetting.dart';
import 'package:flutter_maps/model/place_search.dart';
import 'package:flutter_maps/service/CameraService.dart';
import 'package:flutter_maps/service/GoogleMapService.dart';
import 'package:flutter_maps/service/LocationService.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import 'MapMenuView.dart';

var appBarHeight = 53.0;

class MapView extends StatelessWidget {
  // ignore: non_constant_identifier_names
  final GGMapService = Get.find<GoogleMapService>();
  final locationService = Get.find<LocationService>();
  final camService = Get.find<CameraService>();
  final mapViewController = Get.find<MapviewController>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  //Sliding up panel controller
  final panelController = PanelController();

  @override
  // ignore: override_on_non_overriding_member
  void initState() {
    mapViewController.getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    var minHeight = 40.0;

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      body: SlidingUpPanel(
        controller: panelController,
        minHeight: minHeight,
        maxHeight: mapViewController.panelHeight.value,
        //snapPoint: 0.5,
        body: Container(
          height: height,
          width: width,
          child: Stack(
            children: <Widget>[
              // Map View
              Obx(
                () => GoogleMap(
                  markers: Set<Marker>.from(mapViewController.markers.value),
                  initialCameraPosition: camService.initialLocation,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: mapViewController.mapType.value,
                  zoomGesturesEnabled: true,
                  zoomControlsEnabled: false,
                  polylines:
                      Set<Polyline>.of(mapViewController.polylines.values),
                  onMapCreated: (GoogleMapController controller) {
                    mapViewController.mapController = controller;
                  },
                  onLongPress: mapViewController.addMarker,
                ),
              ),
              //searchBar
              SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () async {
                        if (await mapViewController
                            .findPlace(mapViewController.findedAddress.value)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Place finded"),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Can't find place"),
                            ),
                          );
                        }
                        //Todo
                      },
                    ),
                    Expanded(
                      child: TypeAheadField<PlaceSearch?>(
                        debounceDuration: Duration(microseconds: 500),
                        textFieldConfiguration: TextFieldConfiguration(
                            onChanged: (value) {
                              mapViewController.findedAddress.value = value;
                            },
                            style: TextStyle(fontSize: 24)),
                        suggestionsBoxDecoration: SuggestionsBoxDecoration(),
                        suggestionsCallback: placeService.getAutocomplete,
                        itemBuilder: (context, PlaceSearch? suggestion) {
                          final place = suggestion;
                          return ListTile(
                            title: Text(place!.description),
                          );
                        },
                        noItemsFoundBuilder: (context) {
                          return Container(
                            height: 50,
                            child: Center(
                              child: Text(
                                "No Places Found!",
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          );
                        },
                        onSuggestionSelected: (places) => {},
                      ),
                    ),
                  ],
                ),
              ),
              // Show zoom buttons
              Positioned(
                right: 12,
                top: 100,
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      ClipOval(
                        child: Material(
                          color: Colors.grey.shade300, // button color
                          child: InkWell(
                            splashColor: Colors.grey, // inkwell color
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.add),
                            ),
                            onTap: () {
                              mapViewController.mapController.animateCamera(
                                CameraUpdate.zoomIn(),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      ClipOval(
                        child: Material(
                          color: Colors.grey.shade300, // button color
                          child: InkWell(
                            splashColor: Colors.grey, // inkwell color
                            child: SizedBox(
                              width: 50,
                              height: 50,
                              child: Icon(Icons.remove),
                            ),
                            onTap: () {
                              mapViewController.mapController.animateCamera(
                                CameraUpdate.zoomOut(),
                              );
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              // Show current location button
              Positioned(
                right: 20,
                bottom: 51,
                child: ClipOval(
                  child: Material(
                    color: Colors.white, // button color
                    child: InkWell(
                      splashColor: Colors.white38, // inkwell color
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(Icons.my_location),
                      ),
                      onTap: () async {
                        await mapViewController.getCurrentLocation();
                        mapViewController.mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(
                                mapViewController.currentPosition.latitude,
                                mapViewController.currentPosition.longitude,
                              ),
                              zoom: 18.0,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        panelBuilder: (controller) => DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: buildTabBar(),
            body: TabBarView(
              children: [
                MenuView(
                  controller: controller,
                  panelController: panelController,
                ),
                MapSetting(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSize buildTabBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: AppBar(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
        title: buildDragHander(),
        titleSpacing: 0.0,
        bottom: TabBar(
          tabs: [Tab(child: Text("place")), Tab(child: Text("Setting"))],
        ),
      ),
    );
  }

  Widget buildDragHander() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(18),
        ),
        width: 25,
        height: 5,
      ),
    );
  }
}
