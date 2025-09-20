import 'package:flutter_bloc/flutter_bloc.dart';
import 'admin_mode_repository.dart';

class AdminModeCubit extends Cubit<bool> {
  final AdminModeRepository _repository;

  AdminModeCubit(this._repository) : super(false);

  Future<void> init() async {
    final isAdmin = await _repository.load();
    emit(isAdmin);
  }

  Future<void> set(bool value) async {
    await _repository.save(value);
    emit(value);
  }

  Future<void> toggle() async {
    final newValue = !state;
    await set(newValue);
  }
}
