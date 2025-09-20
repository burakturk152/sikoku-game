import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'package:auto_route/auto_route.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/puzzle_service.dart';
import '../services/puzzle_loader_service.dart';
import '../models/puzzle_data.dart';
import '../services/user_progress_service.dart';
import '../services/progress_service.dart';
import '../widgets/star_indicator.dart';
import '../widgets/sound_control.dart';
import '../widgets/painters.dart';
import '../widgets/counters.dart';
import '../widgets/grid_widget.dart';
import '../widgets/game_timer_widget.dart';
import '../widgets/success_dialog_widget.dart';
import '../widgets/game_loading_widget.dart';
import '../widgets/game_ui_builder.dart';
import '../widgets/game_error_handler.dart';
import '../services/game_timer_service.dart';
import '../services/puzzle_loading_service.dart';
import '../services/daily_puzzle_selection.dart';
import '../services/weekly_puzzle_selection.dart';
import '../utils/puzzle_debug_utils.dart';
import '../routes/app_router.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_states.dart';
import '../bloc/puzzle_events.dart';
import '../theme/app_themes.dart';
import '../theme/cell_icons.dart';

@RoutePage()
class GameScreen extends StatefulWidget {
  final int stage;
  final int level;
  final DateTime? dailyDate; // Günlük mod için opsiyonel tarih
  final DateTime? weeklyMonday; // Haftalık mod için opsiyonel pazartesi
  
  const GameScreen({Key? key, required this.stage, required this.level, this.dailyDate, this.weeklyMonday}) : super(key: key);

  UniverseKind get universe =>
      (stage == 2) ? UniverseKind.forest : UniverseKind.space;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  bool isLoading = true;
  int maxTimeSeconds = 60;
  List<List<int>>? currentHints;
  bool isPuzzleCompleted = false;
  bool _isDailyMode = false;
  bool _isWeeklyMode = false;
  final TransformationController _transformationController = TransformationController();
  late GameTimerService _timerService;

  @override
  void initState() {
    super.initState();
    _timerService = GameTimerService(
      onTimeUpdate: (seconds) {
        if (mounted) {
          setState(() {});
        }
      },
    );
    _precacheImages();
  }

  // İkonları önceden yükle (performans için)
  void _precacheImages() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        precacheImage(const AssetImage('assets/images/earth.png'), context);
        precacheImage(const AssetImage('assets/images/sunny.png'), context);
        precacheImage(const AssetImage('assets/images/blueberry.png'), context);
        precacheImage(const AssetImage('assets/images/banana.png'), context);
      }
    });
  }

  @override
  void dispose() {
    _timerService.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timerService.startTimer();
  }

  void _stopTimer() {
    _timerService.stopTimer();
  }

  Future<void> _loadPuzzle(BuildContext context) async {
    final selectedDaily = widget.dailyDate ?? DailyPuzzleSelection.consume();
    final selectedWeekly = widget.weeklyMonday ?? WeeklyPuzzleSelection.consume();
    if (selectedDaily != null) _isDailyMode = true;
    if (selectedWeekly != null) _isWeeklyMode = true;
    await PuzzleLoadingService.loadPuzzle(
      context: context,
      level: widget.level,
      stage: widget.stage,
      setLoading: (loading) => setState(() => isLoading = loading),
      setHints: (hints) => currentHints = hints,
      setMaxTime: (time) => maxTimeSeconds = time,
      startTimer: _startTimer,
      printSolution: _printSolution,
      dailyDate: selectedDaily,
      weeklyMonday: selectedWeekly,
    );
  }

  void _printSolution(PuzzleData puzzle) {
    PuzzleDebugUtils.printSolution(puzzle);
  }

  void _showSuccessDialog() async {
    _stopTimer();
    
    SuccessDialogWidget.show(
      context: context,
      level: widget.level,
      elapsedSeconds: _timerService.currentTime,
      stage: widget.stage,
      isDaily: _isDailyMode,
      isWeekly: _isWeeklyMode,
      onBackToMenu: () => context.router.pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pal = Theme.of(context).extension<AppPalette>()!;

    
    return BlocProvider(
      create: (context) => PuzzleBloc(),
      child: Builder(
        builder: (context) => BlocListener<PuzzleBloc, PuzzleState>(
          listener: (context, state) {
            if (state is PuzzleError) {
              GameErrorHandler.handlePuzzleError(context, state);
            } else if (state is PuzzleLoaded && state.isSolved) {
              GameErrorHandler.handlePuzzleSolved(
                context: context,
                timerService: _timerService,
                stopTimer: _stopTimer,
                setPuzzleCompleted: () => setState(() => isPuzzleCompleted = true),
                showSuccessDialog: _showSuccessDialog,
                isDaily: _isDailyMode,
              );
            }
          },
          child: BlocBuilder<PuzzleBloc, PuzzleState>(
            builder: (context, state) {
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              
              if (isLoading || state is PuzzleLoading) {
                if (isLoading) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _loadPuzzle(context);
                  });
                }
                
                return GameLoadingWidget(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                );
              }
              
              if (state is PuzzleLoaded) {
                // Timer'ı başlat (eğer henüz başlamamışsa)
                if (!_timerService.isRunning && !isPuzzleCompleted) {
                  _startTimer();
                }
                
                return GameUIBuilder(
                  state: state,
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  currentHints: currentHints,
                  transformationController: _transformationController,
                  timerService: _timerService,
                  actualLevel: widget.level,
                  iconSet: iconsForUniverse(widget.universe), // Yeni parametre
                  isDailyMode: _isDailyMode, // Günlük mod bilgisi
                  isWeeklyMode: _isWeeklyMode, // Haftalık mod bilgisi
                );
              }
              
              return Scaffold(
                backgroundColor: pal.puzzleBackground,
                body: Center(
                  child: Text(
                    'Bir hata oluştu',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
} 