import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../models/puzzle_data.dart';

class CirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width * 0.12).clamp(1.5, 4.0);
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2 - 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiamondPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.width * 0.12).clamp(1.5, 4.0);
    
    final path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height / 2);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(0, size.height / 2);
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HintsPainter extends CustomPainter {
  final List<List<int>> hints;
  final double cellSize;
  final double gap;
  final int cellCount;
  ui.Image? equalImage;
  ui.Image? notEqualImage;

  HintsPainter({
    required this.hints,
    required this.cellSize,
    required this.gap,
    required this.cellCount,
    this.equalImage,
    this.notEqualImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Color(0xFFF5F5F5) // Kırık beyaz tonu (saydam değil)
      ..style = PaintingStyle.fill;

    final textPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;

    for (final hint in hints) {
      final cell1 = [hint[0], hint[1]];
      final cell2 = [hint[2], hint[3]];
      final hintType = hint.length > 4 ? hint[4] : 0; // 0 = equal, 1 = not_equal
      
      // Sadece yan yana veya alt alta olan hücreler için sembol göster
      if (_areAdjacent(cell1, cell2)) {
        final center1 = _getCellCenter(cell1[0], cell1[1]);
        final center2 = _getCellCenter(cell2[0], cell2[1]);
        final symbolCenter = Offset(
          (center1.dx + center2.dx) / 2,
          (center1.dy + center2.dy) / 2,
        );

        // Dolu yuvarlak çerçeve çiz
        final circleRadius = cellSize * 0.25;
        canvas.drawCircle(symbolCenter, circleRadius, fillPaint); // İçini tamamen doldur
        canvas.drawCircle(symbolCenter, circleRadius, paint); // Kenarlığını çiz

        // PNG görsellerini kullan
        bool isVertical = _isVerticalConnection(cell1, cell2);
        final imageSize = cellSize * 0.4; // Görsel boyutu
        
                 if (hintType == 0) {
           // EqualIcon mantığını kullan - pixel-snapped fill tabanlı çizim
           _drawEqualIcon(canvas, symbolCenter, imageSize, isVertical);
                 } else if (hintType == 1 && notEqualImage != null) {
           final src = Rect.fromLTWH(0, 0, notEqualImage!.width.toDouble(), notEqualImage!.height.toDouble());
           
           // Ana görsel çiz
           canvas.drawImageRect(
             notEqualImage!,
             src,
             Rect.fromCenter(
               center: symbolCenter,
               width: imageSize,
               height: imageSize,
             ),
             Paint(),
           );
         }
      }
    }
  }

  bool _areAdjacent(List<int> cell1, List<int> cell2) {
    final row1 = cell1[0];
    final col1 = cell1[1];
    final row2 = cell2[0];
    final col2 = cell2[1];
    
    if (row1 == row2 && (col1 == col2 - 1 || col1 == col2 + 1)) {
      return true;
    }
    
    if (col1 == col2 && (row1 == row2 - 1 || row1 == row2 + 1)) {
      return true;
    }
    
    return false;
  }

  bool _isVerticalConnection(List<int> cell1, List<int> cell2) {
    final row1 = cell1[0];
    final col1 = cell1[1];
    final row2 = cell2[0];
    final col2 = cell2[1];
    
    return col1 == col2 && (row1 == row2 - 1 || row1 == row2 + 1);
  }

  Offset _getCellCenter(int row, int col) {
    final x = col * (cellSize + gap) + cellSize / 2;
    final y = row * (cellSize + gap) + cellSize / 2;
    return Offset(x, y);
  }

  void _drawEqualIcon(Canvas canvas, Offset center, double size, bool isVertical) {
    final dpr = ui.PlatformDispatcher.instance.views.first.devicePixelRatio;
    
    // Yardımcı fonksiyonlar
    double toPhysical(double logical) => logical * dpr;
    double toLogical(double physical) => physical / dpr;
    double snap(double logical) => toLogical(toPhysical(logical).roundToDouble());
    
    double snappedThickness(double logicalThickness) {
      final phys = (logicalThickness * dpr).round().clamp(1, 10000);
      return phys / dpr;
    }

    // Parametreler
    final barThickness = size * 0.15; // Boyuta göre orantılı kalınlık
    final gap = size * 0.2; // Boyuta göre orantılı boşluk
    final cornerRadius = 999; // Kapsül şekli
    
    // Güvenli iç boşluk (%12 padding)
    final padding = size * 0.12;
    final contentWidth = size - (padding * 2);
    final contentHeight = size - (padding * 2);
    
    // Merkez koordinatları
    final centerX = center.dx;
    final centerY = center.dy;
    
    // Bar kalınlığını pixel-snap et
    final snappedBarThickness = snappedThickness(barThickness);
    final snappedGap = snap(gap);
    
    // Bar genişliği
    final barWidth = contentWidth;
    final barLeft = centerX - (barWidth / 2);
    final barRight = centerX + (barWidth / 2);
    
    // Paint objesi
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    if (isVertical) {
      // Dikey bağlantı için 90 derece döndürülmüş eşittir işareti
      canvas.save();
      canvas.translate(centerX, centerY);
      canvas.rotate(90 * 3.14159 / 180);
      
      // Üst bar koordinatları (döndürülmüş)
      final topBarTop = -(snappedGap / 2) - snappedBarThickness;
      final topBarBottom = -(snappedGap / 2);
      
      // Alt bar koordinatları (döndürülmüş)
      final bottomBarTop = (snappedGap / 2);
      final bottomBarBottom = (snappedGap / 2) + snappedBarThickness;
      
      // Döndürülmüş bar genişliği
      final rotatedBarWidth = contentHeight;
      final rotatedBarLeft = -(rotatedBarWidth / 2);
      final rotatedBarRight = (rotatedBarWidth / 2);
      
      // Üst bar çiz (döndürülmüş)
      final topBarRect = RRect.fromLTRBR(
        rotatedBarLeft,
        topBarTop,
        rotatedBarRight,
        topBarBottom,
        Radius.circular(cornerRadius.toDouble()),
      );
      canvas.drawRRect(topBarRect, paint);
      
      // Alt bar çiz (döndürülmüş)
      final bottomBarRect = RRect.fromLTRBR(
        rotatedBarLeft,
        bottomBarTop,
        rotatedBarRight,
        bottomBarBottom,
        Radius.circular(cornerRadius.toDouble()),
      );
      canvas.drawRRect(bottomBarRect, paint);
      
      canvas.restore();
    } else {
      // Yatay bağlantı için normal eşittir işareti
      
      // Üst bar koordinatları
      final topBarTop = centerY - (snappedGap / 2) - snappedBarThickness;
      final topBarBottom = centerY - (snappedGap / 2);
      
      // Alt bar koordinatları
      final bottomBarTop = centerY + (snappedGap / 2);
      final bottomBarBottom = centerY + (snappedGap / 2) + snappedBarThickness;
      
      // Üst bar çiz
      final topBarRect = RRect.fromLTRBR(
        barLeft,
        topBarTop,
        barRight,
        topBarBottom,
        Radius.circular(cornerRadius.toDouble()),
      );
      canvas.drawRRect(topBarRect, paint);
      
      // Alt bar çiz
      final bottomBarRect = RRect.fromLTRBR(
        barLeft,
        bottomBarTop,
        barRight,
        bottomBarBottom,
        Radius.circular(cornerRadius.toDouble()),
      );
      canvas.drawRRect(bottomBarRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is! HintsPainter) return true;
    
    // Sadece hints değiştiğinde repaint yap
    if (hints.length != oldDelegate.hints.length) return true;
    
    for (int i = 0; i < hints.length; i++) {
      if (hints[i][0] != oldDelegate.hints[i][0] ||
          hints[i][1] != oldDelegate.hints[i][1] ||
          hints[i][2] != oldDelegate.hints[i][2] ||
          hints[i][3] != oldDelegate.hints[i][3] ||
          (hints[i].length > 4 ? hints[i][4] : 0) != (oldDelegate.hints[i].length > 4 ? oldDelegate.hints[i][4] : 0)) {
        return true;
      }
    }
    
    // Cell size veya gap değiştiğinde repaint yap
    if (cellSize != oldDelegate.cellSize || 
        gap != oldDelegate.gap || 
        cellCount != oldDelegate.cellCount) {
      return true;
    }
    
    return false;
  }
} 