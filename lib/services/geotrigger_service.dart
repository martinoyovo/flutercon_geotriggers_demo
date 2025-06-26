import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:navigation_demo/models/demo_config.dart';
import 'package:navigation_demo/models/tour_feature.dart';
import 'location_service.dart';
import 'voice_service.dart';

class GeotriggerService {
  static const double zoneBufferDistance = 25.0;
  static const double initialZoomScale = 8000.0;

  // Dependencies
  final LocationService _locationService;
  final VoiceService _voiceService;

  // Feature tables
  late FeatureCollectionTable _zonesTable;
  late FeatureCollectionTable _poisTable;
  late FeatureCollectionTable _dynamicZonesTable;
  late FeatureCollectionTable _dynamicPoisTable;

  // Geotrigger monitors
  late GeotriggerMonitor _zoneMonitor;
  late GeotriggerMonitor _poiMonitor;
  late GeotriggerMonitor _dynamicZoneMonitor;
  late GeotriggerMonitor _dynamicPoiMonitor;
  late LocationGeotriggerFeed _locationFeed;

  // State
  final Set<String> _activeZones = {};
  bool _demoCompleted = false;
  bool _completionScheduled = false;
  double _currentRouteProgress = 0.0;
  bool _isDestinationReached = false; // New flag to prevent multiple triggers

  // Callbacks
  Function(Set<String> activeZones)? onZoneChanged;
  Function()? onDemoComplete;
  Function(List<String> activeFeatures)? onDynamicFeaturesChanged;
  Function(TourFeature feature)? onDynamicFeatureAppeared;

  // Getters for UI
  FeatureCollectionTable get zonesTable => _zonesTable;
  FeatureCollectionTable get poisTable => _poisTable;
  FeatureCollectionTable get dynamicZonesTable => _dynamicZonesTable;
  FeatureCollectionTable get dynamicPoisTable => _dynamicPoisTable;
  Set<String> get activeZones => Set.from(_activeZones);

  GeotriggerService({
    required LocationService locationService,
    required VoiceService voiceService,
  }) : _locationService = locationService,
        _voiceService = voiceService;

  Future<void> initialize() async {
    await _createFeatureTables();
    await _setupGeotriggers();
  }

  Future<void> _createFeatureTables() async {
    _zonesTable = await _createFeatureTable(
      geometryType: GeometryType.polygon,
      features: TourData.getZones(),
    );

    _poisTable = await _createFeatureTable(
      geometryType: GeometryType.point,
      features: TourData.getPOIs(),
    );

    // Create dynamic feature tables (initially empty)
    _dynamicZonesTable = await _createFeatureTable(
      geometryType: GeometryType.polygon,
      features: [],
    );

    _dynamicPoisTable = await _createFeatureTable(
      geometryType: GeometryType.point,
      features: [],
    );

    // Debug output
    print('Created ${TourData.getZones().length} static zones');
    print('Created ${TourData.getPOIs().length} static POIs');
    print('Created dynamic zones table (initially empty)');
    print('Created dynamic POIs table (initially empty)');
  }

  Future<FeatureCollectionTable> _createFeatureTable({
    required GeometryType geometryType,
    required List<TourFeature> features,
  }) async {
    final fields = [
      Field.text(name: 'name', alias: 'Feature Name', length: 50),
      Field.text(name: 'type', alias: 'Feature Type', length: 30),
      Field.text(name: 'message', alias: 'Message', length: 200),
    ];

    final table = FeatureCollectionTable(
      fields: fields,
      geometryType: geometryType,
      spatialReference: SpatialReference.wgs84,
    );

    // Add features to table
    for (final featureData in features) {
      final feature = table.createFeature();
      feature.attributes['name'] = featureData.name;
      feature.attributes['type'] = featureData.type;
      feature.attributes['message'] = featureData.message;
      feature.geometry = featureData.geometry;
      await table.addFeature(feature);
    }

    return table;
  }

  Future<void> _setupGeotriggers() async {
    _locationFeed = LocationGeotriggerFeed(
      locationDataSource: _locationService.dataSource,
    );

    // Create static zone geotrigger
    _zoneMonitor = await _createGeotriggerMonitor(
      featureTable: _zonesTable,
      bufferDistance: DemoConfig.zoneBufferDistance,
      name: 'conference_zones',
      eventHandler: (info) => _handleGeotriggerEvent(info, isZone: true),
    );

    // Create static POI geotrigger
    _poiMonitor = await _createGeotriggerMonitor(
      featureTable: _poisTable,
      bufferDistance: DemoConfig.poiBufferDistance,
      name: 'conference_pois',
      eventHandler: (info) => _handleGeotriggerEvent(info, isZone: false),
    );
  }

