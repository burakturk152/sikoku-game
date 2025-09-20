class PuzzleData {
  final int stage;
  final int level;
  final int gridSize; // Grid boyutu eklendi
  final List<List<int>> solution;
  final Map<String, List<List<String?>>> symbols;
  final int difficulty;
  final List<List<int>> prefilled;
  final String? hint;
  final List<String>? hints;
  final List<List<int>>? hintData; // Yeni alan: List<List<int>> formatında hint'ler
  final int? maxTimeSeconds;

  PuzzleData({
    required this.stage,
    required this.level,
    required this.gridSize, // Grid boyutu eklendi
    required this.solution,
    required this.symbols,
    required this.difficulty,
    required this.prefilled,
    this.hint,
    this.hints,
    this.hintData, // Yeni alan
    this.maxTimeSeconds,
  });

  String get id => '${stage}_$level';

  factory PuzzleData.fromJson(Map<String, dynamic> json) {
    // Grid boyutunu al (varsayılan 6)
    int gridSize = json['grid_size'] ?? 6;
    
    // Solution'ı düzgün parse et
    List<List<int>> solution = [];
    for (var row in json['solution']) {
      List<int> intRow = [];
      for (var cell in row) {
        intRow.add(cell as int);
      }
      solution.add(intRow);
    }

    // Symbols'ı düzgün parse et
    Map<String, List<List<String?>>> symbols = {};
    List<List<String?>> horizontalSymbols = [];
    for (var row in json['symbols']['horizontal']) {
      List<String?> stringRow = [];
      for (var cell in row) {
        stringRow.add(cell as String?);
      }
      horizontalSymbols.add(stringRow);
    }
    
    List<List<String?>> verticalSymbols = [];
    for (var row in json['symbols']['vertical']) {
      List<String?> stringRow = [];
      for (var cell in row) {
        stringRow.add(cell as String?);
      }
      verticalSymbols.add(stringRow);
    }
    
    symbols['horizontal'] = horizontalSymbols;
    symbols['vertical'] = verticalSymbols;

    // Prefilled'ı düzgün parse et
    List<List<int>> prefilled = [];
    for (var position in json['prefilled']) {
      List<int> intPosition = [];
      for (var coord in position) {
        intPosition.add(coord as int);
      }
      prefilled.add(intPosition);
    }

    // Hints'leri parse et
    List<String>? hints;
    if (json['hints'] != null) {
      hints = List<String>.from(json['hints']);
    }
    
    // HintData'yı parse et (yeni)
    List<List<int>>? hintData;
    if (json['hintData'] != null) {
      hintData = (json['hintData'] as List<dynamic>)
          .map((e) => (e as List<dynamic>).cast<int>())
          .toList();
    }

    return PuzzleData(
      stage: json['stage'],
      level: json['level'],
      gridSize: gridSize, // Grid boyutu eklendi
      solution: solution,
      symbols: symbols,
      difficulty: json['difficulty'],
      prefilled: prefilled,
      hint: json['hint'],
      hints: hints,
      hintData: hintData, // Yeni alan
      maxTimeSeconds: json['max_time_seconds'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage,
      'level': level,
      'grid_size': gridSize, // Grid boyutu eklendi
      'solution': solution,
      'symbols': symbols,
      'difficulty': difficulty,
      'prefilled': prefilled,
      'hint': hint,
      'hints': hints,
      'hintData': hintData, // List<List<int>> formatında
      'max_time_seconds': maxTimeSeconds,
    };
  }
}

// Yeni JSON formatı için PuzzleModel sınıfı
class PuzzleModel {
  final int level;
  final String difficulty;
  final int size;
  final List<List<PuzzleCell>> puzzle;
  final List<List<String>> solution;
  final List<PuzzleHintData> hints;
  final String theme;

  PuzzleModel({
    required this.level,
    required this.difficulty,
    required this.size,
    required this.puzzle,
    required this.solution,
    required this.hints,
    required this.theme,
  });

  factory PuzzleModel.fromJson(Map<String, dynamic> json) {
    // Puzzle grid'ini parse et
    List<List<PuzzleCell>> puzzle = [];
    for (var row in json['puzzle']) {
      List<PuzzleCell> puzzleRow = [];
      for (var cell in row) {
        puzzleRow.add(PuzzleCell.fromJson(cell));
      }
      puzzle.add(puzzleRow);
    }

    // Solution'ı parse et
    List<List<String>> solution = [];
    for (var row in json['solution']) {
      List<String> solutionRow = [];
      for (var cell in row) {
        solutionRow.add(cell as String);
      }
      solution.add(solutionRow);
    }

    // Hints'leri parse et
    List<PuzzleHintData> hints = [];
    for (var hint in json['hints']) {
      hints.add(PuzzleHintData.fromJson(hint));
    }

    return PuzzleModel(
      level: json['level'],
      difficulty: json['difficulty'],
      size: json['size'],
      puzzle: puzzle,
      solution: solution,
      hints: hints,
      theme: json['theme'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'difficulty': difficulty,
      'size': size,
      'puzzle': puzzle.map((row) => row.map((cell) => cell.toJson()).toList()).toList(),
      'solution': solution,
      'hints': hints.map((hint) => hint.toJson()).toList(),
      'theme': theme,
    };
  }
}

// Puzzle hücresi sınıfı
class PuzzleCell {
  final String value;
  final bool locked;

  PuzzleCell({
    required this.value,
    required this.locked,
  });

  factory PuzzleCell.fromJson(Map<String, dynamic> json) {
    return PuzzleCell(
      value: json['value'] ?? '',
      locked: json['locked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'locked': locked,
    };
  }
}

// Puzzle ipucu sınıfı (PuzzleHint ile çakışmayı önlemek için PuzzleHintData olarak adlandırıldı)
class PuzzleHintData {
  final String type;
  final List<int> cell1;
  final List<int> cell2;

  PuzzleHintData({
    required this.type,
    required this.cell1,
    required this.cell2,
  });

  factory PuzzleHintData.fromJson(Map<String, dynamic> json) {
    return PuzzleHintData(
      type: json['type'],
      cell1: List<int>.from(json['cell1']),
      cell2: List<int>.from(json['cell2']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'cell1': cell1,
      'cell2': cell2,
    };
  }
} 