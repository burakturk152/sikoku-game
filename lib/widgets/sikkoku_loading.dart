import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:typed_data';

class SikkokuLoading extends StatefulWidget {
  final double size;
  final Color? background;
  final Color? gridBg;

  const SikkokuLoading({
    Key? key,
    this.size = 240.0,
    this.background,
    this.gridBg,
  }) : super(key: key);

  @override
  State<SikkokuLoading> createState() => _SikkokuLoadingState();
}

class _SikkokuLoadingState extends State<SikkokuLoading>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _rotations;
  late List<Animation<double>> _opacities;
  ui.Image? _logoImage;
  Uint8List? _logoBytes;
  ui.Image? _triangleImage;
  ui.Image? _circleImage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Logo1.png'yi yükle
    _loadLogoImage();
    
    // Triangle ve Circle PNG'lerini yükle
    _loadShapeImages();

    // Her hücre için ayrı animasyon
    _rotations = List.generate(9, (index) {
      final start = (index * 0.08).clamp(0.0, 0.7);
      final end = (start + 0.2).clamp(0.0, 1.0);
      return Tween<double>(
        begin: 0.0,
        end: 18.0 * (math.pi / 180), // 18 derece radyan cinsinden
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          start,
          end,
          curve: Curves.easeInOut,
        ),
      ));
    });

    _opacities = List.generate(9, (index) {
      final start = (index * 0.08).clamp(0.0, 0.7);
      final end = (start + 0.2).clamp(0.0, 1.0);
      return Tween<double>(
        begin: 1.0,
        end: 0.3,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          start,
          end,
          curve: Curves.easeInOut,
        ),
      ));
    });

    _controller.repeat();
  }

  Future<void> _loadShapeImages() async {
    try {
      // Triangle PNG'sini yükle
      final triangleCodec = await ui.instantiateImageCodec(
        await DefaultAssetBundle.of(context).load('assets/images/triangle.png').then((data) => data.buffer.asUint8List())
      );
      _triangleImage = (await triangleCodec.getNextFrame()).image;

      // Circle PNG'sini yükle
      final circleCodec = await ui.instantiateImageCodec(
        await DefaultAssetBundle.of(context).load('assets/images/circle.png').then((data) => data.buffer.asUint8List())
      );
      _circleImage = (await circleCodec.getNextFrame()).image;

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Shape görsel yükleme hatası: $e');
    }
  }

  Future<void> _loadLogoImage() async {
    try {
      // Logo1.png'yi yükle
      final logoCodec = await ui.instantiateImageCodec(
        await DefaultAssetBundle.of(context).load('assets/images/logo1.png').then((data) => data.buffer.asUint8List())
      );
      _logoImage = (await logoCodec.getNextFrame()).image;
      
      // Logo bytes'ını cache'le
      _logoBytes = await _logoImage!.toByteData(format: ui.ImageByteFormat.png).then((data) => data!.buffer.asUint8List());

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Logo yükleme hatası: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: _logoBytes != null
          ? Image.memory(
              _logoBytes!,
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
            )
          : Container(
              width: widget.size,
              height: widget.size,
              color: Colors.transparent,
            ),
    );
  }
}

class ShapeOverlayPainter extends CustomPainter {
  final List<Animation<double>> rotations;
  final List<Animation<double>> opacities;
  final ui.Image? triangleImage;
  final ui.Image? circleImage;

  ShapeOverlayPainter({
    required this.rotations,
    required this.opacities,
    this.triangleImage,
    this.circleImage,
  }) : super(repaint: Listenable.merge([...rotations, ...opacities]));

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    final cellSize = size.width / 3;
    final center = Offset(size.width / 2, size.height / 2);

    // Arka plan yok - sadece shape'ler

    // Hücreleri çiz
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 3; col++) {
        final index = row * 3 + col;
        final cellCenter = Offset(
          col * cellSize + cellSize / 2,
          row * cellSize + cellSize / 2,
        );

        canvas.save();
        canvas.translate(cellCenter.dx, cellCenter.dy);
        canvas.rotate(rotations[index].value);
        canvas.translate(-cellCenter.dx, -cellCenter.dy);

        // Desen: [O, △, O] [△, O, △] [O, △, O]
        if ((row + col) % 2 == 0) {
          // Circle PNG - mavi hücrelerde
          if (circleImage != null) {
            final imageSize = cellSize * 0.4;
            final srcRect = Rect.fromLTWH(0, 0, circleImage!.width.toDouble(), circleImage!.height.toDouble());
            final dstRect = Rect.fromCenter(
              center: cellCenter,
              width: imageSize,
              height: imageSize,
            );
            
            // Circle'ı opacity ile çiz
            paint.colorFilter = ColorFilter.mode(
              Colors.white.withOpacity(opacities[index].value),
              BlendMode.srcATop,
            );
            canvas.drawImageRect(
              circleImage!,
              srcRect,
              dstRect,
              paint,
            );
          }
        } else {
          // Triangle PNG - sarı hücrelerde
          if (triangleImage != null) {
            final imageSize = cellSize * 0.4;
            final srcRect = Rect.fromLTWH(0, 0, triangleImage!.width.toDouble(), triangleImage!.height.toDouble());
            final dstRect = Rect.fromCenter(
              center: cellCenter,
              width: imageSize,
              height: imageSize,
            );
            
            // Triangle'ı opacity ile çiz
            paint.colorFilter = ColorFilter.mode(
              Colors.white.withOpacity(opacities[index].value),
              BlendMode.srcATop,
            );
            canvas.drawImageRect(
              triangleImage!,
              srcRect,
              dstRect,
              paint,
            );
          }
        }

        canvas.restore();
      }
    }
  }

  void _drawDiamond(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size); // Üst
    path.lineTo(center.dx + size, center.dy); // Sağ
    path.lineTo(center.dx, center.dy + size); // Alt
    path.lineTo(center.dx - size, center.dy); // Sol
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