  Future<GeotriggerMonitor> _createGeotriggerMonitor({
    required FeatureCollectionTable featureTable,
    required double bufferDistance,
    required String name,
    required Function(GeotriggerNotificationInfo) eventHandler,
  }) async {
    final geotrigger = FenceGeotrigger(
      feed: _locationFeed,
      ruleType: FenceRuleType.enterOrExit,
      fenceParameters: FeatureFenceParameters(
        featureTable: featureTable,
        bufferDistance: bufferDistance,
      ),
      messageExpression: ArcadeExpression(expression: r'$fencefeature.name'),
      name: name,
    );

    final monitor = GeotriggerMonitor(geotrigger);
    monitor.onGeotriggerNotificationEvent.listen(eventHandler);
    await monitor.start();

    return monitor;
  }

  void _handleGeotriggerEvent(
      GeotriggerNotificationInfo info, {
        required bool isZone,}) {
    final fenceInfo = info as FenceGeotriggerNotificationInfo;
    final featureName = fenceInfo.message;
    final feature = fenceInfo.fenceGeoElement as Feature;

    switch (fenceInfo.fenceNotificationType) {
      case FenceNotificationType.entered:
        print('DEBUG: Entered zone/POI: $featureName');

        if (isZone) {
          _activeZones.add(featureName);
          onZoneChanged?.call(_activeZones);
        }

        final message = feature.attributes['message'] as String;
        _voiceService.speak(message);

        // Check for demo completion - FIXED: Use correct destination name
        if ((featureName == 'Times Square Destination' ||
            featureName.contains('Times Square')) &&
            !_demoCompleted &&
            !_completionScheduled &&
            !_isDestinationReached) {
          print('DEBUG: Demo completion triggered for destination: $featureName');
          _isDestinationReached = true;
          _demoCompleted = true;
          _completionScheduled = true;
          _scheduleAutoStop();
        }
        break;

      case FenceNotificationType.exited:
        if (isZone) {
          _activeZones.remove(featureName);
          onZoneChanged?.call(_activeZones);
        }
        break;
    }
  }

  void _scheduleAutoStop() {
    print('DEBUG: Scheduling auto stop');
    Future.delayed(Duration(seconds: 2), () {
      if (_demoCompleted && !_completionScheduled) {
        // Double-check to prevent multiple calls
        print('DEBUG: Calling onDemoComplete callback');
        onDemoComplete?.call();
      }
    });
  }

  Future<void> startDemo() async {
    print('DEBUG: Starting demo - resetting all completion flags');
    _demoCompleted = false;
    _completionScheduled = false;
    _isDestinationReached = false; // Reset destination flag
    _activeZones.clear();
    await _locationService.resetToStart();
    await _locationService.start();
  }

  Future<void> pauseDemo() async {
    await _locationService.stop();
    await _voiceService.stop();
  }

  Future<void> resumeDemo() async {
    await _locationService.start();
    if (_activeZones.isNotEmpty) {
      final currentZone = _activeZones.first;
      _voiceService.speak("Resuming demo. You are in: $currentZone");
    } else {
      _voiceService.speak("Continuing the tour.");
    }
  }

  Future<void> stopDemo() async {
    await _locationService.stop();
    await _voiceService.stop();
    _activeZones.clear();
    _demoCompleted = false;
    _isDestinationReached = false;
  }

  Future<void> resetDemo() async {
    await stopDemo();
    await _clearDynamicFeatures();
    _currentRouteProgress = 0.0;
    _isDestinationReached = false; // Reset destination flag
    await _locationService.resetToStart();
    await _voiceService.speak(
      "Demo reset to entrance. Ready for a fresh tour!",
    );
  }

  Future<void> stopDemoWithAnnouncement() async {
    print('DEBUG: Stopping demo with announcement');
    // IMPORTANT: Stop location service first to prevent further triggers
    await _locationService.stop();

    // Mark as completed to prevent further processing
    _completionScheduled = true;

    await Future.delayed(Duration(milliseconds: 500));
    await _voiceService.speak(
      "Demo tour completed! Click Start Demo to tour again.",
    );

    _activeZones.clear();
    _demoCompleted = false;
    _isDestinationReached = false; // Reset destination flag
    await _clearDynamicFeatures();
    _currentRouteProgress = 0.0;

    // Reset completion flag after everything is done
    _completionScheduled = false;
  }

  Future<void> _clearDynamicFeatures() async {
    // Clear dynamic zones
    final zoneQuery = QueryParameters();
    final zoneResult = await _dynamicZonesTable.queryFeatures(zoneQuery);
    for (final feature in zoneResult.features()) {
      await _dynamicZonesTable.deleteFeature(feature);
    }

    // Clear dynamic POIs
    final poiQuery = QueryParameters();
    final poiResult = await _dynamicPoisTable.queryFeatures(poiQuery);
    for (final feature in poiResult.features()) {
      await _dynamicPoisTable.deleteFeature(feature);
    }
  }

  void dispose() {
    _zoneMonitor.stop();
    _poiMonitor.stop();
    _dynamicZoneMonitor.stop();
    _dynamicPoiMonitor.stop();
    _locationService.dispose();
    _voiceService.dispose();
  }
}