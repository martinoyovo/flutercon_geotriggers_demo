import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

class VoiceService {
  late FlutterTts _flutterTts;
  bool _isInitialized = false;
  bool _isSpeaking = false;

  // NYC-optimized voice settings
  static const String _language = "en-US";
  //static const double _pitch = 1.0;
  static const double _speechRate = 0.5; // Slightly slower for clarity in noisy NYC
  static const double _volume = 0.9;

  Future<void> initialize() async {
    try {
      print(' Initializing VoiceService for NYC Demo...');
      _flutterTts = FlutterTts();

      // iOS-specific setup
      if (Platform.isIOS) {
        await _flutterTts.setSharedInstance(true);
        await _flutterTts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.allowBluetooth,
            IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.spokenAudio,
        );
      }

      // Configure voice settings for NYC demo
      await _flutterTts.setLanguage(_language);
      //await _flutterTts.setPitch(_pitch);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);

      // Set up completion callback
      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
      });

      // Set up error callback
      _flutterTts.setErrorHandler((message) {
        print('TTS Error: $message');
        _isSpeaking = false;
      });

      _isInitialized = true;
      print('VoiceService initialized for NYC tourism announcements');

    } catch (e) {
      print('VoiceService initialization failed: $e');
      _isInitialized = false;
    }
  }

  Future<void> speak(String message) async {
    if (!_isInitialized) {
      print('VoiceService not initialized, attempting to initialize...');
      await initialize();
      if (!_isInitialized) {
        print('Cannot speak: VoiceService initialization failed');
        return;
      }
    }

    try {
      // Stop current speech if any
      if (_isSpeaking) {
        await _flutterTts.stop();
      }

      print('Speaking: $message');
      _isSpeaking = true;

      // Speak the message
      await _flutterTts.speak(message);

    } catch (e) {
      print('Error speaking message: $e');
      _isSpeaking = false;
    }
  }

  Future<void> stop() async {
    if (_isInitialized) {
      try {
        await _flutterTts.stop();
        _isSpeaking = false;
        print('Voice stopped');
      } catch (e) {
        print('Error stopping voice: $e');
      }
    }
  }

  // Check if currently speaking
  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isInitialized;

  void dispose() {
    print('Disposing VoiceService...');
    if (_isInitialized) {
      _flutterTts.stop();
      _isInitialized = false;
      _isSpeaking = false;
    }
  }
}