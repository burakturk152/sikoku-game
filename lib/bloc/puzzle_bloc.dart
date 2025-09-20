import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'puzzle_events.dart';
import 'puzzle_states.dart';
import '../utils/puzzle_validation_utils.dart';
import '../audio/audio_gateway.dart';



// Bloc
class PuzzleBloc extends Bloc<PuzzleEvent, PuzzleState> {
  PuzzleBloc() : super(PuzzleInitial()) {
    on<PuzzleLoad>(_onPuzzleLoad);
    on<PuzzleCellTapped>(_onCellTapped);
    on<PuzzleUndo>(_onUndo);
    on<PuzzleRedo>(_onRedo);
    on<PuzzleHint>(_onHint);
    on<PuzzleReset>(_onReset);
    on<PuzzleCheck>(_onCheck);
    on<PuzzleClearErrors>(_onClearErrors);
    on<PuzzleCheckMistakes>(_onCheckMistakes);
    on<PuzzleRevealMistakes>(_onRevealMistakes);
    on<PuzzleStopRevealMistakes>(_onStopRevealMistakes);
  }

  void _onPuzzleLoad(PuzzleLoad event, Emitter<PuzzleState> emit) {
    emit(PuzzleLoading());
    
    // Grid durumunu başlat
    List<List<int>> initialGrid = List.generate(
      event.gridSize, 
      (i) => List.generate(event.gridSize, (j) => 0)
    );
    
    // Pre-filled hücreleri doldur
    for (List<int> position in event.prefilled) {
      int row = position[0];
      int col = position[1];
      initialGrid[row][col] = event.solution[row][col];
    }
    
    // İlk durumu geçmişe ekle
    List<List<List<int>>> moveHistory = [
      List.generate(event.gridSize, (i) => 
        List.generate(event.gridSize, (j) => initialGrid[i][j]))
    ];
    
    emit(PuzzleLoaded(
      stage: event.stage,
      level: event.level,
      gridSize: event.gridSize,
      gridState: initialGrid,
      solution: event.solution,
      horizontalSymbols: event.horizontalSymbols,
      verticalSymbols: event.verticalSymbols,
      prefilled: event.prefilled,
      moveHistory: moveHistory,
      currentHistoryIndex: 0,
      isSolved: false,
      errors: [],
      elapsedSeconds: 0,
      isTimerRunning: false,
      errorCells: [],
      isChecking: false,
      checkMessage: '',
      checkTimestamp: null,
    ));
  }

  void _onCellTapped(PuzzleCellTapped event, Emitter<PuzzleState> emit) {
    if (state is PuzzleLoaded) {
      final currentState = state as PuzzleLoaded;
      
      // Pre-filled cell kontrolü
      bool isPrefilled = currentState.prefilled.any(
        (position) => position[0] == event.row && position[1] == event.col
      );
      
      if (isPrefilled) {
        emit(PuzzleError('Bu hücre sabit! Değiştirilemez.'));
        return;
      }
      
      // Grid durumunu güncelle
      List<List<int>> newGridState = List.generate(
        currentState.gridSize,
        (i) => List.generate(currentState.gridSize, (j) => currentState.gridState[i][j])
      );
      
      // Hücre rengini değiştir (0 -> 1 -> 2 -> 0)
      newGridState[event.row][event.col] = (newGridState[event.row][event.col] + 1) % 3;
      
      // Hücre tıklama ses efekti çal
      AudioGateway().playCellClickSound();
      
      // Geçmişe kaydet
      List<List<List<int>>> newHistory = List.from(currentState.moveHistory);
      newHistory.add(List.generate(
        currentState.gridSize,
        (i) => List.generate(currentState.gridSize, (j) => newGridState[i][j])
      ));
      
      // Çözüm kontrolü
      bool isSolved = PuzzleValidationUtils.isPuzzleSolved(newGridState, currentState.solution);
      
      // Hata kontrolü
      List<String> errors = PuzzleValidationUtils.validateGrid(newGridState, currentState);
      
      // Tıklanan hücreyi hata listesinden çıkar (eğer varsa)
      List<List<int>> updatedErrorCells = List.from(currentState.errorCells);
      updatedErrorCells.removeWhere((cell) => cell[0] == event.row && cell[1] == event.col);
      
      emit(currentState.copyWith(
        gridState: newGridState,
        moveHistory: newHistory,
        currentHistoryIndex: newHistory.length - 1,
        isSolved: isSolved,
        errors: errors,
        errorCells: updatedErrorCells, // Tıklanan hücreyi hata listesinden çıkar
      ));
    }
  }

