import 'package:flutter_bloc/flutter_bloc.dart';
import 'inventory_model.dart';
import 'inventory_repository.dart';
import 'inventory_state.dart';

class InventoryCubit extends Cubit<InventoryState> {
  final InventoryRepository _repository;

  InventoryCubit(this._repository) : super(InventoryState.initial());

  Future<void> init() async {
    emit(state.copyWith(status: InventoryStatus.loading));
    
    try {
      final model = await _repository.load();
      emit(state.copyWith(
        model: model,
        status: InventoryStatus.idle,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: 'Envanter yüklenemedi: $e',
      ));
    }
  }

  Future<bool> useHint() async {
    if (state.model.hintCount <= 0) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: 'Yetersiz Hint',
      ));
      return false;
    }

    try {
      emit(state.copyWith(status: InventoryStatus.saving));
      
      final newModel = state.model.copyWith(
        hintCount: state.model.hintCount - 1,
      );
      
      await _repository.save(newModel);
      
      emit(state.copyWith(
        model: newModel,
        status: InventoryStatus.idle,
      ));
      
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: 'Hint kullanılamadı: $e',
      ));
      return false;
    }
  }

  Future<bool> useUndo() async {
    if (state.model.undoCount <= 0) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: 'Yetersiz Undo',
      ));
      return false;
    }

    try {
      emit(state.copyWith(status: InventoryStatus.saving));
      
      final newModel = state.model.copyWith(
        undoCount: state.model.undoCount - 1,
      );
      
      await _repository.save(newModel);
      
      emit(state.copyWith(
        model: newModel,
        status: InventoryStatus.idle,
      ));
      
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: 'Undo kullanılamadı: $e',
      ));
      return false;
    }
  }

  Future<bool> useCheck() async {
    if (state.model.checkCount <= 0) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: 'Yetersiz Check',
      ));
      return false;
    }

    try {
      emit(state.copyWith(status: InventoryStatus.saving));
      
      final newModel = state.model.copyWith(
        checkCount: state.model.checkCount - 1,
      );
      
      await _repository.save(newModel);
      
      emit(state.copyWith(
        model: newModel,
        status: InventoryStatus.idle,
      ));
      
      return true;
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: 'Check kullanılamadı: $e',
      ));
      return false;
    }
  }

  Future<void> addItems({
    int hint = 0,
    int undo = 0,
    int check = 0,
  }) async {
    try {
      emit(state.copyWith(status: InventoryStatus.saving));
      
      final newModel = state.model.copyWith(
        hintCount: state.model.hintCount + hint,
        undoCount: state.model.undoCount + undo,
        checkCount: state.model.checkCount + check,
      );
      
      await _repository.save(newModel);
      
      emit(state.copyWith(
        model: newModel,
        status: InventoryStatus.idle,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: 'Envanter güncellenemedi: $e',
      ));
    }
  }

  Future<void> addHints(int count) async {
    await addItems(hint: count);
  }

  Future<void> addUndos(int count) async {
    await addItems(undo: count);
  }

  Future<void> addChecks(int count) async {
    await addItems(check: count);
  }

  Future<void> reset() async {
    try {
      emit(state.copyWith(status: InventoryStatus.saving));
      
      await _repository.reset();
      final defaults = InventoryModel.defaults();
      await _repository.save(defaults);
      
      emit(state.copyWith(
        model: defaults,
        status: InventoryStatus.idle,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: 'Envanter sıfırlanamadı: $e',
      ));
    }
  }
}
