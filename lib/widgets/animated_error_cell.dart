import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedErrorCell extends StatefulWidget {
  final Widget child;
  final bool isError;
  final bool canRevealMistakes;
  final VoidCallback? onTap;
  final double cellSize;

  const AnimatedErrorCell({
    Key? key,
    required this.child,
    required this.isError,
    required this.canRevealMistakes,
    this.onTap,
    required this.cellSize,
  }) : super(key: key);

  @override
  State<AnimatedErrorCell> createState() => _AnimatedErrorCellState();
}

class _AnimatedErrorCellState extends State<AnimatedErrorCell>
    with TickerProviderStateMixin {
  late AnimationController _haloController;
  late AnimationController _shakeController;
  late Animation<double> _haloAnimation;
  late Animation<double> _shakeAnimation;
  
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    
    // Halo animasyonu (yanıp sönen efekt)
    _haloController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _haloAnimation = Tween<double>(
      begin: 0.05,
      end: 0.25,
    ).animate(CurvedAnimation(
      parent: _haloController,
      curve: Curves.easeInOut,
    ));
    
    // Shake animasyonu (sarsma efekti)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _shakeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedErrorCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // canRevealMistakes değiştiğinde animasyonu başlat/durdur
    if (widget.canRevealMistakes && widget.isError && !_isAnimating) {
      _startAnimations();
    } else if (!widget.canRevealMistakes && _isAnimating) {
      _stopAnimations();
    }
  }

  void _startAnimations() {
    if (!mounted) return;
    
    setState(() {
      _isAnimating = true;
    });
    
    // Shake animasyonunu başlat (tek sefer)
    _shakeController.forward();
    
    // Halo animasyonunu başlat (tekrarlı) - otomatik kaybolma yok
    _haloController.repeat(reverse: true);
  }

  void _stopAnimations() {
    if (!mounted) return;
    
    _haloController.stop();
    _shakeController.stop();
    
    setState(() {
      _isAnimating = false;
    });
  }

  @override
  void dispose() {
    _haloController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Eğer hata değilse veya canRevealMistakes false ise normal widget'ı göster
    if (!widget.isError || !widget.canRevealMistakes) {
      return GestureDetector(
        onTap: widget.onTap,
        child: widget.child,
      );
    }

    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: Listenable.merge([_haloController, _shakeController]),
        builder: (context, child) {
          // Shake offset hesapla
          final shakeOffset = _shakeAnimation.value * 1.5 * math.sin(_shakeAnimation.value * math.pi);
          
          return Container(
            margin: EdgeInsets.only(left: shakeOffset),
            child: Stack(
              children: [
                // Ana hücre - her zaman tıklanabilir
                Positioned.fill(
                  child: GestureDetector(
                    onTap: widget.onTap,
                    behavior: HitTestBehavior.opaque, // Tıklama alanını genişlet
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFFF3B30), // Kırmızı border
                          width: 3.0,
                        ),
                        color: const Color(0xFFFF3B30).withOpacity(0.15), // Kırmızı overlay
                      ),
                      child: widget.child,
                    ),
                  ),
                ),
                
                // Halo efekti (yanıp sönen dış çember) - tıklanamaz
                if (_isAnimating)
                  Positioned(
                    left: -4,
                    top: -4,
                    right: -4,
                    bottom: -4,
                    child: IgnorePointer( // Tıklamaları engelle
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10), // Biraz daha büyük radius
                          border: Border.all(
                            color: const Color(0xFFFF3B30).withOpacity(_haloAnimation.value),
                            width: 2.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF3B30).withOpacity(_haloAnimation.value * 0.5),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
