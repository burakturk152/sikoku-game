import 'dart:math' as math;
import 'package:flutter/material.dart';

class LevelPathLayout extends StatelessWidget {
  const LevelPathLayout({
    super.key,
    required this.polylinePoints, // SVG <polyline points="...">
    required this.viewBoxSize,    // Illustrator viewBox (width, height)
    required this.levelCount,     // kaç buton
    required this.onLevelTap,     // butona tıklandığında
    this.background,
    this.buttonSize = 44,
    this.startOffsetRatio = 0.06, // yolun %6'sından sonra başla
    this.endOffsetRatio = 0.00,   // yolun sonunda pay bırakma
    this.debugShowPath = false,
    this.unlockedLevels = const <int>[],
    this.levelStars = const <int, int>{},
  });

  final String polylinePoints;
  final Size viewBoxSize;
  final int levelCount;
  final void Function(int levelIndex) onLevelTap;

  final ImageProvider? background;
  final double buttonSize;
  final double startOffsetRatio;
  final double endOffsetRatio;
  final bool debugShowPath;
  final List<int> unlockedLevels;
  final Map<int, int> levelStars;

  // --- SVG polyline "points" string'ini (x y x y ...) -> List<Offset> dönüştürür
  List<Offset> _parsePolylinePoints(String raw) {
    // Virgül, yeni satır ve boşluk ayracıyla ayır
    final tokens = raw.trim().split(RegExp(r'[\s,]+')).where((t) => t.isNotEmpty);
    final nums = <double>[];
    for (var t in tokens) {
      // ".1" veya "-.2" gibi değerleri "0.1", "-0.2"e çevir (Illustrator bazen böyle yazıyor)
      if (t.startsWith('.')) t = '0$t';
      if (t.startsWith('-.')) t = t.replaceFirst('-.', '-0.');
      nums.add(double.parse(t));
    }
    final points = <Offset>[];
    for (int i = 0; i + 1 < nums.length; i += 2) {
      points.add(Offset(nums[i], nums[i + 1]));
    }
    return points;
  }

  // Eşit aralık hesaplama - PathMetric kullanarak
  List<Offset> _getPointsOnPath(List<Offset> points, int count, double startRatio, double endRatio) {
    if (points.length < 2) return [];
    
    final result = <Offset>[];
    
    // Path oluştur
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    // PathMetric hesapla
    final pathMetric = path.computeMetrics().first;
    final total = pathMetric.length;
    
    // Eşit dağıtım hesaplama - modulo kullanmadan
    final start = total * startRatio;
    final end = total * (1.0 - (endRatio ?? 0.0));
    final avail = (end - start).clamp(1.0, total);
    final step = avail / count;
    
    for (int i = 0; i < count; i++) {
      final at = (start + step * (i + 0.5)).clamp(0.0, total - 1e-6);
      
      // Tangent hesapla
      final tangent = pathMetric.getTangentForOffset(at);
      if (tangent != null) {
        result.add(tangent.position);
      }
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cons) {
      final screen = Size(cons.maxWidth, cons.maxHeight);

      // 1) Polyline -> Points
      final polyPts = _parsePolylinePoints(polylinePoints);
      if (polyPts.isEmpty) {
        return const SizedBox.shrink();
      }

      // 2) viewBox -> ekran ölçeklemesi
      final sx = screen.width / viewBoxSize.width;
      final sy = screen.height / viewBoxSize.height;
      
      final scaledPoints = polyPts.map((p) => 
        Offset(p.dx * sx, p.dy * sy)
      ).toList();

      // 3) Path üzerinde noktalar hesapla
      final samplePoints = _getPointsOnPath(scaledPoints, levelCount, startOffsetRatio, endOffsetRatio);

      final children = <Widget>[];

      if (background != null) {
        children.add(Positioned.fill(
          child: Image(image: background!, fit: BoxFit.cover),
        ));
      }

      // İsteğe bağlı debug path çizimi
      if (debugShowPath) {
        children.add(Positioned.fill(
          child: CustomPaint(painter: _PathPainter(scaledPoints)),
        ));
      }

      // Level butonları
      for (int i = 0; i < samplePoints.length; i++) {
        final p = samplePoints[i];
        final levelIndex = i + 1;
        final isUnlocked = unlockedLevels.contains(levelIndex);
        final stars = levelStars[levelIndex] ?? 0;
        
        children.add(Positioned(
          left: p.dx - buttonSize / 2,
          top: p.dy - buttonSize / 2,
          child: _LevelCircle(
            label: '$levelIndex',
            size: buttonSize,
            isUnlocked: isUnlocked,
            stars: stars,
            onTap: isUnlocked ? () => onLevelTap(levelIndex) : null,
          ),
        ));
      }

      return Stack(clipBehavior: Clip.none, children: children);
    });
  }
}

class _LevelCircle extends StatelessWidget {
  const _LevelCircle({
    required this.label,
    required this.size,
    required this.isUnlocked,
    required this.stars,
    this.onTap,
  });

  final String label;
  final double size;
  final bool isUnlocked;
  final int stars;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ana buton
          Stack(
            alignment: Alignment.center,
            children: [
              // Alt katman: Beyaz halo (glow) - sadece açık level'lar için
              if (isUnlocked)
                SizedBox(
                  width: size + 10,
                  height: size + 10,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                    ),
                  ),
                ),
              
              // Orta katman: Daire
              SizedBox(
                width: size,
                height: size,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked 
                      ? const Color(0xFF2F73FF) // açık level'lar için mavi
                      : Colors.grey.shade300, // kilitli level'lar için net gri
                    border: Border.all(
                      color: isUnlocked ? Colors.white : Colors.grey.shade400, 
                      width: 2
                    ),
                  ),
                ),
              ),
              
              // Üst katman: İçerik (rakam veya kilit simgesi)
              if (isUnlocked)
                // Açık level'lar için rakam
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                )
              else
                // Kilitli level'lar için kilit simgesi
                Icon(
                  Icons.lock,
                  color: Colors.grey.shade600,
                  size: size * 0.4,
                ),
            ],
          ),
          
                                                                                     // Yıldızlar - sadece açık level'lar için
             if (isUnlocked && stars > 0)
               Transform.translate(
                 offset: const Offset(0, -4),
                 child: Row(
                   mainAxisSize: MainAxisSize.min,
                   children: List.generate(3, (index) {
                     return Icon(
                       index < stars ? Icons.star : Icons.star_border,
                       color: index < stars ? Colors.amber : Colors.grey.shade400,
                       size: 10,
                     );
                   }),
                 ),
               ),
        ],
      ),
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter(this.points);
  final List<Offset> points;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _PathPainter oldDelegate) => false;
}
