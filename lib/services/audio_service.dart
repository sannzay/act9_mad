import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _bg = AudioPlayer();   
  static final AudioPlayer _sfx = AudioPlayer();  
  static bool _isBackgroundPlaying = false;

  static Future<void> playBackground() async {
    if (_isBackgroundPlaying) return; // Prevent multiple instances
    
    try {
      await _bg.stop(); // Stop any existing audio first
      await _bg.setReleaseMode(ReleaseMode.loop);
      
      // Set up completion listener to restart if loop fails
      _bg.onPlayerComplete.listen((event) {
        debugPrint('AudioService: background completed, restarting...');
        if (_isBackgroundPlaying) {
          _bg.play(AssetSource('audio/background.mp3'), volume: 0.8);
        }
      });
      
      await _bg.play(AssetSource('audio/background.mp3'), volume: 0.8);
      _isBackgroundPlaying = true;
      debugPrint('AudioService: background started (looping)');
    } catch (e, st) {
      debugPrint('AudioService: background audio error: $e\n$st');
    }
  }

  static Future<void> stopBackground() async {
    try {
      _isBackgroundPlaying = false;
      await _bg.stop();
      debugPrint('AudioService: background stopped');
    } catch (e, st) {
      debugPrint('AudioService: stop error: $e\n$st');
    }
  }

  static Future<void> playSfx(String filename) async {
    try {
      // Set up completion listener to resume background audio after SFX
      _sfx.onPlayerComplete.listen((event) {
        debugPrint('AudioService: SFX completed, resuming background...');
        if (_isBackgroundPlaying && _bg.state != PlayerState.playing) {
          _bg.play(AssetSource('audio/background.mp3'), volume: 0.8);
        }
      });
      
      await _sfx.play(AssetSource('audio/$filename'));
      debugPrint('AudioService: sfx play $filename');
    } catch (e, st) {
      debugPrint('AudioService: sfx error ($filename): $e\n$st');
    }
  }
}
