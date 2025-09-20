class InventoryModel {
  final int hintCount;
  final int undoCount;
  final int checkCount;

  const InventoryModel({
    required this.hintCount,
    required this.undoCount,
    required this.checkCount,
  });

  factory InventoryModel.defaults() => const InventoryModel(
    hintCount: 1,
    undoCount: 1,
    checkCount: 1,
  );

  Map<String, dynamic> toJson() {
    return {
      'hintCount': hintCount,
      'undoCount': undoCount,
      'checkCount': checkCount,
    };
  }

  factory InventoryModel.fromJson(Map<String, dynamic> json) {
    return InventoryModel(
      hintCount: json['hintCount'] ?? 1,
      undoCount: json['undoCount'] ?? 1,
      checkCount: json['checkCount'] ?? 1,
    );
  }

  InventoryModel copyWith({
    int? hintCount,
    int? undoCount,
    int? checkCount,
  }) {
    return InventoryModel(
      hintCount: hintCount ?? this.hintCount,
      undoCount: undoCount ?? this.undoCount,
      checkCount: checkCount ?? this.checkCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InventoryModel &&
        other.hintCount == hintCount &&
        other.undoCount == undoCount &&
        other.checkCount == checkCount;
  }

  @override
  int get hashCode => hintCount.hashCode ^ undoCount.hashCode ^ checkCount.hashCode;
}
