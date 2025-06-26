import 'package:arcgis_maps/arcgis_maps.dart';
import 'package:flutter/material.dart';
import 'package:navigation_demo/models/demo_config.dart';
import 'package:navigation_demo/services/geotrigger_service.dart';
import 'package:navigation_demo/services/location_service.dart';
import 'package:navigation_demo/services/route_service.dart';
import 'package:navigation_demo/services/voice_service.dart';
import 'package:navigation_demo/widgets/conference_map_view.dart';
import 'package:navigation_demo/widgets/demo_controls.dart';
import 'package:navigation_demo/widgets/demo_status_panel.dart';
import 'dart:async';
import 'dart:math' as math;

class TourScreen extends StatefulWidget {
  const TourScreen({super.key});

  @override
  State<TourScreen> createState() => _TourScreenState();
}

class _TourScreenState extends State<TourScreen> {
  // Services
  late GeotriggerService _geotriggerService;
  late LocationService _locationService;
  late VoiceService _voiceService;
  late RouteService _routeService;

  // Map controller
  final _mapController = ArcGISMapView.createController();

  // State
  String _statusText = "Calculating NYC tourism route...";
  bool _demoRunning = false;
  bool _locationDisplayStarted = false;
  Set<String> _activeZones = {};
  bool _isReady = false;
  Polyline? _routeGeometry;
  double _currentSpeed = DemoConfig.drivingSpeed;
  bool _isAutoStopping = false; // New flag to prevent interference during auto-stop

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      setState(() {
        _statusText = "Connecting to ArcGIS routing service...";
      });

      // Initialize services
      _locationService = LocationService();
      _voiceService = VoiceService();
      _routeService = RouteService();

      await _locationService.initialize();
      await _voiceService.initialize();
      await _routeService.initialize();

      setState(() {
        _statusText = "Calculating route from Union Square to Times Square...";
      });

      // Calculate the route
      final routeCalculated = await _routeService.calculateRoute();
      if (routeCalculated) {
        _routeGeometry = _routeService.routeGeometry;

        // Set up location service with calculated route points
        if (_routeService.routePoints != null) {
          await _locationService.setupRouteFromPoints(
            _routeService.routePoints!,
          );
        }

        setState(() {
          _statusText = "Route calculated! Setting up geotriggers...";
        });
      } else {
        setState(() {
          _statusText = "Route calculation failed, using fallback path...";
        });
      }

      // Initialize geotriggers
      _geotriggerService = GeotriggerService(
        locationService: _locationService,
        voiceService: _voiceService,
      );

      await _geotriggerService.initialize();

      // Set up callbacks
      _geotriggerService.onZoneChanged = (activeZones) {
        if (mounted && !_isAutoStopping) {
          setState(() {
            _activeZones = activeZones;
            _statusText = activeZones.isEmpty
                ? "Driving route - no active zones"
                : "Active: ${activeZones.join(', ')}";
          });
        }
      };

      _geotriggerService.onDemoComplete = () {
        if (mounted && !_isAutoStopping) {
          _autoStopDemo();
        }
      };

      // Set up dynamic feature callbacks
      _geotriggerService.onDynamicFeaturesChanged = (activeFeatures) {
        if (mounted && !_isAutoStopping) {
          setState(() {
            _statusText = "Dynamic features: ${activeFeatures.length} active";
          });
        }
      };

      _geotriggerService.onDynamicFeatureAppeared = (feature) {
        if (mounted && !_isAutoStopping) {
          setState(() {
            _statusText = "New feature: ${feature.name}";
          });
          // Announce new feature
          _voiceService.speak("New ${feature.type}: ${feature.name}");
        }
      };

