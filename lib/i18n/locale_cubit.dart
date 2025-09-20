import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'locale_repository.dart';
import 'locale_state.dart';

class LocaleCubit extends Cubit<LocaleState> {
  final LocaleRepository _repository;

  LocaleCubit(this._repository) : super(LocaleState.initial());

  Future<void> init() async {
    final savedLocale = await _repository.load();
    final locale = savedLocale ?? const Locale('tr', 'TR');
    
    emit(LocaleState(
      activeLocale: locale,
      pendingLocale: locale,
    ));
  }

  void setPending(Locale locale) {
    emit(state.copyWith(pendingLocale: locale));
  }

  Future<void> apply() async {
    await _repository.save(state.pendingLocale);
    emit(state.copyWith(activeLocale: state.pendingLocale));
  }
}
