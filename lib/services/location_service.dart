import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:navigation_demo/models/demo_config.dart';

class LocationService {
  late SimulatedLocationDataSource _locationDataSource;
  List<ArcGISPoint>? _routePoints;
  double _currentSpeed = DemoConfig.drivingSpeed;

  SimulatedLocationDataSource get dataSource => _locationDataSource;

  Future<void> initialize() async {
    _locationDataSource = SimulatedLocationDataSource();
    // Don't setup path yet - wait for real route calculation
  }

  Future<void> setupRouteFromPoints(List<ArcGISPoint> routePoints) async {
    _routePoints = routePoints;
    await _setupDrivingPath();
  }

  Future<void> updateSpeed(double newSpeed) async {
    _currentSpeed = newSpeed;
    await _setupDrivingPath();
  }

  Future<void> _setupDrivingPath() async {
    final pathBuilder = PolylineBuilder(
      spatialReference: SpatialReference.wgs84,
    );

    if (_routePoints != null && _routePoints!.isNotEmpty) {
      // Use calculated route points (following real NYC streets)
      for (final point in _routePoints!) {
        pathBuilder.addPoint(point);
      }
      print('Using real street route with ${_routePoints!.length} points');
    } else {
      // Fallback: create straight line between start and end
      print('No route points available, using fallback straight line');
      pathBuilder.addPoint(
        ArcGISPoint(
          x: DemoConfig.startLocation[0],
          y: DemoConfig.startLocation[1],
          spatialReference: SpatialReference.wgs84,
        ),
      );
      pathBuilder.addPoint(
        ArcGISPoint(
          x: DemoConfig.endLocation[0],
          y: DemoConfig.endLocation[1],
          spatialReference: SpatialReference.wgs84,
        ),
      );
    }

    final simulationParameters = SimulationParameters(speed: _currentSpeed);

    _locationDataSource.setLocationsWithPolyline(
      pathBuilder.toGeometry() as Polyline,
      simulationParameters: simulationParameters,
    );
  }

  Future<void> start() async {
    await _locationDataSource.start();
  }

  Future<void> stop() async {
    await _locationDataSource.stop();
  }

  Future<void> resetToStart() async {
    await stop();
    await _setupDrivingPath();
  }

  void dispose() {
    _locationDataSource.stop();
  }
}