      setState(() {
        _isReady = true;
        _statusText =
        "Ready for NYC tourism demo! Press 'Start Demo' to begin driving.";
      });
    } catch (e) {
      setState(() {
        _statusText = "Setup error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NYC Tour Guide Demo'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Status Panel
          DemoStatusPanel(statusText: _statusText, activeZones: _activeZones),

          // Map View
          MediaQuery.removePadding(
            removeBottom: true,
            context: context,
            child: Expanded(
              child: _isReady
                  ? Stack(
                children: [
                  ConferenceMapView(
                    mapController: _mapController,
                    zonesTable: _geotriggerService.zonesTable,
                    poisTable: _geotriggerService.poisTable,
                    dynamicZonesTable:
                    _geotriggerService.dynamicZonesTable,
                    dynamicPoisTable:
                    _geotriggerService.dynamicPoisTable,
                    routeGeometry: _routeGeometry,
                    onMapReady: _onMapViewReady,
                  ),

                  // Speed Display Widget
                  Positioned(
                    top: 20,
                    right: 20,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.speed,
                            color: Colors.blue,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            '${(_currentSpeed * 2.237).toStringAsFixed(0)} mph',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Map Controls
                  Positioned(
                    bottom: 40,
                    right: 18,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FloatingActionButton(
                          heroTag: 'zoomIn',
                          onPressed: _isReady ? _zoomInMap : null,
                          backgroundColor: Colors.white,
                          mini: true,
                          child: Icon(
                            Icons.zoom_in,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 6),
                        FloatingActionButton(
                          heroTag: 'zoomOut',
                          onPressed: _isReady ? _zoomOutMap : null,
                          backgroundColor: Colors.white,
                          mini: true,
                          child: Icon(
                            Icons.zoom_out,
                            color: Colors.blue,
                          ),
                        ),
                        SizedBox(height: 6),
                        FloatingActionButton(
                          heroTag: 'centerUser',
                          onPressed: _isReady ? _centerMapOnCurrentLocation : null,
                          backgroundColor: Colors.white,
                          mini: true,
                          tooltip: 'Center on current location',
                          child: Icon(
                            Icons.gps_fixed,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
                  : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Calculating route and setting up geotriggers...',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Control Panel
          DemoControls(
            isReady: _isReady,
            demoRunning: _demoRunning,
            locationDisplayStarted: _locationDisplayStarted,
            onStart: _startDemo,
            onReset: _resetDemo,
            onSpeedChanged: _onSpeedChanged,
            currentSpeed: _currentSpeed,
          ),
        ],
      ),
    );
  }

  void _onMapViewReady() {
    print('Map view ready with route');
    _centerMapOnCurrentLocation();
  }

  Future<void> _startDemo() async {
    // Prevent starting if currently auto-stopping
    if (_isAutoStopping) {
      print('DEBUG: Cannot start demo - currently auto-stopping');
      return;
    }

    if (!_demoRunning) {
      // Start the demo
      setState(() {
        _demoRunning = true;
        _locationDisplayStarted = true;
        _statusText =
        "Driving to Times Square... Watch for landmarks and zones!";
      });

      _mapController.locationDisplay.dataSource = _locationService.dataSource;
      _mapController.locationDisplay.autoPanMode =
          LocationDisplayAutoPanMode.recenter;
      _mapController.locationDisplay.initialZoomScale =
          DemoConfig.initialZoomScale;
      _mapController.locationDisplay.start();

      await _geotriggerService.startDemo();
    } else {
      // Pause/Resume the demo
      if (_locationDisplayStarted) {
        // Pause the demo
        _mapController.locationDisplay.stop();
        await _geotriggerService.pauseDemo();

        setState(() {
          _locationDisplayStarted = false;
          _statusText = "Tourism paused. Click 'Start Demo' to resume driving.";
        });
      } else {
        // Resume the demo
        _mapController.locationDisplay.dataSource = _locationService.dataSource;
        _mapController.locationDisplay.autoPanMode =
            LocationDisplayAutoPanMode.recenter;
        _mapController.locationDisplay.initialZoomScale =
            DemoConfig.initialZoomScale;
        _mapController.locationDisplay.start();
        await _geotriggerService.resumeDemo();

        setState(() {
          _locationDisplayStarted = true;
          _statusText = "Resuming tourism route... Watch for landmarks!";
        });
      }
    }
  }

  Future<void> _resetDemo() async {
    // Prevent reset if currently auto-stopping
    if (_isAutoStopping) {
      print('DEBUG: Cannot reset demo - currently auto-stopping');
      return;
    }

    // Stop and reset the demo completely
    _mapController.locationDisplay.stop();
    await _geotriggerService.resetDemo();

    // Add a small delay to ensure location display is fully stopped
    await Future.delayed(Duration(milliseconds: 100));

    setState(() {
      _demoRunning = false;
      _locationDisplayStarted = false;
      _statusText =
      "Demo reset to Union Square. Press 'Start Demo' for fresh tour.";
      _activeZones.clear();
    });
  }

  Future<void> _autoStopDemo() async {
    print('DEBUG: Auto stop demo called');

    // Prevent multiple calls and user interference
    if (_isAutoStopping) {
      print('DEBUG: Auto stop already in progress, ignoring');
      return;
    }

    if (!_demoRunning) {
      print('DEBUG: Demo not running, ignoring auto stop call');
      return;
    }

    // Set flag to prevent interference
    _isAutoStopping = true;

    try {
      // Stop location display immediately
      _mapController.locationDisplay.stop();

      // Stop the geotrigger service with announcement
      await _geotriggerService.stopDemoWithAnnouncement();

      // Update UI state
      if (mounted) {
        setState(() {
          _demoRunning = false;
          _locationDisplayStarted = false;
          _statusText =
          "🎯 Tour completed! You've reached Times Square. Press 'Start Demo' to tour again.";
          _activeZones.clear();
        });
      }

      print('DEBUG: Auto stop completed successfully');
    } catch (e) {
      print('ERROR: Auto stop failed: $e');
    } finally {
      // Reset flag after a delay
      Future.delayed(Duration(seconds: 3), () {
        _isAutoStopping = false;
        print('DEBUG: Auto stop flag reset');
      });
    }
  }

  Future<void> _zoomInMap() async {
    try {
      final viewpoint = _mapController.getCurrentViewpoint(
        ViewpointType.centerAndScale,
      );
      if (viewpoint != null) {
        final center = viewpoint.targetGeometry as ArcGISPoint;
        final currentScale = viewpoint.targetScale;
        final newScale = currentScale / 1.5;

        final newViewpoint = Viewpoint.fromCenter(
          center,
          scale: newScale,
          rotation: viewpoint.rotation,
        );

        // Animate the zoom in
        await _mapController.setViewpointAnimated(
          newViewpoint,
          duration: 0.5, // 500ms
        );
      }
    } catch (e) {
      print('ERROR: Failed to zoom in: $e');
    }
  }

  Future<void> _zoomOutMap() async {
    try {
      final viewpoint = _mapController.getCurrentViewpoint(
        ViewpointType.centerAndScale,
      );
      if (viewpoint != null) {
        final center = viewpoint.targetGeometry as ArcGISPoint;
        final currentScale = viewpoint.targetScale;
        final newScale = currentScale * 1.5;

        final newViewpoint = Viewpoint.fromCenter(
          center,
          scale: newScale,
          rotation: viewpoint.rotation,
        );

        // Animate the zoom out
        await _mapController.setViewpointAnimated(
          newViewpoint,
          duration: 0.5, // 500ms
        );
      }
    } catch (e) {
      print('ERROR: Failed to zoom out: $e');
    }
  }

  Future<void> _centerMapOnCurrentLocation() async {
    try {
      // Get the current location from the location display
      final currentLocation = _mapController.locationDisplay.location;

      if (currentLocation != null && currentLocation.position != null) {
        print('DEBUG: Centering on current location: ${currentLocation.position!.x}, ${currentLocation.position!.y}');

        // Get current heading/course if available
        double? heading;
        if (currentLocation.course != null && !currentLocation.course!.isNaN) {
          heading = currentLocation.course;
        }

        // Create viewpoint with current location
        final viewpoint = Viewpoint.fromCenter(
          currentLocation.position!,
          scale: DemoConfig.initialZoomScale,
          rotation: heading ?? 0,
        );

        // Animate to the current location with smooth animation
        await _mapController.setViewpointAnimated(
          viewpoint,
          duration: 2.0, // 2 seconds smooth animation
        );

        print('DEBUG: Successfully animated to current location');
      } else {
        print('DEBUG: No current location available, centering on route start');
        await _centerMapOnRouteStart();
      }
    } catch (e) {
      print('ERROR: Failed to center on current location: $e');
      // Fallback to route start if current location fails
      await _centerMapOnRouteStart();
    }
  }

  Future<void> _centerMapOnRouteStart() async {
    double? heading;
    ArcGISPoint? center;

    if (_routeService.routePoints != null &&
        _routeService.routePoints!.length > 1) {
      final p1 = _routeService.routePoints![0];
      final p2 = _routeService.routePoints![1];
      final dx = p2.x - p1.x;
      final dy = p2.y - p1.y;
      heading = (90 - (180 / math.pi) * math.atan2(dy, dx));
      center = p1;
    }

    if (_routeGeometry != null && center != null) {
      final viewpoint = Viewpoint.fromCenter(
        center,
        scale: DemoConfig.initialZoomScale,
        rotation: heading ?? 0,
      );

      // Animate to route start
      await _mapController.setViewpointAnimated(
        viewpoint,
        duration: 2.0,
      );
    } else {
      // Fallback to general NYC area
      center = ArcGISPoint(
        x: -73.9820,
        y: 40.7330,
        spatialReference: SpatialReference.wgs84,
      );

      final viewpoint = Viewpoint.fromCenter(
        center,
        scale: DemoConfig.initialZoomScale,
        rotation: 0,
      );

      await _mapController.setViewpointAnimated(
        viewpoint,
        duration: 2.0,
      );
    }
  }

  void _onSpeedChanged(double newSpeed) {
    setState(() {
      _currentSpeed = newSpeed;
    });
    _locationService.updateSpeed(newSpeed);
  }

  @override
  void dispose() {
    _geotriggerService.dispose();
    _routeService.dispose();
    _mapController.dispose();
    super.dispose();
  }
}