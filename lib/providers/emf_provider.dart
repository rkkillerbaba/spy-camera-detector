import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../core/services/alert_service.dart';

class EmfProvider extends ChangeNotifier {
  final AlertService _alertService = AlertService();
  StreamSubscription<MagnetometerEvent>? _subscription;

  double _x = 0.0;
  double _y = 0.0;
  double _z = 0.0;
  double _magnitude = 0.0;
  double _peakMagnitude = 0.0;

  // Configurable alert threshold in microteslas (µT)
  // Typical Earth ambient background is ~30 to 50 µT. Metals and electronics spike > 65 µT.
  double _threshold = 65.0;

  bool _isScanning = false;
  bool _alertTriggered = false;
  bool _soundVibrateEnabled = true;

  // Historical reading points for graph visualization
  final List<double> _history = [];
  static const int maxHistoryLength = 30;

  // Getters
  double get x => _x;
  double get y => _y;
  double get z => _z;
  double get magnitude => _magnitude;
  double get peakMagnitude => _peakMagnitude;
  double get threshold => _threshold;
  bool get isScanning => _isScanning;
  bool get alertTriggered => _alertTriggered;
  bool get soundVibrateEnabled => _soundVibrateEnabled;
  List<double> get history => List.unmodifiable(_history);

  void setThreshold(double value) {
    _threshold = value;
    notifyListeners();
  }

  void toggleSoundVibrate() {
    _soundVibrateEnabled = !_soundVibrateEnabled;
    notifyListeners();
  }

  void resetPeak() {
    _peakMagnitude = 0.0;
    _history.clear();
    notifyListeners();
  }

  void startListening() {
    if (_isScanning) return;
    _isScanning = true;
    notifyListeners();

    _subscription = magnetometerEventStream().listen(
      (MagnetometerEvent event) {
        _x = event.x;
        _y = event.y;
        _z = event.z;

        // Calculate 3D Euclidean vector magnitude: sqrt(x² + y² + z²)
        _magnitude = sqrt(_x * _x + _y * _y + _z * _z);

        if (_magnitude > _peakMagnitude) {
          _peakMagnitude = _magnitude;
        }

        // Add to history
        _history.add(_magnitude);
        if (_history.length > maxHistoryLength) {
          _history.removeAt(0);
        }

        // Check against alert threshold
        if (_magnitude >= _threshold) {
          _alertTriggered = true;
          if (_soundVibrateEnabled) {
            _alertService.triggerAlert(isHighDanger: _magnitude > (_threshold + 25));
          }
        } else {
          _alertTriggered = false;
        }

        notifyListeners();
      },
      onError: (error) {
        debugPrint('Magnetometer stream error: $error');
        _isScanning = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isScanning = false;
    _alertTriggered = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
