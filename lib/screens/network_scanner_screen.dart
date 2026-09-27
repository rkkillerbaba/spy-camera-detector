import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/network_scanner_provider.dart';
import '../core/theme/app_theme.dart';
import '../core/services/network_scanner_service.dart';

class NetworkScannerScreen extends StatefulWidget {
  const NetworkScannerScreen({Key? key}) : super(key: key);

  @override
  State<NetworkScannerScreen> createState() => _NetworkScannerScreenState();
}

class _NetworkScannerScreenState extends State<NetworkScannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NetworkScannerProvider>().fetchNetworkInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final netProv = context.watch<NetworkScannerProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('WI-FI CAM DETECTOR'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw),
            tooltip: 'Refresh Network Info',
            onPressed: () => netProv.fetchNetworkInfo(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            // Wi-Fi Connection Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.neonCyan.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.wifi, color: AppTheme.neonCyan, size: 22),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              netProv.wifiName ?? 'Connected Wi-Fi',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'IP: ${netProv.wifiIp ?? 'Scanning...'} | Subnet: ${netProv.subnet ?? 'Unknown'}.x',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Scan action button
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: netProv.isScanning ? AppTheme.neonRedDim : AppTheme.neonGreen,
                        foregroundColor: netProv.isScanning ? AppTheme.neonRed : Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: netProv.isScanning ? AppTheme.neonRed : Colors.transparent,
                          ),
                        ),
                      ),
                      icon: Icon(netProv.isScanning ? LucideIcons.square : LucideIcons.radar),
                      label: Text(
                        netProv.isScanning ? 'STOP SUBNET SCAN' : 'START LAN CAMERA DISCOVERY',
                        style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.0),
                      ),
                      onPressed: () {
                        if (netProv.isScanning) {
                          netProv.stopScan();
                        } else {
                          netProv.startScan();
                        }
                      },
                    ),
                  ),

                  // Progress bar during scan
                  if (netProv.isScanning) ...[
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: netProv.scanProgress,
                      backgroundColor: AppTheme.surfaceLight,
                      color: AppTheme.neonGreen,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Probing 254 hosts on RTSP, HTTP, ONVIF ports: ${(netProv.scanProgress * 100).toInt()}%',
                      style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Discovered summary strip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'DISCOVERED DEVICES (${netProv.devices.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (netProv.suspiciousCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.neonRedDim,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.neonRed),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.alertOctagon, size: 14, color: AppTheme.neonRed),
                        const SizedBox(width: 4),
                        Text(
                          '${netProv.suspiciousCount} SUSPICIOUS',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neonRed,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),

            // Device List View
            Expanded(
              child: netProv.devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.scanLine,
                            size: 48,
                            color: AppTheme.textMuted.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No devices scanned yet',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap "Start LAN Camera Discovery" above\nto detect active smart/spy devices.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      physics: const BouncingScrollPhysics(),
                      itemCount: netProv.devices.length,
                      itemBuilder: (context, index) {
                        final device = netProv.devices[index];
                        return _buildDeviceCard(device);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard(DiscoveredDevice device) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: device.isSuspicious ? AppTheme.neonRed : AppTheme.border,
          width: device.isSuspicious ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: device.isSuspicious ? AppTheme.neonRedDim : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              device.isSuspicious ? LucideIcons.cctv : LucideIcons.hardDrive,
              color: device.isSuspicious ? AppTheme.neonRed : AppTheme.neonGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      device.ip,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (device.isSuspicious)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.neonRed,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'SPY CAM RISK',
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  device.deviceType,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: device.isSuspicious ? AppTheme.neonRed : AppTheme.textSecondary,
                  ),
                ),
                if (device.openPorts.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Open Ports: ${device.openPorts.join(", ")}',
                    style: const TextStyle(fontSize: 10, color: AppTheme.textMuted, fontFamily: 'monospace'),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${device.responseTimeMs}ms',
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
