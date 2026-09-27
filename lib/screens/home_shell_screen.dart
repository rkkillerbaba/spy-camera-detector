import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_theme.dart';
import 'emf_detector_screen.dart';
import 'ir_camera_screen.dart';
import 'network_scanner_screen.dart';
import 'guide_screen.dart';

class HomeShellScreen extends StatefulWidget {
  const HomeShellScreen({Key? key}) : super(key: key);

  @override
  State<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends State<HomeShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    EmfDetectorScreen(),
    IrCameraScreen(),
    NetworkScannerScreen(),
    GuideScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppTheme.border, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.compass),
              activeIcon: Icon(LucideIcons.compass, color: AppTheme.neonGreen),
              label: 'EMF Sensor',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.camera),
              activeIcon: Icon(LucideIcons.camera, color: AppTheme.neonPurple),
              label: 'IR Lens',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.wifi),
              activeIcon: Icon(LucideIcons.wifi, color: AppTheme.neonCyan),
              label: 'Wi-Fi Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(LucideIcons.bookOpen),
              activeIcon: Icon(LucideIcons.bookOpen, color: AppTheme.neonYellow),
              label: 'Guide',
            ),
          ],
        ),
      ),
    );
  }
}
