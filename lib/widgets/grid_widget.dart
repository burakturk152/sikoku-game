import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3;
import 'dart:ui' as ui;
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_states.dart';
import '../bloc/puzzle_events.dart';
import '../widgets/painters.dart';
import '../models/puzzle_data.dart';
import '../services/image_cache_service.dart';
import '../theme/app_themes.dart';
import '../theme/cell_icons.dart';
import '../config/universe_config.dart';

import 'animated_error_cell.dart';

class GridWidget extends StatefulWidget {
  final PuzzleLoaded state;
  final double screenWidth;
  final double screenHeight;
  final double gridArea;
  final double gap;
  final double cellSize;
  final int cellCount;
  final double fontSize;
  final List<List<int>>? currentHints;
  final TransformationController transformationController;
  final int stage;
  final CellIconSet iconSet; // Yeni parametre

  const GridWidget({
    Key? key,
    required this.state,
    required this.screenWidth,
    required this.screenHeight,
    required this.gridArea,
    required this.gap,
    required this.cellSize,
    required this.cellCount,
    required this.fontSize,
    required this.currentHints,
    required this.transformationController,
    required this.stage,
    required this.iconSet, // Yeni parametre
  }) : super(key: key);

  @override
  State<GridWidget> createState() => _GridWidgetState();
}

class _GridWidgetState extends State<GridWidget> {
  ui.Image? equalImage;
  ui.Image? notEqualImage;

  @override
  void initState() {
    super.initState();
    _loadImages();
  }

  Future<void> _loadImages() async {
    // Cache'den PNG'leri al
    final imageCache = ImageCacheService();
    
    if (imageCache.isLoaded) {
      // Cache'de varsa direkt kullan
      equalImage = imageCache.equalImage;
      notEqualImage = imageCache.notEqualImage;
    } else {
      // Cache'de yoksa yükle (fallback)
      await imageCache.loadHintImages();
      equalImage = imageCache.equalImage;
      notEqualImage = imageCache.notEqualImage;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final pal = Theme.of(context).extension<AppPalette>()!;
    
    return InteractiveViewer(
      transformationController: widget.transformationController,
      minScale: 0.5,
      maxScale: 3.0,
      child: Container(
        width: widget.gridArea + (widget.gridArea * 0.25),
        height: widget.gridArea + (widget.gridArea * 0.15) + widget.gridArea * 0.1,
        color: pal.puzzleBackground,
        child: Stack(
          children: [
            // Grid Layer
            Positioned(
              left: widget.gridArea * 0.1,
              top: widget.gridArea * 0.1,
              width: widget.gridArea,
              height: widget.gridArea,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.cellCount,
                  crossAxisSpacing: widget.gap,
                  mainAxisSpacing: widget.gap,
                ),
                itemCount: widget.cellCount * widget.cellCount,
                itemBuilder: (context, index) {
                  final row = index ~/ widget.cellCount;
                  final col = index % widget.cellCount;
                  
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (!_isPrefilledCell(row, col, widget.state.prefilled)) {
                        try {
                          final bloc = context.read<PuzzleBloc>();
                          bloc.add(PuzzleCellTapped(row, col));
                        } catch (e) {
                          print('ERROR: Bloc bulunamadı: $e');
                        }
                      }
                    },
                    child: Container(
                      decoration: _getCellDecoration(widget.state.gridState[row][col], row, col, widget.state.errorCells, pal),
                      child: _getCellSymbol(widget.state.gridState[row][col], widget.cellSize),
                    ),
                  );
                },
              ),
            ),
            
            // Hints Layer (Pass-through)
            if (widget.currentHints != null)
              Positioned(
                left: widget.gridArea * 0.1,
                top: widget.gridArea * 0.1,
                width: widget.gridArea,
                height: widget.gridArea,
                child: IgnorePointer(
                  ignoring: true,
                  child: CustomPaint(
                    painter: HintsPainter(
                      hints: widget.currentHints!,
                      cellSize: widget.cellSize,
                      gap: widget.gap,
                      cellCount: widget.cellCount,
                      equalImage: equalImage,
                      notEqualImage: notEqualImage,
                    ),
                  ),
                ),
              ),
            
            // Sol sayaçlar (satır sayıları)
            for (int row = 0; row < widget.cellCount; row++)
              Positioned(
                left: 0,
                top: widget.gridArea * 0.1 + row * (widget.cellSize + widget.gap) + (widget.cellSize - widget.gridArea * 0.08) / 2,
                width: widget.gridArea * 0.1,
                height: widget.gridArea * 0.08,
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: _buildCounter(
                      '${_getRowCounts(widget.state.gridState, row)[0]}|${_getRowCounts(widget.state.gridState, row)[1]}',
                      widget.fontSize * 0.8,
                      _getCounterColor(_getRowCounts(widget.state.gridState, row), widget.cellCount, pal),
                    ),
                  ),
                ),
              ),
            