  void _onUndo(PuzzleUndo event, Emitter<PuzzleState> emit) {
    if (state is PuzzleLoaded) {
      final currentState = state as PuzzleLoaded;
      
      if (currentState.currentHistoryIndex > 0) {
        int newIndex = currentState.currentHistoryIndex - 1;
        List<List<int>> previousGrid = List.generate(
          currentState.gridSize,
          (i) => List.generate(currentState.gridSize, (j) => currentState.moveHistory[newIndex][i][j])
        );
        
        // Pre-filled hücreleri koru
        for (int row = 0; row < currentState.gridSize; row++) {
          for (int col = 0; col < currentState.gridSize; col++) {
            bool isPrefilled = currentState.prefilled.any(
              (position) => position[0] == row && position[1] == col
            );
            if (isPrefilled) {
              previousGrid[row][col] = currentState.solution[row][col];
            }
          }
        }
        
        bool isSolved = PuzzleValidationUtils.isPuzzleSolved(previousGrid, currentState.solution);
        List<String> errors = PuzzleValidationUtils.validateGrid(previousGrid, currentState);
        
        emit(currentState.copyWith(
          gridState: previousGrid,
          currentHistoryIndex: newIndex,
          isSolved: isSolved,
          errors: errors,
          errorCells: [], // Hata hücrelerini temizle
          isChecking: false,
          checkMessage: '',
          checkTimestamp: null,
        ));
      }
    }
  }

  void _onRedo(PuzzleRedo event, Emitter<PuzzleState> emit) {
    if (state is PuzzleLoaded) {
      final currentState = state as PuzzleLoaded;
      
      if (currentState.currentHistoryIndex < currentState.moveHistory.length - 1) {
        int newIndex = currentState.currentHistoryIndex + 1;
        List<List<int>> nextGrid = List.generate(
          currentState.gridSize,
          (i) => List.generate(currentState.gridSize, (j) => currentState.moveHistory[newIndex][i][j])
        );
        
        // Pre-filled hücreleri koru
        for (int row = 0; row < currentState.gridSize; row++) {
          for (int col = 0; col < currentState.gridSize; col++) {
            bool isPrefilled = currentState.prefilled.any(
              (position) => position[0] == row && position[1] == col
            );
            if (isPrefilled) {
              nextGrid[row][col] = currentState.solution[row][col];
            }
          }
        }
        
        bool isSolved = PuzzleValidationUtils.isPuzzleSolved(nextGrid, currentState.solution);
        List<String> errors = PuzzleValidationUtils.validateGrid(nextGrid, currentState);
        
        emit(currentState.copyWith(
          gridState: nextGrid,
          currentHistoryIndex: newIndex,
          isSolved: isSolved,
          errors: errors,
          errorCells: [], // Hata hücrelerini temizle
          isChecking: false,
          checkMessage: '',
          checkTimestamp: null,
        ));
      }
    }
  }

