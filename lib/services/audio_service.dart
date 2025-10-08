import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _bg = AudioPlayer();   
  static final AudioPlayer _sfx = AudioPlayer();  

  static Future<void> playBackground() async {
    try {
      await _bg.setReleaseMode(ReleaseMode.loop);
      await _bg.play(AssetSource('audio/background.mp3'), volume: 0.8);
      debugPrint('AudioService: background started (looping)');
    } catch (e, st) {
      debugPrint('AudioService: background audio error: $e\n$st');
    }
  }

  static Future<void> stopBackground() async {
    try {
      await _bg.stop();
      debugPrint('AudioService: background stopped');
    } catch (e, st) {
      debugPrint('AudioService: stop error: $e\n$st');
    }
  }

  static Future<void> playSfx(String filename) async {
    try {
      await _sfx.play(AssetSource('audio/$filename'));
      debugPrint('AudioService: sfx play $filename');
    } catch (e, st) {
      debugPrint('AudioService: sfx error ($filename): $e\n$st');
    }
  }
}
