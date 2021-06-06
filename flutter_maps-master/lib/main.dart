import 'package:flutter/material.dart';
import 'package:flutter_maps/MapView/Binding/MapBinding.dart';
import 'package:get/get.dart';
import 'MapView/View/MapView.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(
        primaryColor: Colors.white,
      ),
      getPages: [
        GetPage(name: "MapView", page: () => MapView(), binding: MapBinding()),
      ],
      initialRoute: "MapView",
    );
  }
}
