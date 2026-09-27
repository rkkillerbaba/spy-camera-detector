import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'core/theme/app_theme.dart';
import 'providers/emf_provider.dart';
import 'providers/camera_finder_provider.dart';
import 'providers/network_scanner_provider.dart';
import 'screens/home_shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Enforce portrait mode and dark status bar navigation styling
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Request runtime camera and location permissions for Android 8+ Wi-Fi / Sensor scans
  await [
    Permission.camera,
    Permission.locationWhenInUse,
  ].request();

  runApp(const SpyCameraDetectorApp());
}

class SpyCameraDetectorApp extends StatelessWidget {
  const SpyCameraDetectorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => EmfProvider()),
        ChangeNotifierProvider(create: (_) => CameraFinderProvider()),
        ChangeNotifierProvider(create: (_) => NetworkScannerProvider()),
      ],
      child: MaterialApp(
        title: 'Spy Camera Detector',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const HomeShellScreen(),
      ),
    );
  }
}
