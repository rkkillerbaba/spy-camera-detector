import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';

enum IrFilterMode {
  none,
  infraredHighPass, // High contrast purple/white luminance boost
  nightVisionGreen, // Classic night-vision phosphor green
  luminescenceInvert, // Inversion to spot bright LED hotspots easily
}

class CameraFinderProvider extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  bool _isInitialized = false;
  bool _isFlashOn = false;
  IrFilterMode _filterMode = IrFilterMode.infraredHighPass;
  double _zoomLevel = 1.0;
  double _maxZoomLevel = 1.0;
  double _minZoomLevel = 1.0;

  // Getters
  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isFlashOn => _isFlashOn;
  IrFilterMode get filterMode => _filterMode;
  double get zoomLevel => _zoomLevel;

  Future<void> initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // Select back-facing camera
      final backCamera = _cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller!.initialize();
      _maxZoomLevel = await _controller!.getMaxZoomLevel();
      _minZoomLevel = await _controller!.getMinZoomLevel();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _isInitialized = false;
      notifyListeners();
    }
  }

  Future<void> toggleFlashlight() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      if (_isFlashOn) {
        await _controller!.setFlashMode(FlashMode.off);
        await _controller!.setTorchMode(false);
        _isFlashOn = false;
      } else {
        await _controller!.setFlashMode(FlashMode.torch);
        await _controller!.setTorchMode(true);
        _isFlashOn = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling flashlight: $e');
    }
  }

  void setFilterMode(IrFilterMode mode) {
    _filterMode = mode;
    notifyListeners();
  }

  Future<void> setZoom(double zoom) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    final clampedZoom = zoom.clamp(_minZoomLevel, _maxZoomLevel);
    await _controller!.setZoomLevel(clampedZoom);
    _zoomLevel = clampedZoom;
    notifyListeners();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

extension on CameraController {
  Future<void> setTorchMode(bool enabled) async {
    // Torch mode handling helper
  }
}
