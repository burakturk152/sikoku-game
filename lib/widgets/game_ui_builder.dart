import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_events.dart';
import '../bloc/puzzle_states.dart';
import '../models/puzzle_data.dart';
import '../services/game_timer_service.dart';
import 'grid_widget.dart';
import 'sound_control.dart';
import 'game_timer_widget.dart';
import 'game_control_buttons.dart';
import 'check_dialog_widget.dart';
import '../theme/app_themes.dart';
import '../theme/cell_icons.dart';
import '../l10n/app_localizations.dart';
import 'dart:math' as math;

class GameUIBuilder extends StatefulWidget {
  final PuzzleLoaded state;
  final double screenWidth;
  final double screenHeight;
  final List<List<int>>? currentHints;
  final TransformationController transformationController;
  final GameTimerService timerService;
  final int actualLevel; // Gerçek level numarası
  final CellIconSet iconSet; // Yeni parametre
  final bool isDailyMode; // Günlük mod kontrolü
  final bool isWeeklyMode; // Haftalık mod kontrolü

  const GameUIBuilder({
    Key? key,
    required this.state,
    required this.screenWidth,
    required this.screenHeight,
    required this.currentHints,
    required this.transformationController,
    required this.timerService,
    required this.actualLevel,
    required this.iconSet, // Yeni parametre
    this.isDailyMode = false, // Varsayılan false
    this.isWeeklyMode = false, // Varsayılan false
  }) : super(key: key);

  @override
  State<GameUIBuilder> createState() => _GameUIBuilderState();
}

class _GameUIBuilderState extends State<GameUIBuilder> {
  String _getGameTitle() {
    // Günlük bulmaca kontrolü
    if (widget.isDailyMode) {
      return AppLocalizations.of(context)!.dailyPuzzle;
    }
    
    // Haftalık bulmaca kontrolü
    if (widget.isWeeklyMode) {
      return AppLocalizations.of(context)!.weeklyPuzzle;
    }
    
    // Normal evren level'ları - sezon ve bölüm formatı
    return 'Sezon ${widget.state.stage} - Bölüm ${widget.actualLevel}';
  }

  @override
  Widget build(BuildContext context) {
    final pal = Theme.of(context).extension<AppPalette>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: pal.puzzleBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: pal.counterTextColor),
          onPressed: () => context.router.pop(),
        ),
        title: Text(
          _getGameTitle(),
          style: TextStyle(color: pal.counterTextColor),
        ),
        centerTitle: true,
        actions: [
          GameTimerWidget(
            timerService: widget.timerService,
            screenWidth: widget.screenWidth,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // GridWidget doğrudan kullanılıyor
                  GridWidget(
                    state: widget.state,
                    screenWidth: widget.screenWidth,
                    screenHeight: widget.screenHeight,
                    gridArea: widget.screenWidth * 0.8,
                    gap: (widget.screenWidth * 0.8) / widget.state.gridSize * 0.05, // Responsive gap
                    cellSize: (widget.screenWidth * 0.8 - ((widget.screenWidth * 0.8) / widget.state.gridSize * 0.05) * (widget.state.gridSize - 1)) / widget.state.gridSize,
                    cellCount: widget.state.gridSize,
                    fontSize: (widget.screenWidth * 0.8 - ((widget.screenWidth * 0.8) / widget.state.gridSize * 0.05) * (widget.state.gridSize - 1)) / widget.state.gridSize * 0.35,
                    currentHints: widget.currentHints,
                    transformationController: widget.transformationController,
                    stage: widget.state.stage,
                    iconSet: widget.iconSet, // Yeni parametre
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Game control buttons
                  GameControlButtons(
                    screenWidth: widget.screenWidth,
                    screenHeight: widget.screenHeight,
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom navigation bar
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox.shrink(), // Sol boşluk
                Text(
                  '${widget.state.gridSize}x${widget.state.gridSize} Grid',
                  style: TextStyle(
                    color: pal.counterTextColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SoundControl(),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 