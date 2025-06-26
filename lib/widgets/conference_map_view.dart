import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';

class ConferenceMapView extends StatelessWidget {
  final ArcGISMapViewController mapController;
  final FeatureCollectionTable zonesTable;
  final FeatureCollectionTable poisTable;
  final FeatureCollectionTable? dynamicZonesTable;
  final FeatureCollectionTable? dynamicPoisTable;
  final Polyline? routeGeometry;
  final VoidCallback onMapReady;

  const ConferenceMapView({
    super.key,
    required this.mapController,
    required this.zonesTable,
    required this.poisTable,
    this.dynamicZonesTable,
    this.dynamicPoisTable,
    this.routeGeometry,
    required this.onMapReady,
  });

  @override
  Widget build(BuildContext context) {
    return ArcGISMapView(
      controllerProvider:
          () =>
              mapController
                ..arcGISMap = ArcGISMap.withBasemapStyle(
                  BasemapStyle.arcGISNavigation,
                ),
      onMapViewReady: () async {
        await _addLayersToMap();
        onMapReady();
      },
    );
  }

  Future<void> _addLayersToMap() async {
    // Add route first (bottom layer)
    if (routeGeometry != null) {
      await _addRouteOverlay();
    }

    // Add static zones overlay
    await _addZonesOverlay();

    // Add static POIs overlay
    await _addPoisOverlay();
  }

  Future<void> _addRouteOverlay() async {
    if (routeGeometry == null) return;

    final routeOverlay = GraphicsOverlay();

    // Google Maps style: Blue polyline with white border
    // White border/outline (thicker, underneath)
    final borderLineSymbol = SimpleLineSymbol(
      style: SimpleLineSymbolStyle.solid,
      color: Colors.white,
      width: 4,
    );

    // Blue main line (thinner, on top)
    final mainLineSymbol = SimpleLineSymbol(
      style: SimpleLineSymbolStyle.solid,
      color: Colors.blue[600]!, // Google Maps blue
      width: 10,
    );

    final routeSymbol = CompositeSymbol(
      symbols: [borderLineSymbol, mainLineSymbol],
    );

    routeOverlay.graphics.add(
      Graphic(geometry: routeGeometry, symbol: routeSymbol),
    );

    mapController.graphicsOverlays.add(routeOverlay);
  }

  Future<void> _addZonesOverlay() async {
    final zonesOverlay = GraphicsOverlay();
    final zonesResult = await zonesTable.queryFeatures(QueryParameters());

    for (final feature in zonesResult.features()) {
      final zoneName = feature.attributes['name'] as String;
      final zoneType = feature.attributes['type'] as String;

      // Unique color for each zone based on name and type
      Color zoneColor = _getZoneColor(zoneName, zoneType);

      // Zone polygon with type-specific styling
      final zoneSymbol = SimpleFillSymbol(
        style: SimpleFillSymbolStyle.solid,
        color: zoneColor.withValues(alpha: 0.3),
        outline: SimpleLineSymbol(
          style: SimpleLineSymbolStyle.solid,
          color: zoneColor,
          width: 2,
        ),
      );

      zonesOverlay.graphics.add(
        Graphic(geometry: feature.geometry, symbol: zoneSymbol),
      );

      // Zone label - positioned closer to the zone center
      final envelope = feature.geometry!.extent;
      final centerPoint = ArcGISPoint(
        x: envelope.center.x,
        y: envelope.center.y,
        spatialReference: SpatialReference.wgs84,
      );

      final labelSymbol = TextSymbol(
        text: zoneName,
        color: zoneColor,
        size: 12,
        horizontalAlignment: HorizontalAlignment.center,
        verticalAlignment: VerticalAlignment.middle,
      );

      zonesOverlay.graphics.add(
        Graphic(geometry: centerPoint, symbol: labelSymbol),
      );
    }

    mapController.graphicsOverlays.add(zonesOverlay);
  }

