import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';

class DiscoveredDevice {
  final String ip;
  final String hostname;
  final int responseTimeMs;
  final bool isSuspicious;
  final String deviceType;
  final List<int> openPorts;

  DiscoveredDevice({
    required this.ip,
    this.hostname = 'Unknown Device',
    required this.responseTimeMs,
    this.isSuspicious = false,
    required this.deviceType,
    this.openPorts = const [],
  });
}

class NetworkScannerService {
  final NetworkInfo _networkInfo = NetworkInfo();

  // Known camera / IoT streaming and management ports
  static const List<int> cameraPorts = [
    80,    // HTTP Web UI
    443,   // HTTPS Web UI
    554,   // RTSP (Standard IP Camera Stream)
    1935,  // RTMP
    8000,  // Hikvision / Generic DVR
    8080,  // Alternate Web Server
    8899,  // ONVIF Device Discovery / Management
    37777, // Dahua DVR/Camera Protocol
  ];

  Future<String?> getWifiIP() async {
    try {
      return await _networkInfo.getWifiIP();
    } catch (e) {
      debugPrint('Error getting Wi-Fi IP: $e');
      return null;
    }
  }

  Future<String?> getWifiName() async {
    try {
      return await _networkInfo.getWifiName();
    } catch (e) {
      debugPrint('Error getting Wi-Fi SSID: $e');
      return null;
    }
  }

  /// Scan subnet across IP range (1 to 254) with concurrency control
  Stream<DiscoveredDevice> scanSubnet({
    required String subnet,
    required void Function(double progress) onProgressUpdate,
  }) async* {
    const totalHosts = 254;
    int scannedCount = 0;

    // Batching to avoid socket exhaustion on mobile devices
    const batchSize = 25;
    for (int i = 1; i <= totalHosts; i += batchSize) {
      final batchTasks = <Future<DiscoveredDevice?>>[];
      final end = (i + batchSize - 1 > totalHosts) ? totalHosts : i + batchSize - 1;

      for (int host = i; host <= end; host++) {
        final targetIp = '$subnet.$host';
        batchTasks.add(_probeHost(targetIp));
      }

      final results = await Future.wait(batchTasks);
      for (final device in results) {
        scannedCount++;
        onProgressUpdate(scannedCount / totalHosts);
        if (device != null) {
          yield device;
        }
      }
    }
  }

  /// Probe host on typical camera and communication ports
  Future<DiscoveredDevice?> _probeHost(String ip) async {
    final openPorts = <int>[];
    final stopwatch = Stopwatch()..start();
    bool hostAlive = false;

    for (final port in cameraPorts) {
      try {
        final socket = await Socket.connect(
          ip,
          port,
          timeout: const Duration(milliseconds: 300),
        );
        socket.destroy();
        openPorts.add(port);
        hostAlive = true;
      } catch (_) {
        // Port closed or unreachable
      }
    }

    stopwatch.stop();

    if (hostAlive) {
      bool suspicious = openPorts.contains(554) ||
          openPorts.contains(8899) ||
          openPorts.contains(37777) ||
          openPorts.contains(8000);

      String type = 'Network Client';
      if (suspicious) {
        type = 'Potential IP Camera / Streaming Device';
      } else if (openPorts.contains(80) || openPorts.contains(8080)) {
        type = 'Web Interface / Router / IoT';
      }

      return DiscoveredDevice(
        ip: ip,
        hostname: 'Host ($ip)',
        responseTimeMs: stopwatch.elapsedMilliseconds,
        isSuspicious: suspicious,
        deviceType: type,
        openPorts: openPorts,
      );
    }

    return null;
  }
}
