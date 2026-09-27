import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/camera_finder_provider.dart';
import '../core/theme/app_theme.dart';

class IrCameraScreen extends StatefulWidget {
  const IrCameraScreen({Key? key}) : super(key: key);

  @override
  State<IrCameraScreen> createState() => _IrCameraScreenState();
}

class _IrCameraScreenState extends State<IrCameraScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CameraFinderProvider>().initializeCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cameraProv = context.watch<CameraFinderProvider>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('INFRARED / LENS FINDER'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(
              cameraProv.isFlashOn ? LucideIcons.flashlight : LucideIcons.flashlightOff,
              color: cameraProv.isFlashOn ? AppTheme.neonYellow : AppTheme.textMuted,
            ),
            tooltip: 'Flashlight / Lens Reflection Strobe',
            onPressed: () => cameraProv.toggleFlashlight(),
          ),
        ],
      ),
      body: cameraProv.isInitialized && cameraProv.controller != null
          ? Stack(
              children: [
                // Live camera preview with selected IR image filter overlay
                Positioned.fill(
                  child: _buildFilteredCameraPreview(cameraProv),
                ),

                // Targeting Reticle / Crosshair Overlay
                Center(
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.neonGreen.withOpacity(0.5),
                        width: 1.5,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppTheme.neonGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),

                // Guidance Banner
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: const Row(
                      children: [
                        Icon(LucideIcons.eye, color: AppTheme.neonPurple, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Turn off room lights. Look for bright purple/red/white pinpoint light dots on lenses.',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom Floating Control Palette
                Positioned(
                  bottom: 24,
                  left: 16,
                  right: 16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Filter Mode Selector Chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildFilterChip(
                              label: 'IR Glow (Purple)',
                              mode: IrFilterMode.infraredHighPass,
                              activeMode: cameraProv.filterMode,
                              onTap: () => cameraProv.setFilterMode(IrFilterMode.infraredHighPass),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Night Vision',
                              mode: IrFilterMode.nightVisionGreen,
                              activeMode: cameraProv.filterMode,
                              onTap: () => cameraProv.setFilterMode(IrFilterMode.nightVisionGreen),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'High Invert',
                              mode: IrFilterMode.luminescenceInvert,
                              activeMode: cameraProv.filterMode,
                              onTap: () => cameraProv.setFilterMode(IrFilterMode.luminescenceInvert),
                            ),
                            const SizedBox(width: 8),
                            _buildFilterChip(
                              label: 'Normal',
                              mode: IrFilterMode.none,
                              activeMode: cameraProv.filterMode,
                              onTap: () => cameraProv.setFilterMode(IrFilterMode.none),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Zoom Slider control
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surface.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(LucideIcons.zoomIn, size: 16, color: AppTheme.neonGreen),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppTheme.neonGreen,
                                  inactiveTrackColor: AppTheme.surfaceLight,
                                  thumbColor: AppTheme.neonGreen,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  trackHeight: 3,
                                ),
                                child: Slider(
                                  value: cameraProv.zoomLevel,
                                  min: 1.0,
                                  max: 5.0,
                                  onChanged: (val) => cameraProv.setZoom(val),
                                ),
                              ),
                            ),
                            Text(
                              '${cameraProv.zoomLevel.toStringAsFixed(1)}x',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.neonGreen,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppTheme.neonGreen),
                  SizedBox(height: 16),
                  Text(
                    'Initializing High-Sensitivity Camera...',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IrFilterMode mode,
    required IrFilterMode activeMode,
    required VoidCallback onTap,
  }) {
    final isSelected = mode == activeMode;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.neonGreen.withOpacity(0.2) : Colors.black87,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.neonGreen : AppTheme.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppTheme.neonGreen : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildFilteredCameraPreview(CameraFinderProvider cameraProv) {
    Widget preview = CameraPreview(cameraProv.controller!);

    // Color filter transformation overlay matrices for IR enhancement
    switch (cameraProv.filterMode) {
      case IrFilterMode.infraredHighPass:
        // Enhance violet/cyan spectral bands and compress red wavelengths
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            1.8, 0.0, 0.2, 0.0, 20, // R
            0.1, 0.8, 0.9, 0.0, 10, // G
            1.2, 0.1, 2.0, 0.0, 40, // B (IR glow spectral boost)
            0.0, 0.0, 0.0, 1.0, 0,  // A
          ]),
          child: preview,
        );

      case IrFilterMode.nightVisionGreen:
        // Monochromatic green channel phosphor matrix
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            0.0, 0.0, 0.0, 0.0, 0,
            0.3, 0.6, 0.1, 0.0, 30, // Green luminance
            0.0, 0.0, 0.0, 0.0, 0,
            0.0, 0.0, 0.0, 1.0, 0,
          ]),
          child: preview,
        );

      case IrFilterMode.luminescenceInvert:
        // Negative luminescence filter for spotting high-intensity specular reflection
        return ColorFiltered(
          colorFilter: const ColorFilter.matrix([
            -1.0,  0.0,  0.0, 0.0, 255,
             0.0, -1.0,  0.0, 0.0, 255,
             0.0,  0.0, -1.0, 0.0, 255,
             0.0,  0.0,  0.0, 1.0,   0,
          ]),
          child: preview,
        );

      case IrFilterMode.none:
      default:
        return preview;
    }
  }
}
