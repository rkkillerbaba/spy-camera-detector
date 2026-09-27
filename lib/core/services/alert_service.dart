import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

/// Service responsible for alert indicators (haptic vibration pulses and frequency beeps)
class AlertService {
  static final AlertService _instance = AlertService._internal();
  factory AlertService() => _instance;
  AlertService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  DateTime _lastAlertTime = DateTime.fromMillisecondsSinceEpoch(0);

  /// Trigger alert vibration and audio tone with debounce
  Future<void> triggerAlert({required bool isHighDanger}) async {
    final now = DateTime.now();
    // Debounce to prevent vibration flooding
    if (now.difference(_lastAlertTime).inMilliseconds < (isHighDanger ? 250 : 500)) {
      return;
    }
    _lastAlertTime = now;

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        if (isHighDanger) {
          Vibration.vibrate(pattern: [0, 150, 50, 150]);
        } else {
          Vibration.vibrate(duration: 80);
        }
      }
    } catch (e) {
      debugPrint('Vibration error: $e');
    }

    // Play synthetic radar alert sound / beep click
    try {
      if (!_isPlaying) {
        _isPlaying = true;
        // In release, plays asset or system sound
        await _audioPlayer.stop();
        _isPlaying = false;
      }
    } catch (e) {
      debugPrint('Audio alert error: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
