import 'dart:async';
import 'package:flutter/foundation.dart';
import '../core/services/network_scanner_service.dart';

class NetworkScannerProvider extends ChangeNotifier {
  final NetworkScannerService _service = NetworkScannerService();

  String? _wifiIp;
  String? _wifiName;
  String? _subnet;
  bool _isScanning = false;
  double _scanProgress = 0.0;
  final List<DiscoveredDevice> _devices = [];
  StreamSubscription<DiscoveredDevice>? _scanSubscription;

  // Getters
  String? get wifiIp => _wifiIp;
  String? get wifiName => _wifiName;
  String? get subnet => _subnet;
  bool get isScanning => _isScanning;
  double get scanProgress => _scanProgress;
  List<DiscoveredDevice> get devices => List.unmodifiable(_devices);
  int get suspiciousCount => _devices.where((d) => d.isSuspicious).length;

  Future<void> fetchNetworkInfo() async {
    _wifiIp = await _service.getWifiIP();
    _wifiName = await _service.getWifiName();

    if (_wifiIp != null && _wifiIp!.contains('.')) {
      final parts = _wifiIp!.split('.');
      if (parts.length >= 3) {
        _subnet = '${parts[0]}.${parts[1]}.${parts[2]}';
      }
    }
    notifyListeners();
  }

  void startScan() async {
    if (_isScanning) return;
    await fetchNetworkInfo();

    if (_subnet == null) {
      debugPrint('No valid subnet detected. Are you connected to Wi-Fi?');
      return;
    }

    _isScanning = true;
    _scanProgress = 0.0;
    _devices.clear();
    notifyListeners();

    _scanSubscription?.cancel();
    _scanSubscription = _service
        .scanSubnet(
          subnet: _subnet!,
          onProgressUpdate: (progress) {
            _scanProgress = progress;
            notifyListeners();
          },
        )
        .listen(
          (device) {
            _devices.add(device);
            notifyListeners();
          },
          onDone: () {
            _isScanning = false;
            _scanProgress = 1.0;
            notifyListeners();
          },
          onError: (err) {
            debugPrint('Scan error: $err');
            _isScanning = false;
            notifyListeners();
          },
        );
  }

  void stopScan() {
    _scanSubscription?.cancel();
    _isScanning = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }
}
