# FlutterCon Geotrigger Demo

A Flutter application demonstrating ArcGIS Maps SDK geotriggers for NYC Tourism and interactive experiences.

## Setup Instructions

### 1. Prerequisites

- Flutter SDK (3.7.0 or higher)
- ArcGIS Developer Account
- Valid ArcGIS API Key

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure ArcGIS API Key

1. Get your API key from [ArcGIS Developer Portal](https://developers.arcgis.com/)
2. Open `lib/save_me.dart`
3. Replace `'YOUR_API_KEY_HERE'` on line 8 with your actual API key:

```dart
ArcGISEnvironment.apiKey = 'your-actual-api-key-here';
```

### 4. Platform Configuration

#### Android
The project is already configured with the required settings in `android/app/build.gradle.kts`:
- Android NDK 25.2.9519653 minimum
- Android SDK 26 minimum
- Kotlin version 1.9.0

#### iOS
The project is already configured with the required settings in `ios/Podfile`:
- iOS 16.0 minimum
- Required pods for ArcGIS Maps SDK

### 5. Run the Application

```bash
flutter run
```

### Geotrigger System

- **Zone Geotriggers**: Trigger when entering/exiting polygon zones
- **POI Geotriggers**: Trigger when approaching points of interest (2-meter buffer)
- **Voice Feedback**: Automatic text-to-speech announcements
- **Visual Feedback**: Real-time status updates and zone indicators

### Adding New Zones or POIs

1. Add new zone definitions to the `zoneDefinitions` array
2. Add new POI definitions to the `poiDefinitions` array
3. Ensure proper polygon closure for zones (first and last points should be the same)

### Customizing Messages

Edit the `message` field in zone and POI definitions to customize voice announcements.

## Troubleshooting

### Common Issues

1. **API Key Error**: Ensure your ArcGIS API key is valid and has the necessary permissions
2. **Location Permissions**: The app uses simulated location, so no real location permissions are needed
3. **Voice Not Working**: Check device volume and TTS settings

### Debug Information

The app provides real-time status updates in the UI and console output:
- Zone entry/exit events
- POI proximity notifications
- Simulation status

## Dependencies

- `arcgis_maps: ^200.7.0` - ArcGIS Maps SDK for Flutter
- `flutter_tts: ^4.2.2` - Text-to-speech functionality
- `permission_handler: ^12.0.0+1` - Permission handling

## License

This project is for demonstration purposes. Please ensure compliance with ArcGIS Maps SDK licensing terms for production use.
