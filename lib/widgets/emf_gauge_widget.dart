import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class EmfGaugeWidget extends StatelessWidget {
  final double value;
  final double maxRange;
  final double threshold;

  const EmfGaugeWidget({
    Key? key,
    required this.value,
    this.maxRange = 150.0,
    required this.threshold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDanger = value >= threshold;
    final normalized = (value / maxRange).clamp(0.0, 1.0);

    return SizedBox(
      width: 250,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(250, 250),
            painter: _EmfGaugePainter(
              progress: normalized,
              thresholdProgress: (threshold / maxRange).clamp(0.0, 1.0),
              isDanger: isDanger,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace',
                  color: isDanger ? AppTheme.neonRed : AppTheme.neonGreen,
                  shadows: [
                    Shadow(
                      color: isDanger ? AppTheme.neonRed : AppTheme.neonGreen,
                      blurRadius: 18,
                    ),
                  ],
                ),
              ),
              const Text(
                'µT (Microtesla)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDanger ? AppTheme.neonRedDim : AppTheme.neonGreenDim,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDanger ? AppTheme.neonRed : AppTheme.neonGreen,
                  ),
                ),
                child: Text(
                  isDanger ? 'POTENTIAL SPY CAM DETECTED' : 'NORMAL AMBIENT EMF',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDanger ? AppTheme.neonRed : AppTheme.neonGreen,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmfGaugePainter extends CustomPainter {
  final double progress;
  final double thresholdProgress;
  final bool isDanger;

  _EmfGaugePainter({
    required this.progress,
    required this.thresholdProgress,
    required this.isDanger,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 16;
    const startAngle = 0.75 * pi;
    const sweepAngle = 1.5 * pi;

    // Background track arc
    final bgPaint = Paint()
      ..color = AppTheme.surfaceLight
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Active progress arc
    final activePaint = Paint()
      ..shader = SweepGradient(
        startAngle: startAngle,
        endAngle: startAngle + sweepAngle,
        colors: const [
          AppTheme.neonGreen,
          AppTheme.neonYellow,
          AppTheme.neonRed,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle * progress,
      false,
      activePaint,
    );

    // Threshold indicator tick
    final tickAngle = startAngle + (sweepAngle * thresholdProgress);
    final tickInner = Offset(
      center.dx + (radius - 10) * cos(tickAngle),
      center.dy + (radius - 10) * sin(tickAngle),
    );
    final tickOuter = Offset(
      center.dx + (radius + 10) * cos(tickAngle),
      center.dy + (radius + 10) * sin(tickAngle),
    );

    final tickPaint = Paint()
      ..color = AppTheme.neonRed
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(tickInner, tickOuter, tickPaint);
  }

  @override
  bool shouldRepaint(covariant _EmfGaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.thresholdProgress != thresholdProgress ||
        oldDelegate.isDanger != isDanger;
  }
}
