import 'package:arcgis_maps/arcgis_maps.dart';

import 'demo_config.dart';

// BASE CLASSES FOR GEOSPATIAL FEATURES
class TourFeature {
  final String name;
  final String type;
  final String message;
  final Geometry geometry;

  const TourFeature({
    required this.name,
    required this.type,
    required this.message,
    required this.geometry,
  });
}

class TourZone extends TourFeature {
  TourZone({
    required super.name,
    required super.type,
    required super.message,
    required List<List<double>> coordinates,
  }) : super(geometry: _createPolygon(coordinates));

  static Polygon _createPolygon(List<List<double>> coordinates) {
    final builder = PolygonBuilder(spatialReference: SpatialReference.wgs84);
    for (final coord in coordinates) {
      builder.addPoint(ArcGISPoint(x: coord[0], y: coord[1]));
    }
    // Close the polygon
    if (coordinates.isNotEmpty) {
      builder.addPoint(ArcGISPoint(x: coordinates[0][0], y: coordinates[0][1]));
    }
    return builder.toGeometry() as Polygon;
  }
}

// Circular Zone using GeometryEngine.bufferGeodetic
class CircularZone extends TourFeature {
  CircularZone({
    required super.name,
    required super.type,
    required super.message,
    required double centerX,
    required double centerY,
    required double radiusMeters,
  }) : super(geometry: _createCircle(centerX, centerY, radiusMeters));

  static Polygon _createCircle(
      double centerX,
      double centerY,
      double radiusMeters,
      ) {
    // Create center point
    final centerPoint = ArcGISPoint(
      x: centerX,
      y: centerY,
      spatialReference: SpatialReference.wgs84,
    );

    // Create circular buffer around the point
    final circularPolygon = GeometryEngine.bufferGeodetic(
      geometry: centerPoint,
      distance: radiusMeters,
      distanceUnit: LinearUnit(unitId: LinearUnitId.meters),
      maxDeviation: double.nan,
      curveType: GeodeticCurveType.geodesic,
    );

    return circularPolygon;
  }
}

class TourPOI extends TourFeature {
  TourPOI({
    required super.name,
    required super.type,
    required super.message,
    required double x,
    required double y,
  }) : super(
    geometry: ArcGISPoint(
      x: x,
      y: y,
      spatialReference: SpatialReference.wgs84,
    ),
  );
}

// DATA CLASS - Generates zones and POIs from DemoConfig
class TourData {
  // Generate geotrigger zones from DemoConfig
  static List<TourFeature> getZones() {
    final zones = <TourFeature>[];

    // Convert DemoConfig geotrigger zones to CircularZone objects
    for (final zoneData in DemoConfig.geotriggerZones) {
      final center = zoneData['center'] as List<double>;
      zones.add(
        CircularZone(
          name: zoneData['name'] as String,
          type: zoneData['type'] as String,
          message: zoneData['message'] as String,
          centerX: center[0],
          centerY: center[1],
          radiusMeters: zoneData['radius'] as double,
        ),
      );
    }

    return zones;
  }

  // Generate POIs from DemoConfig
  static List<TourPOI> getPOIs() {
    final pois = <TourPOI>[];

    // Convert DemoConfig points of interest to ConferencePOI objects
    for (final poiData in DemoConfig.pointsOfInterest) {
      final coordinates = poiData['coordinates'] as List<double>;
      pois.add(
        TourPOI(
          name: poiData['name'] as String,
          type: poiData['category'] as String,
          message: poiData['description'] as String,
          x: coordinates[0],
          y: coordinates[1],
        ),
      );
    }

    return pois;
  }
}
