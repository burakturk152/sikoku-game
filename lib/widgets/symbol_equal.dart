import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class EqualIcon extends StatelessWidget {
  final double size;
  final Color color;
  final double barThickness;
  final double gap;
  final double cornerRadius;

  const EqualIcon({
    Key? key,
    this.size = 44,
    this.color = Colors.white,
    this.barThickness = 6,
    this.gap = 8,
    this.cornerRadius = 999,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(size, size),
        painter: _EqualIconPainter(
          color: color,
          barThickness: barThickness,
          gap: gap,
          cornerRadius: cornerRadius,
        ),
      ),
    );
  }
}

class _EqualIconPainter extends CustomPainter {
  final Color color;
  final double barThickness;
  final double gap;
  final double cornerRadius;

  _EqualIconPainter({
    required this.color,
    required this.barThickness,
    required this.gap,
    required this.cornerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    
    // Yardımcı fonksiyonlar
    double toPhysical(double logical) => logical * dpr;
    double toLogical(double physical) => physical / dpr;
    double snap(double logical) => toLogical(toPhysical(logical).roundToDouble());
    
    double snappedThickness(double logicalThickness) {
      final phys = (logicalThickness * dpr).round().clamp(1, 10000);
      return phys / dpr;
    }

    // Güvenli iç boşluk (%12 padding)
    final padding = size.width * 0.12;
    final contentWidth = size.width - (padding * 2);
    final contentHeight = size.height - (padding * 2);
    
    // Merkez koordinatları
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Bar kalınlığını pixel-snap et
    final snappedBarThickness = snappedThickness(barThickness);
    final snappedGap = snap(gap);
    
    // Üst bar koordinatları
    final topBarTop = centerY - (snappedGap / 2) - snappedBarThickness;
    final topBarBottom = centerY - (snappedGap / 2);
    
    // Alt bar koordinatları
    final bottomBarTop = centerY + (snappedGap / 2);
    final bottomBarBottom = centerY + (snappedGap / 2) + snappedBarThickness;
    
    // Bar genişliği
    final barWidth = contentWidth;
    final barLeft = centerX - (barWidth / 2);
    final barRight = centerX + (barWidth / 2);
    
    // Paint objesi
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Üst bar çiz
    final topBarRect = RRect.fromLTRBR(
      barLeft,
      topBarTop,
      barRight,
      topBarBottom,
      Radius.circular(cornerRadius),
    );
    canvas.drawRRect(topBarRect, paint);
    
    // Alt bar çiz
    final bottomBarRect = RRect.fromLTRBR(
      barLeft,
      bottomBarTop,
      barRight,
      bottomBarBottom,
      Radius.circular(cornerRadius),
    );
    canvas.drawRRect(bottomBarRect, paint);
  }

  @override
  bool shouldRepaint(covariant _EqualIconPainter oldDelegate) {
    return color != oldDelegate.color ||
           barThickness != oldDelegate.barThickness ||
           gap != oldDelegate.gap ||
           cornerRadius != oldDelegate.cornerRadius;
  }
}

// Demo Screen (sadece geliştirme/test için)
class SymbolEqualDemoScreen extends StatelessWidget {
  const SymbolEqualDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Equal Icon Demo'),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildDemoRow(24, 'Size 24'),
            const SizedBox(height: 40),
            _buildDemoRow(28, 'Size 28'),
            const SizedBox(height: 40),
            _buildDemoRow(32, 'Size 32'),
            const SizedBox(height: 40),
            _buildDemoRow(44, 'Size 44'),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoRow(double size, String label) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            EqualIcon(size: size),
          ],
        ),
        const SizedBox(width: 40),
        Column(
          children: [
            const Text(
              'Zoomed 2.2x',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Transform.scale(
              scale: 2.2,
              child: EqualIcon(size: size),
            ),
          ],
        ),
      ],
    );
  }
}