  void _onHint(PuzzleHint event, Emitter<PuzzleState> emit) {
    if (state is PuzzleLoaded) {
      final currentState = state as PuzzleLoaded;
      
      // Boş hücreleri bul
      List<List<int>> emptyCells = [];
      for (int row = 0; row < currentState.gridSize; row++) {
        for (int col = 0; col < currentState.gridSize; col++) {
          if (currentState.gridState[row][col] == 0) {
            emptyCells.add([row, col]);
          }
        }
      }
      
      if (emptyCells.isNotEmpty) {
        Random random = Random();
        var randomCell = emptyCells[random.nextInt(emptyCells.length)];
        int row = randomCell[0];
        int col = randomCell[1];
        
        // Doğru rengi al
        int correctColor = currentState.solution[row][col];
        
        // Grid durumunu güncelle
        List<List<int>> newGridState = List.generate(
          currentState.gridSize,
          (i) => List.generate(currentState.gridSize, (j) => currentState.gridState[i][j])
        );
        newGridState[row][col] = correctColor;
        
        // Geçmişe kaydet
        List<List<List<int>>> newHistory = List.from(currentState.moveHistory);
        newHistory.add(List.generate(
          currentState.gridSize,
          (i) => List.generate(currentState.gridSize, (j) => newGridState[i][j])
        ));
        
        bool isSolved = PuzzleValidationUtils.isPuzzleSolved(newGridState, currentState.solution);
        List<String> errors = PuzzleValidationUtils.validateGrid(newGridState, currentState);
        
        emit(currentState.copyWith(
          gridState: newGridState,
          moveHistory: newHistory,
          currentHistoryIndex: newHistory.length - 1,
          isSolved: isSolved,
          errors: errors,
          errorCells: [], // Hata hücrelerini temizle
          isChecking: false,
          checkMessage: '',
          checkTimestamp: null,
        ));
      }
    }
  }

  void _onReset(PuzzleReset event, Emitter<PuzzleState> emit) {
    if (state is PuzzleLoaded) {
      final currentState = state as PuzzleLoaded;
      
      // Mevcut grid'i kopyala
      List<List<int>> resetGrid = List.generate(
        currentState.gridSize,
        (i) => List.generate(currentState.gridSize, (j) => currentState.gridState[i][j])
      );
      
      // Sadece kullanıcının doldurduğu hücreleri sıfırla (pre-filled olmayan)
      for (int row = 0; row < currentState.gridSize; row++) {
        for (int col = 0; col < currentState.gridSize; col++) {
          bool isPrefilled = currentState.prefilled.any(
            (position) => position[0] == row && position[1] == col
          );
          if (!isPrefilled) {
            resetGrid[row][col] = 0; // Sadece kullanıcının doldurduğu hücreleri sıfırla
          }
        }
      }
      
      // Geçmişe kaydet
      List<List<List<int>>> newHistory = List.from(currentState.moveHistory);
      newHistory.add(List.generate(
        currentState.gridSize,
        (i) => List.generate(currentState.gridSize, (j) => resetGrid[i][j])
      ));
      
      // Çözüm kontrolü
      bool isSolved = PuzzleValidationUtils.isPuzzleSolved(resetGrid, currentState.solution);
      List<String> errors = PuzzleValidationUtils.validateGrid(resetGrid, currentState);
      
      emit(currentState.copyWith(
        gridState: resetGrid,
        moveHistory: newHistory,
        currentHistoryIndex: newHistory.length - 1,
        isSolved: isSolved,
        errors: errors,
        errorCells: [], // Hata hücrelerini temizle
        isChecking: false,
        checkMessage: '',
        checkTimestamp: null,
      ));
    }
  }

