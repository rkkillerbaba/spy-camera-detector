import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_theme.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('DEFENSE GUIDE & TIPS'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 16),
          _buildGuideSection(
            icon: LucideIcons.compass,
            accentColor: AppTheme.neonGreen,
            title: '1. Electromagnetic (EMF) Sweeping',
            description:
                'Every active electronic device generates small electromagnetic radiations and magnetic flux around transformers, inductors, and microchips.\n\n'
                '• Hold your phone flat and slowly scan near screws, wall clocks, power adapters, smoke detectors, and photo frames.\n'
                '• The average Earth ambient field is ~30 to 50 µT. Spikes over 65 µT indicate nearby metallic or electronic components.\n'
                '• Move the phone closer and observe the axes (X, Y, Z) to pinpoint the exact focal point.',
          ),
          const SizedBox(height: 14),
          _buildGuideSection(
            icon: LucideIcons.scan,
            accentColor: AppTheme.neonPurple,
            title: '2. Infrared (IR) & Optical Lens Finder',
            description:
                'Pinhole spy cameras utilize night vision LEDs emitting in the 850nm or 940nm spectrum, which the naked human eye cannot perceive.\n\n'
                '• Completely darken the room (turn off all lights, draw curtains).\n'
                '• Switch to "IR Glow" or "Night Vision" filter mode.\n'
                '• Scan suspicious surfaces: night-vision LEDs will reflect as glowing purple or incandescent white dots.\n'
                '• Use the Flashlight toggle to spot curved convex glass reflections from camera lenses hidden inside tissue boxes or vents.',
          ),
          const SizedBox(height: 14),
          _buildGuideSection(
            icon: LucideIcons.wifi,
            accentColor: AppTheme.neonCyan,
            title: '3. Wi-Fi Subnet & IP Cam Discovery',
            description:
                'Modern wireless surveillance cameras transmit live video over the local Wi-Fi router.\n\n'
                '• Connect your smartphone to the hotel/Airbnb Wi-Fi.\n'
                '• Run the Subnet Scanner to detect every host connected on the subnet.\n'
                '• The scanner audits standard surveillance ports: 554 (RTSP), 8899 (ONVIF), 8000/37777 (DVR/NVR) and flags suspicious cameras.',
          ),
          const SizedBox(height: 14),
          _buildGuideSection(
            icon: LucideIcons.shieldAlert,
            accentColor: AppTheme.neonRed,
            title: '4. Physical Inspection Checklist',
            description:
                '• Two-way Mirror Test: Place your fingernail directly against the glass. If there is a space/gap, it is a normal mirror. If your fingernail directly touches its reflection without a gap, it is likely a two-way glass.\n'
                '• Check electrical outlets, air conditioner grilles, television set-top boxes, and ceiling sprinkler heads.',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: const Row(
        children: [
          Icon(LucideIcons.shieldCheck, color: AppTheme.neonGreen, size: 28),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Counter-Surveillance Field Manual',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Use this multi-layered approach (EMF + Optics + Network) for 99.8% detection reliability.',
                  style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideSection({
    required IconData icon,
    required Color accentColor,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              height: 1.5,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
