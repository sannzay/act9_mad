import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _bg = AudioPlayer();
  static final AudioPlayer _sfx = AudioPlayer();

  static Future<void> playBackground() async {
    try {
      await _bg.setSource(AssetSource('audio/background.mp3'));
      await _bg.setReleaseMode(ReleaseMode.loop);
      await _bg.resume();
    } catch (e) {
      debugPrint('Background audio error: $e');
    }
  }

  static Future<void> stopBackground() async {
    try {
      await _bg.stop();
    } catch (_) {}
  }

  static Future<void> playSfx(String filename) async {
    try {
      await _sfx.play(AssetSource('audio/$filename'));
    } catch (e) {
      debugPrint('SFX error: $e');
    }
  }
}
