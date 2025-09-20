import 'package:equatable/equatable.dart';

// States
abstract class PuzzleState extends Equatable {
  const PuzzleState();

  @override
  List<Object?> get props => [];
}

class PuzzleInitial extends PuzzleState {}

class PuzzleLoading extends PuzzleState {}

class PuzzleLoaded extends PuzzleState {
  final int stage;
  final int level;
  final int gridSize;
  final List<List<int>> gridState;
  final List<List<int>> solution;
  final List<List<String?>> horizontalSymbols;
  final List<List<String?>> verticalSymbols;
  final List<List<int>> prefilled;
  final List<List<List<int>>> moveHistory;
  final int currentHistoryIndex;
  final bool isSolved;
  final List<String> errors;
  final int elapsedSeconds;
  final bool isTimerRunning;
  // Hata tespit sistemi için yeni alanlar
  final List<List<int>> errorCells; // Hatalı hücrelerin koordinatları
  final bool isChecking; // Check işlemi devam ediyor mu
  final String checkMessage; // Check sonucu mesajı
  final DateTime? checkTimestamp; // Check zamanı (animasyon için)
  final bool canRevealMistakes; // Reklam izlendikten sonra hataları gösterebilir mi

  const PuzzleLoaded({
    required this.stage,
    required this.level,
    required this.gridSize,
    required this.gridState,
    required this.solution,
    required this.horizontalSymbols,
    required this.verticalSymbols,
    required this.prefilled,
    required this.moveHistory,
    required this.currentHistoryIndex,
    required this.isSolved,
    required this.errors,
    required this.elapsedSeconds,
    required this.isTimerRunning,
    this.errorCells = const [],
    this.isChecking = false,
    this.checkMessage = '',
    this.checkTimestamp,
    this.canRevealMistakes = false,
  });

  PuzzleLoaded copyWith({
    int? stage,
    int? level,
    int? gridSize,
    List<List<int>>? gridState,
    List<List<int>>? solution,
    List<List<String?>>? horizontalSymbols,
    List<List<String?>>? verticalSymbols,
    List<List<int>>? prefilled,
    List<List<List<int>>>? moveHistory,
    int? currentHistoryIndex,
    bool? isSolved,
    List<String>? errors,
    int? elapsedSeconds,
    bool? isTimerRunning,
    List<List<int>>? errorCells,
    bool? isChecking,
    String? checkMessage,
    DateTime? checkTimestamp,
    bool? canRevealMistakes,
  }) {
    return PuzzleLoaded(
      stage: stage ?? this.stage,
      level: level ?? this.level,
      gridSize: gridSize ?? this.gridSize,
      gridState: gridState ?? this.gridState,
      solution: solution ?? this.solution,
      horizontalSymbols: horizontalSymbols ?? this.horizontalSymbols,
      verticalSymbols: verticalSymbols ?? this.verticalSymbols,
      prefilled: prefilled ?? this.prefilled,
      moveHistory: moveHistory ?? this.moveHistory,
      currentHistoryIndex: currentHistoryIndex ?? this.currentHistoryIndex,
      isSolved: isSolved ?? this.isSolved,
      errors: errors ?? this.errors,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      errorCells: errorCells ?? this.errorCells,
      isChecking: isChecking ?? this.isChecking,
      checkMessage: checkMessage ?? this.checkMessage,
      checkTimestamp: checkTimestamp ?? this.checkTimestamp,
      canRevealMistakes: canRevealMistakes ?? this.canRevealMistakes,
    );
  }

  @override
  List<Object?> get props => [
    stage, level, gridSize, gridState, solution, horizontalSymbols, 
    verticalSymbols, prefilled, moveHistory, currentHistoryIndex, 
    isSolved, errors, elapsedSeconds, isTimerRunning, errorCells,
    isChecking, checkMessage, checkTimestamp, canRevealMistakes
  ];
}

class PuzzleError extends PuzzleState {
  final String message;

  const PuzzleError(this.message);

  @override
  List<Object?> get props => [message];
} 