import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class RadarGraphWidget extends StatelessWidget {
  final List<double> history;
  final double threshold;

  const RadarGraphWidget({
    Key? key,
    required this.history,
    required this.threshold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
                'SIGNAL TIMELINE GRAPH',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppTheme.textSecondary,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.neonRed,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Threshold: ${threshold.toInt()} µT',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _WaveformPainter(history: history, threshold: threshold),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveformPainter extends CustomPainter {
  final List<double> history;
  final double threshold;

  _WaveformPainter({required this.history, required this.threshold});

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    // Draw background grid lines
    final gridPaint = Paint()
      ..color = AppTheme.border.withOpacity(0.5)
      ..strokeWidth = 1.0;

    canvas.drawLine(Offset(0, size.height * 0.33), Offset(size.width, size.height * 0.33), gridPaint);
    canvas.drawLine(Offset(0, size.height * 0.66), Offset(size.width, size.height * 0.66), gridPaint);

    // Draw threshold line
    const maxVal = 150.0;
    final thresholdY = size.height - (threshold / maxVal * size.height).clamp(0.0, size.height);
    final threshPaint = Paint()
      ..color = AppTheme.neonRed.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, thresholdY), Offset(size.width, thresholdY), threshPaint);

    // Draw signal wave
    final linePaint = Paint()
      ..color = AppTheme.neonGreen
      ..strokeWidth = 2.0
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppTheme.neonGreen.withOpacity(0.35),
          AppTheme.neonGreen.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final stepX = size.width / (history.length - 1 > 0 ? (history.length - 1) : 1);

    for (int i = 0; i < history.length; i++) {
      final val = history[i].clamp(0.0, maxVal);
      final x = i * stepX;
      final y = size.height - (val / maxVal * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.moveTo(x, size.height);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    fillPath.lineTo((history.length - 1) * stepX, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _WaveformPainter oldDelegate) {
    return true;
  }
}