            // Sağ sayaçlar (satır sayıları)
            for (int row = 0; row < widget.cellCount; row++)
              Positioned(
                left: widget.gridArea * 0.1 + widget.gridArea + widget.gridArea * 0.02,
                top: widget.gridArea * 0.1 + row * (widget.cellSize + widget.gap) + (widget.cellSize - widget.gridArea * 0.08) / 2,
                width: widget.gridArea * 0.1,
                height: widget.gridArea * 0.08,
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: _buildCounter(
                      '${_getRowCounts(widget.state.gridState, row)[0]}|${_getRowCounts(widget.state.gridState, row)[1]}',
                      widget.fontSize * 0.8,
                      _getCounterColor(_getRowCounts(widget.state.gridState, row), widget.cellCount, pal),
                    ),
                  ),
                ),
              ),
            
            // Üst sayaçlar (sütun sayıları)
            for (int col = 0; col < widget.cellCount; col++)
              Positioned(
                left: widget.gridArea * 0.1 + col * (widget.cellSize + widget.gap) + (widget.cellSize - widget.gridArea * 0.08) / 2,
                top: widget.gridArea * 0.02,
                width: widget.gridArea * 0.08,
                height: widget.gridArea * 0.1,
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: _buildCounter(
                      '${_getColumnCounts(widget.state.gridState, col)[0]}|${_getColumnCounts(widget.state.gridState, col)[1]}',
                      widget.fontSize * 0.8,
                      _getCounterColor(_getColumnCounts(widget.state.gridState, col), widget.cellCount, pal),
                    ),
                  ),
                ),
              ),
            
            // Alt sayaçlar (sütun sayıları)
            for (int col = 0; col < widget.cellCount; col++)
              Positioned(
                left: widget.gridArea * 0.1 + col * (widget.cellSize + widget.gap) + (widget.cellSize - widget.gridArea * 0.08) / 2,
                top: widget.gridArea * 0.1 + widget.gridArea,
                width: widget.gridArea * 0.08,
                height: widget.gridArea * 0.1,
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: _buildCounter(
                      '${_getColumnCounts(widget.state.gridState, col)[0]}|${_getColumnCounts(widget.state.gridState, col)[1]}',
                      widget.fontSize * 0.8,
                      _getCounterColor(_getColumnCounts(widget.state.gridState, col), widget.cellCount, pal),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Sayaç hesaplama fonksiyonları
  List<int> _getRowCounts(List<List<int>> gridState, int row) {
    int blueCount = 0;
    int yellowCount = 0;
    for (int col = 0; col < gridState[row].length; col++) {
      if (gridState[row][col] == 1) blueCount++;
      if (gridState[row][col] == 2) yellowCount++;
    }
    return [blueCount, yellowCount];
  }

  List<int> _getColumnCounts(List<List<int>> gridState, int col) {
    int blueCount = 0;
    int yellowCount = 0;
    for (int row = 0; row < gridState.length; row++) {
      if (gridState[row][col] == 1) blueCount++;
      if (gridState[row][col] == 2) yellowCount++;
    }
    return [blueCount, yellowCount];
  }

  Color _getCounterColor(List<int> counts, int cellCount, AppPalette pal) {
    // Maksimum değerleri hesapla (6x6 için 3|3, 8x8 için 4|4, 10x10 için 5|5)
    final maxValue = cellCount ~/ 2;
    
    // Eğer her iki değer de maksimuma ulaşmışsa gri renk
    if (counts[0] == maxValue && counts[1] == maxValue) {
      return Colors.grey.shade400;
    }
    
    // Normal renk
    return pal.counterTextColor;
  }

  Widget _buildCounter(String text, double fontSize, Color counterColor) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: counterColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  bool _isPrefilledCell(int row, int col, List<List<int>> prefilled) {
    return prefilled.any((position) => position[0] == row && position[1] == col);
  }

  bool _isErrorCell(int row, int col, List<List<int>> errorCells) {
    return errorCells.any((cell) => cell[0] == row && cell[1] == col);
  }

  BoxDecoration _getCellDecoration(int state, int row, int col, List<List<int>> errorCells, AppPalette pal) {
    // Hatalı hücre kontrolü - canRevealMistakes true ise hataları göster
    bool isErrorCell = widget.state.canRevealMistakes && errorCells.any((cell) => cell[0] == row && cell[1] == col);
    bool isPrefilled = _isPrefilledCell(row, col, widget.state.prefilled);
    
    // İlk evren için PNG görselleri ile uyumlu gradyan arka planlar
    if (_isFirstUniverse()) {
      BoxDecoration decoration;
      
      switch (state) {
        case 0: 
          // Boş hücre - gri arka plan
          decoration = BoxDecoration(
            color: pal.emptyCellColor,
            borderRadius: BorderRadius.circular(6),
            border: isPrefilled 
                ? Border.all(
                    color: Color(0xFF6A0DAD),
                    width: (widget.cellSize * 0.04).clamp(1.0, 4.0),  // Her iki stage için %4
                  )
                : (isErrorCell 
                    ? Border.all(
                        color: const Color(0xFFFF3B30),
                        width: 3.0,
                      )
                    : null),
            boxShadow: isPrefilled 
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                  ]
                : isErrorCell
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF3B30).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
          );
          break;
        case 1: 
          // Dünya - mavi gradyan arka plan
          decoration = BoxDecoration(
            gradient: pal.earthCellGradient,
            borderRadius: BorderRadius.circular(6),
            border: isPrefilled 
                ? Border.all(
                    color: Color(0xFF6A0DAD),
                    width: (widget.cellSize * 0.04).clamp(1.0, 4.0),  // Her iki stage için %4
                  )
                : (isErrorCell 
                    ? Border.all(
                        color: const Color(0xFFFF3B30),
                        width: 3.0,
                      )
                    : null),
            boxShadow: isPrefilled 
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                  ]
                : isErrorCell
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF3B30).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
          );
          break;
        case 2: 
          // Güneş - sarı gradyan arka plan
          decoration = BoxDecoration(
            gradient: pal.sunCellGradient,
            borderRadius: BorderRadius.circular(6),
            border: isPrefilled 
                ? Border.all(
                    color: Color(0xFF6A0DAD),
                    width: (widget.cellSize * 0.04).clamp(1.0, 4.0),  // Her iki stage için %4
                  )
                : (isErrorCell 
                    ? Border.all(
                        color: const Color(0xFFFF3B30),
                        width: 3.0,
                      )
                    : null),
            boxShadow: isPrefilled 
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                  ]
                : isErrorCell
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF3B30).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
          );
          break;
        default: 
          decoration = BoxDecoration(
            color: pal.emptyCellColor,
            borderRadius: BorderRadius.circular(6),
            border: isPrefilled 
                ? Border.all(
                    color: Color(0xFF6A0DAD),
                    width: (widget.cellSize * 0.04).clamp(1.0, 4.0),  // Her iki stage için %4
                  )
                : (isErrorCell 
                    ? Border.all(
                        color: const Color(0xFFFF3B30),
                        width: 3.0,
                      )
                    : null),
            boxShadow: isPrefilled 
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 3,
                      offset: Offset(1, 1),
                    ),
                  ]
                : isErrorCell
                    ? [
                        BoxShadow(
                          color: const Color(0xFFFF3B30).withOpacity(0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
          );
      }
      
      return decoration;
    }
    
    // Diğer evrenler için eski renk sistemi
    Color baseColor;
    switch (state) {
      case 0: baseColor = Colors.blueGrey.shade700; // Boş
      case 1: baseColor = Colors.blue; // Mavi
      case 2: baseColor = Colors.yellow; // Sarı
      default: baseColor = Colors.blueGrey.shade700;
    }
    
    // Hatalı hücre ise kırmızıya çalan renk
    if (isErrorCell) {
      baseColor = baseColor.withRed((baseColor.red + 100).clamp(0, 255));
    }
    
    return BoxDecoration(
      color: baseColor,
      borderRadius: BorderRadius.circular(6),
      border: isPrefilled 
          ? Border.all(
              color: Color(0xFF6A0DAD),
              width: (widget.cellSize * 0.04).clamp(1.0, 4.0),  // Her iki stage için %4
            )
          : (isErrorCell 
              ? Border.all(
                  color: Colors.red,
                  width: widget.screenWidth * 0.003,
                )
              : null),
      boxShadow: isPrefilled 
          ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 3,
                offset: Offset(1, 1),
              ),
            ]
          : [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
    );
  }

  Widget _getCellSymbol(int state, double cellSize) {
    if (state == 0) return const SizedBox.shrink(); // Boş durum
    
    // Stage 0 (Günlük/Haftalık bulmacalar) için üçgen ve yuvarlak çizimler
        if (widget.stage == 0) {
          return Center(
            child: Container(
              width: cellSize * 0.7,
              height: cellSize * 0.7,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 3,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
              child: Image.asset(
                state == 1 ? 'assets/images/circle.png' : 'assets/images/triangle.png',
                fit: BoxFit.contain,
              ),
            ),
          );
        }
    
    // Stage 1 için sunny.png ve earth.png görselleri
    if (widget.stage == 1) {
      final iconLogical = cellSize * 0.6;
      
      return Center(
        child: Container(
          width: iconLogical,
          height: iconLogical,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                spreadRadius: 1,
                offset: Offset(2, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              state == 1 ? 'assets/images/earth.png' : 'assets/images/sunny.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
    
    // Stage 2 için banana ve blueberry görselleri
    if (widget.stage == 2) {
      final iconLogical = cellSize * 0.6;
      
      return Center(
        child: Container(
          width: iconLogical,
          height: iconLogical,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                spreadRadius: 1,
                offset: Offset(2, 2),
              ),
            ],
            borderRadius: BorderRadius.circular(8),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              state == 1 ? 'assets/images/blueberry.png' : 'assets/images/banana.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }
    
    // Diğer evrenler için eski şekilleri kullan
    return Center(
      child: SizedBox(
        width: cellSize * 0.4,
        height: cellSize * 0.4,
        child: CustomPaint(
          painter: state == 1 ? CirclePainter() : DiamondPainter(),
        ),
      ),
    );
  }
  
  bool _isFirstUniverse() {
    // Stage 1 ve Stage 2 için gradyan sistemi kullan (PNG görselleri sadece Stage 1'de)
    return widget.stage == 1 || widget.stage == 2;
  }

  // Evren temasına göre hücre görselini getir
  String _getCellImage(int state) {
    print('=== GRID WIDGET DEBUG ===');
    print('Widget stage: ${widget.stage}');
    print('State: $state');
    print('IconSet blue: ${widget.iconSet.blue}');
    print('IconSet yellow: ${widget.iconSet.yellow}');
    
    if (state == 1) {
      print('Returning blue icon: ${widget.iconSet.blue}');
      return widget.iconSet.blue; // Mavi hücreler için
    } else {
      print('Returning yellow icon: ${widget.iconSet.yellow}');
      return widget.iconSet.yellow; // Sarı hücreler için
    }
  }

  // Net ikon oluşturma metodu - PNG'ler geçici olarak kaldırıldı
  Widget _buildSharpIcon(int state, double iconLogical) {
    // Hiçbir şey gösterme - sadece hücre rengi kalsın
    return const SizedBox.shrink();
  }
}