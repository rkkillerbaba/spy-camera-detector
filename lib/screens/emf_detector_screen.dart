import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/emf_provider.dart';
import '../core/theme/app_theme.dart';
import '../widgets/emf_gauge_widget.dart';
import '../widgets/radar_graph_widget.dart';

class EmfDetectorScreen extends StatefulWidget {
  const EmfDetectorScreen({Key? key}) : super(key: key);

  @override
  State<EmfDetectorScreen> createState() => _EmfDetectorScreenState();
}

class _EmfDetectorScreenState extends State<EmfDetectorScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmfProvider>().startListening();
    });
  }

  @override
  Widget build(BuildContext context) {
    final emf = context.watch<EmfProvider>();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('EMF DETECTOR'),
        actions: [
          IconButton(
            icon: Icon(
              emf.soundVibrateEnabled ? LucideIcons.volume2 : LucideIcons.volumeX,
              color: emf.soundVibrateEnabled ? AppTheme.neonGreen : AppTheme.textMuted,
            ),
            tooltip: 'Sound & Haptic Feedback',
            onPressed: () => emf.toggleSoundVibrate(),
          ),
          IconButton(
            icon: const Icon(LucideIcons.rotateCcw),
            tooltip: 'Reset Peak',
            onPressed: () => emf.resetPeak(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // Alert Warning Banner
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: emf.alertTriggered ? AppTheme.neonRedDim : AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: emf.alertTriggered ? AppTheme.neonRed : AppTheme.border,
                  width: emf.alertTriggered ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    emf.alertTriggered ? LucideIcons.alertTriangle : LucideIcons.shieldCheck,
                    color: emf.alertTriggered ? AppTheme.neonRed : AppTheme.neonGreen,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      emf.alertTriggered
                          ? 'WARNING: High EMF field detected! Hidden electronic camera/mic nearby.'
                          : 'Scanner Active. Sweep slowly across suspicious objects or wall crevices.',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: emf.alertTriggered ? AppTheme.neonRed : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            EmfGaugeWidget(
              value: emf.magnitude,
              threshold: emf.threshold,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildAxisCard('X AXIS', emf.x.toStringAsFixed(1), 'µT'),
                const SizedBox(width: 8),
                _buildAxisCard('Y AXIS', emf.y.toStringAsFixed(1), 'µT'),
                const SizedBox(width: 8),
                _buildAxisCard('Z AXIS', emf.z.toStringAsFixed(1), 'µT'),
                const SizedBox(width: 8),
                _buildAxisCard('PEAK', emf.peakMagnitude.toStringAsFixed(1), 'µT', isPeak: true),
              ],
            ),
            const SizedBox(height: 16),
            RadarGraphWidget(
              history: emf.history,
              threshold: emf.threshold,
            ),
            const SizedBox(height: 16),
            _buildThresholdSlider(context, emf),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildThresholdSlider(BuildContext context, EmfProvider emf) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ALERT THRESHOLD',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.textSecondary),
              ),
              Text(
                '${emf.threshold.toInt()} µT',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.neonGreen, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppTheme.neonGreen,
              inactiveTrackColor: AppTheme.surfaceLight,
              thumbColor: AppTheme.neonGreen,
              overlayColor: AppTheme.neonGreenDim,
              trackHeight: 4,
            ),
            child: Slider(
              value: emf.threshold,
              min: 40.0,
              max: 120.0,
              divisions: 16,
              onChanged: (val) => emf.setThreshold(val),
            ),
          ),
          const Text(
            'Ambient background is ~45 µT. Move near electronics to trigger acoustic & haptic alerts.',
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildAxisCard(String title, String value, String unit, {bool isPeak = false}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPeak ? AppTheme.neonRed.withOpacity(0.4) : AppTheme.border,
          ),
        ),
        child: Column(
          children: [
            Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPeak ? AppTheme.neonRed : AppTheme.textMuted)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: isPeak ? AppTheme.neonRed : AppTheme.textPrimary)),
            Text(unit, style: const TextStyle(fontSize: 9, color: AppTheme.textMuted)),
          ],
        ),
      ),
    );
  }
}
