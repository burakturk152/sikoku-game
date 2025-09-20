import 'package:equatable/equatable.dart';

// Events
abstract class PuzzleEvent extends Equatable {
  const PuzzleEvent();

  @override
  List<Object?> get props => [];
}

class PuzzleCellTapped extends PuzzleEvent {
  final int row;
  final int col;

  const PuzzleCellTapped(this.row, this.col);

  @override
  List<Object?> get props => [row, col];
}

class PuzzleUndo extends PuzzleEvent {}

class PuzzleRedo extends PuzzleEvent {}

class PuzzleHint extends PuzzleEvent {}

class PuzzleReset extends PuzzleEvent {}

class PuzzleCheck extends PuzzleEvent {}

class PuzzleClearErrors extends PuzzleEvent {}

class PuzzleCheckMistakes extends PuzzleEvent {}

class PuzzleRevealMistakes extends PuzzleEvent {}

class PuzzleStopRevealMistakes extends PuzzleEvent {}

class PuzzleLoad extends PuzzleEvent {
  final int stage;
  final int level;
  final List<List<int>> solution;
  final List<List<String?>> horizontalSymbols;
  final List<List<String?>> verticalSymbols;
  final List<List<int>> prefilled;
  final int gridSize;

  const PuzzleLoad({
    required this.stage,
    required this.level,
    required this.solution,
    required this.horizontalSymbols,
    required this.verticalSymbols,
    required this.prefilled,
    required this.gridSize,
  });

  @override
  List<Object?> get props => [stage, level, solution, horizontalSymbols, verticalSymbols, prefilled, gridSize];
} 