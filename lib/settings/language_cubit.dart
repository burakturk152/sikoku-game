import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageState extends Equatable {
  final String code; // 'tr' | 'en'
  const LanguageState(this.code);
  @override
  List<Object?> get props => [code];
}

class LanguageCubit extends Cubit<LanguageState> {
  static const _prefsKey = 'app.settings.language';
  LanguageCubit() : super(const LanguageState('tr')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey) ?? 'tr';
    emit(LanguageState(code));
  }

  Future<void> setLanguage(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, code);
    emit(LanguageState(code));
  }
}