  // Get unique color for each zone based on name and type
  Color _getZoneColor(String zoneName, String zoneType) {
    // Primary color mapping based on zone name
    switch (zoneName.toLowerCase()) {
      case 'union square':
        return Colors.green[700]!; // Green for the starting point
      case 'flatiron district':
        return Colors.orange[600]!; // Orange for the iconic building district
      case 'theater district':
        return Colors.purple[600]!; // Purple for entertainment/theater
      case 'central park south':
        return Colors.teal[600]!; // Teal for the park
      case 'columbus circle':
        return Colors.indigo[600]!; // Indigo for the landmark
      case 'times square destination':
        return Colors.blue[600]!; // Blue for the destination
      default:
        // Fallback color mapping based on type
        switch (zoneType) {
          case 'start':
            return Colors.green[600]!;
          case 'neighborhood':
            return Colors.orange[600]!;
          case 'cultural':
            return Colors.red[600]!;
          case 'entertainment':
            return Colors.purple[600]!;
          case 'park':
            return Colors.teal[600]!;
          case 'landmark':
            return Colors.indigo[600]!;
          case 'destination':
            return Colors.blue[600]!;
          default:
            return Colors.grey[600]!;
        }
    }
  }

  Future<void> _addPoisOverlay() async {
    final poisOverlay = GraphicsOverlay();
    final poisResult = await poisTable.queryFeatures(QueryParameters());

    for (final feature in poisResult.features()) {
      final poiName = feature.attributes['name'] as String;
      final poiType = feature.attributes['type'] as String;

      // POI styling based on type
      Color poiColor;
      double poiSize;
      switch (poiType) {
        case 'navigation':
          poiColor = Colors.purple;
          poiSize = 20;
          break;
        case 'opportunity':
          poiColor = Colors.green;
          poiSize = 16;
          break;
        case 'amenity':
          poiColor = Colors.orange;
          poiSize = 16;
          break;
        case 'logistics':
          poiColor = Colors.brown;
          poiSize = 16;
          break;
        default:
          poiColor = Colors.red;
          poiSize = 14;
      }

      // POI marker
      final poiSymbol = SimpleMarkerSymbol(
        style: SimpleMarkerSymbolStyle.circle,
        color: poiColor,
        size: poiSize,
      );

      poisOverlay.graphics.add(
        Graphic(geometry: feature.geometry, symbol: poiSymbol),
      );

      // POI label - positioned much closer to the marker
      final point = feature.geometry as ArcGISPoint;
      final labelPoint = ArcGISPoint(
        x: point.x,
        y: point.y + 0.0001, // Much smaller offset - closer to marker
        spatialReference: SpatialReference.wgs84,
      );

      final labelSymbol = TextSymbol(
        text: poiName,
        color: poiColor,
        size: 10,
        horizontalAlignment: HorizontalAlignment.center,
        verticalAlignment: VerticalAlignment.bottom,
      );

      poisOverlay.graphics.add(
        Graphic(geometry: labelPoint, symbol: labelSymbol),
      );
    }

    mapController.graphicsOverlays.add(poisOverlay);
  }

  Future<void> _addDynamicZonesOverlay() async {
    final dynamicZonesOverlay = GraphicsOverlay();
    final dynamicZonesResult = await dynamicZonesTable!.queryFeatures(
      QueryParameters(),
    );

    for (final feature in dynamicZonesResult.features()) {
      final zoneName = feature.attributes['name'] as String;
      final zoneType = feature.attributes['type'] as String;

      // Use the same color system for dynamic zones
      Color zoneColor = _getZoneColor(zoneName, zoneType);

      // Dynamic zone with pulsing effect
      final zoneSymbol = SimpleFillSymbol(
        style: SimpleFillSymbolStyle.solid,
        color: zoneColor.withValues(alpha: 0.4),
        outline: SimpleLineSymbol(
          style: SimpleLineSymbolStyle.solid,
          color: zoneColor,
          width: 3,
        ),
      );

      dynamicZonesOverlay.graphics.add(
        Graphic(geometry: feature.geometry, symbol: zoneSymbol),
      );

      // Zone label
      final envelope = feature.geometry!.extent;
      final centerPoint = ArcGISPoint(
        x: envelope.center.x,
        y: envelope.center.y,
        spatialReference: SpatialReference.wgs84,
      );

      final labelSymbol = TextSymbol(
        text: zoneName,
        color: zoneColor,
        size: 14,
        horizontalAlignment: HorizontalAlignment.center,
        verticalAlignment: VerticalAlignment.middle,
      );

      dynamicZonesOverlay.graphics.add(
        Graphic(geometry: centerPoint, symbol: labelSymbol),
      );
    }

    mapController.graphicsOverlays.add(dynamicZonesOverlay);
  }
}