  void _onCheck(PuzzleCheck event, Emitter<PuzzleState> emit) async {
    if (state is PuzzleLoaded) {
      final currentState = state as PuzzleLoaded;
      
      // Hata tespit sistemi
      List<List<int>> errorCells = [];
      int errorCount = 0;
      
      // Grid'i karşılaştır ve hatalı hücreleri bul
      for (int row = 0; row < currentState.gridSize; row++) {
        for (int col = 0; col < currentState.gridSize; col++) {
          // Boş hücreleri atla (henüz doldurulmamış)
          if (currentState.gridState[row][col] == 0) continue;
          
          // Çözümle karşılaştır
          if (currentState.gridState[row][col] != currentState.solution[row][col]) {
            errorCells.add([row, col]);
            errorCount++;
          }
        }
      }
      
      // Check mesajını oluştur
      String checkMessage;
      if (errorCount == 0) {
        checkMessage = 'Congratulations! All cells are correct.';
      } else {
        checkMessage = 'Errors found in $errorCount cells.';
      }
      
      // State'i güncelle - artık otomatik kaybolma yok
      emit(currentState.copyWith(
        errorCells: errorCells,
        isChecking: true,
        checkMessage: checkMessage,
        checkTimestamp: DateTime.now(),
      ));
    }
  }

  void _onClearErrors(PuzzleClearErrors event, Emitter<PuzzleState> emit) {
    if (state is PuzzleLoaded) {
      final currentState = state as PuzzleLoaded;
      emit(currentState.copyWith(
        errorCells: [],
        isChecking: false,
        checkMessage: '',
        checkTimestamp: null,
      ));
    }
  }

  // Yeni event handler'lar - sadece hata sayısını hesaplar, hücreleri vurgulamaz
  void _onCheckMistakes(PuzzleCheckMistakes event, Emitter<PuzzleState> emit) {
    if (state is PuzzleLoaded) {
      final currentState = state as PuzzleLoaded;
      
      // Bu işlem hiçbir şey yapmaz, sadece placeholder
      // Hata sayısı hesaplama logic'i dialog widget'ında olacak
    }
  }

  // Reklam izlendikten sonra hataları göster
  void _onRevealMistakes(PuzzleRevealMistakes event, Emitter<PuzzleState> emit) {
    if (state is PuzzleLoaded) {
      final currentState = state as PuzzleLoaded;
      
      // Hata tespit sistemi
      List<List<int>> errorCells = [];
      
      // Grid'i karşılaştır ve hatalı hücreleri bul
      for (int row = 0; row < currentState.gridSize; row++) {
        for (int col = 0; col < currentState.gridSize; col++) {
          // Boş hücreleri atla (henüz doldurulmamış)
          if (currentState.gridState[row][col] == 0) continue;
          
          // Çözümle karşılaştır
          if (currentState.gridState[row][col] != currentState.solution[row][col]) {
            errorCells.add([row, col]);
          }
        }
      }
      
      // State'i güncelle - hataları göster ve canRevealMistakes'ı true yap
      // Artık otomatik kaybolma yok, sadece manuel olarak durdurulabilir
      emit(currentState.copyWith(
        errorCells: errorCells,
        canRevealMistakes: true,
        isChecking: true,
        checkTimestamp: DateTime.now(),
      ));
    }
  }

  // Animasyonu manuel olarak durdur
  void _onStopRevealMistakes(PuzzleStopRevealMistakes event, Emitter<PuzzleState> emit) {
    if (state is PuzzleLoaded) {
      final currentState = state as PuzzleLoaded;
      emit(currentState.copyWith(
        canRevealMistakes: false,
        isChecking: false,
        checkTimestamp: null,
      ));
    }
  }

  // Hata sayısını hesaplayan utility fonksiyon
  static int calculateMistakeCount(PuzzleLoaded state) {
    int mistakeCount = 0;
    
    // Grid'i karşılaştır ve hatalı hücreleri say
    for (int row = 0; row < state.gridSize; row++) {
      for (int col = 0; col < state.gridSize; col++) {
        // Boş hücreleri atla (henüz doldurulmamış)
        if (state.gridState[row][col] == 0) continue;
        
        // Çözümle karşılaştır
        if (state.gridState[row][col] != state.solution[row][col]) {
          mistakeCount++;
        }
      }
    }
    
    return mistakeCount;
  }


}