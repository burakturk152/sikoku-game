import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../routes/app_router.dart';
import '../services/level_progress_service.dart';

class StageButton extends StatefulWidget {
  final int level;
  final int stage;
  const StageButton({super.key, required this.level, this.stage = 1});

  @override
  State<StageButton> createState() => _StageButtonState();
}

class _StageButtonState extends State<StageButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isUnlocked = false;
  int _starCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _loadLevelData();
  }

  Future<void> _loadLevelData() async {
    final isUnlocked = await LevelProgressService.isLevelUnlocked(widget.level);
    final starCount = await LevelProgressService.getStars(widget.level);
    
    print('DEBUG StageButton: Level ${widget.level}, Unlocked: $isUnlocked, Stars: $starCount');
    
    if (mounted) {
      setState(() {
        _isUnlocked = isUnlocked;
        _starCount = starCount;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() async {
    if (!_isUnlocked) {
      await _animationController.forward();
      await _animationController.reverse();
      return;
    }

    await _animationController.forward();
    await _animationController.reverse();
    
    print('Stage ${widget.level} tapped');
    if (mounted) {
      context.router.push(GameRoute(stage: widget.stage, level: widget.level));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: _isUnlocked ? _onTap : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final screenHeight = MediaQuery.of(context).size.height;
                final buttonSize = (screenWidth + screenHeight) * 0.02;
                final fontSize = buttonSize * 0.4;
                final borderWidth = buttonSize * 0.05;
                
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Ana buton
                    Stack(
                      children: [
                        Container(
                          width: buttonSize,
                          height: buttonSize,
                          decoration: BoxDecoration(
                            color: _isUnlocked ? Colors.blueAccent : Colors.grey.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _isUnlocked ? Colors.white : Colors.grey.shade400,
                              width: borderWidth,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (_isUnlocked ? Colors.blueAccent : Colors.grey).withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${widget.level}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
                            ),
                          ),
                        ),
                        // Kilit ikonu (sadece kilitli level'lar için)
                        if (!_isUnlocked)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Icon(
                              Icons.lock_outline,
                              color: Colors.grey,
                              size: fontSize * 0.6,
                            ),
                          ),
                      ],
                    ),
                    
                    // Yıldız göstergesi
                    if (_starCount > 0) ...[
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_starCount, (index) => 
                          Icon(Icons.star, color: Colors.yellow, size: 16)
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
} 