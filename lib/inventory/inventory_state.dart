import 'package:equatable/equatable.dart';
import 'inventory_model.dart';

enum InventoryStatus { idle, loading, saving, error }

class InventoryState extends Equatable {
  final InventoryModel model;
  final InventoryStatus status;
  final String? errorMessage;

  const InventoryState({
    required this.model,
    this.status = InventoryStatus.idle,
    this.errorMessage,
  });

  factory InventoryState.initial() {
    return InventoryState(
      model: InventoryModel.defaults(),
      status: InventoryStatus.idle,
    );
  }

  InventoryState copyWith({
    InventoryModel? model,
    InventoryStatus? status,
    String? errorMessage,
  }) {
    return InventoryState(
      model: model ?? this.model,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  // UI için kolay erişim metodları
  bool get hasHint => model.hintCount > 0;
  bool get hasUndo => model.undoCount > 0;
  bool get hasCheck => model.checkCount > 0;

  @override
  List<Object?> get props => [model, status, errorMessage];
}
