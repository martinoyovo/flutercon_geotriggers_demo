import 'package:arcgis_maps/arcgis_maps.dart';
import '../models/demo_config.dart';
import 'dart:math' as math;

class RouteService {
  RouteTask? _routeTask;
  ArcGISRoute? _currentRoute;
  Polyline? _routeGeometry;
  List<ArcGISPoint>? _routePoints;

  // Getters
  ArcGISRoute? get currentRoute => _currentRoute;
  Polyline? get routeGeometry => _routeGeometry;
  List<ArcGISPoint>? get routePoints => _routePoints;

  Future<void> initialize() async {
    try {
      print('Initializing RouteService...');
      _routeTask = RouteTask.withUri(
        Uri.parse(
          'https://route-api.arcgis.com/arcgis/rest/services/World/Route/NAServer/Route_World',
        ),
      );

      // Test the connection
      await _routeTask!.createDefaultParameters();
      print('RouteService initialized successfully');
    } catch (e) {
      print('RouteService initialization failed: $e');
      rethrow;
    }
  }

  Future<bool> calculateRoute() async {
    // Always use the custom route through zones and POIs
    _createRouteThroughZonesAndPOIs();
    return true;
  }

  Future<bool> calculateRouteFromPoints({
    required ArcGISPoint startPoint,
    required ArcGISPoint endPoint,
  }) async {
    if (_routeTask == null) {
      print('RouteTask not initialized');
      return false;
    }

    try {
      // Create stops
      final startStop = Stop(startPoint);
      final endStop = Stop(endPoint);

      print('Creating route parameters...');

      // Create route parameters for NYC driving
      final routeParameters = await _routeTask!.createDefaultParameters();

      // Clear any existing stops and add our stops
      routeParameters.clearStops();
      routeParameters.setStops([startStop, endStop]);

      // Configure route parameters
      routeParameters.returnRoutes = true;
      routeParameters.returnDirections = true;
      routeParameters.returnStops = true;

      print('Solving route...');

      // Solve the route
      final routeResult = await _routeTask!.solveRoute(routeParameters);

      if (routeResult.routes.isNotEmpty) {
        _currentRoute = routeResult.routes.first;
        _routeGeometry = _currentRoute!.routeGeometry;

        if (_routeGeometry != null) {
          // Extract points from the calculated route for location simulation
          _routePoints = _extractRoutePoints(_routeGeometry!);
          return true;
        } else {
          return false;
        }
      } else {
        return false;
      }
    } catch (e) {
      print('Route calculation error: $e');
      return true; // Return true so demo can continue with fallback
    }
  }

  void _createRouteThroughZonesAndPOIs() {
    print('Creating route that passes through all zones and POIs...');

    // Create a polyline that goes through all the zones and POIs
    final pathBuilder = PolylineBuilder(
      spatialReference: SpatialReference.wgs84,
    );

    // Add all points from the driving path that goes through zones and POIs
    for (final point in DemoConfig.drivingPath) {
      pathBuilder.addPoint(
        ArcGISPoint(
          x: point[0],
          y: point[1],
          spatialReference: SpatialReference.wgs84,
        ),
      );
    }

    _routeGeometry = pathBuilder.toGeometry() as Polyline;
    _routePoints = _extractRoutePoints(_routeGeometry!);

    print(
      'Route through zones and POIs created with ${_routePoints!.length} points',
    );
  }

  List<ArcGISPoint> _extractRoutePoints(Polyline routeGeometry) {
    final points = <ArcGISPoint>[];

    try {
      print('Extracting route points...');

      // Get all parts of the polyline (real street segments)
      final partsCount = routeGeometry.parts.size;
      print('Route has $partsCount parts');

      for (int partIndex = 0; partIndex < partsCount; partIndex++) {
        final part = routeGeometry.parts.getPart(index: partIndex);
        final pointsInPart = part.pointCount;
        print('Part $partIndex has $pointsInPart points');

        // Get all points in this part
        for (int pointIndex = 0; pointIndex < pointsInPart; pointIndex++) {
          try {
            final point = part.getPoint(pointIndex: pointIndex);
            points.add(point);
          } catch (e) {
            print(
              'Warning: Could not get point $pointIndex from part $partIndex: $e',
            );
          }
        }
      }

      if (points.isEmpty) {
        print('No points extracted, creating basic route');
        return [
          ArcGISPoint(
            x: DemoConfig.startLocation[0],
            y: DemoConfig.startLocation[1],
            spatialReference: SpatialReference.wgs84,
          ),
          ArcGISPoint(
            x: DemoConfig.endLocation[0],
            y: DemoConfig.endLocation[1],
            spatialReference: SpatialReference.wgs84,
          ),
        ];
      }

      // Densify the route for smoother simulation
      final densifiedPoints = _densifyRoutePoints(points);
      print(
        'Extracted ${points.length} original points, densified to ${densifiedPoints.length} points',
      );

      return densifiedPoints;
    } catch (e) {
      print('Error extracting route points: $e');
      // Return simplified route if extraction fails
      return [
        ArcGISPoint(
          x: DemoConfig.startLocation[0],
          y: DemoConfig.startLocation[1],
          spatialReference: SpatialReference.wgs84,
        ),
        ArcGISPoint(
          x: DemoConfig.endLocation[0],
          y: DemoConfig.endLocation[1],
          spatialReference: SpatialReference.wgs84,
        ),
      ];
    }
  }

  List<ArcGISPoint> _densifyRoutePoints(List<ArcGISPoint> originalPoints) {
    if (originalPoints.length < 2) {
      return originalPoints;
    }

    final densifiedPoints = <ArcGISPoint>[];

    try {
      for (int i = 0; i < originalPoints.length - 1; i++) {
        final currentPoint = originalPoints[i];
        final nextPoint = originalPoints[i + 1];

        densifiedPoints.add(currentPoint);

        // Calculate distance between points
        final distance = _calculateDistance(currentPoint, nextPoint);

        // Add intermediate points if distance is > 50 meters (smoother movement)
        if (distance > 50) {
          final intermediatePointsCount =
              (distance / 25).floor(); // Every 25 meters

          for (int j = 1; j < intermediatePointsCount; j++) {
            final ratio = j / intermediatePointsCount;
            final interpolatedX =
                currentPoint.x + (nextPoint.x - currentPoint.x) * ratio;
            final interpolatedY =
                currentPoint.y + (nextPoint.y - currentPoint.y) * ratio;

            densifiedPoints.add(
              ArcGISPoint(
                x: interpolatedX,
                y: interpolatedY,
                spatialReference: SpatialReference.wgs84,
              ),
            );
          }
        }
      }

      // Add the final point
      densifiedPoints.add(originalPoints.last);

      return densifiedPoints;
    } catch (e) {
      print('Error densifying route points: $e');
      return originalPoints; // Return original points if densification fails
    }
  }

  double _calculateDistance(ArcGISPoint point1, ArcGISPoint point2) {
    try {
      // Simple Euclidean distance (in degrees, approximation for short distances)
      final dx = point2.x - point1.x;
      final dy = point2.y - point1.y;
      return math.sqrt(dx * dx + dy * dy) *
          111000; // Rough conversion to meters
    } catch (e) {
      print('Error calculating distance: $e');
      return 0.0;
    }
  }

  void dispose() {
    print('Disposing RouteService');
    _routeTask = null;
    _currentRoute = null;
    _routeGeometry = null;
    _routePoints = null;
  }
}
