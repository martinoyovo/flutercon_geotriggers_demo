import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:navigation_demo/screens/tour_screen.dart';

void main() {
  // 🔑 Set ArcGIS API key from environment
  ArcGISEnvironment.apiKey = const String.fromEnvironment('API_KEY');

  runApp(FlutterConGeotriggerApp());
}

class FlutterConGeotriggerApp extends StatelessWidget {
  const FlutterConGeotriggerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fluttercon Geotrigger Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: TourScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
