import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/shared_pref_helper.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(ThemeMode initialMode)
      : super(ThemeState(themeMode: initialMode));

  Future<void> toggleTheme() async {
    final nextMode = state.themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    emit(ThemeState(themeMode: nextMode));
    await SharedPrefHelper.saveThemeMode(nextMode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(ThemeState(themeMode: mode));
    await SharedPrefHelper.saveThemeMode(mode);
  }
}
