import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../core/notification_service.dart';
import '../audio/audio_gateway.dart';
import 'settings_model.dart';
import 'settings_repository.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SettingsRepository _repo;
  final NotificationService _notifier;
  final AudioGateway _audio;

  SettingsCubit({SettingsRepository? repository, NotificationService? notifier, AudioGateway? audio})
      : _repo = repository ?? SettingsRepository(),
        _notifier = notifier ?? NotificationService(),
        _audio = audio ?? AudioGateway(),
        super(SettingsState.initial());

  Future<void> init() async {
    emit(state.copyWith(status: SettingsStatus.loading));
    await _notifier.initialize();
    final model = await _repo.load();
    await _audio.apply(model);
    emit(state.copyWith(status: SettingsStatus.idle, model: model));
  }

  Future<void> toggleMusic() => _update(state.model.copyWith(musicOn: !state.model.musicOn));
  Future<void> toggleSfx() => _update(state.model.copyWith(sfxOn: !state.model.sfxOn));
  Future<void> toggleHaptic() => _update(state.model.copyWith(hapticOn: !state.model.hapticOn));

  Future<void> setVolume(double v) => _update(state.model.copyWith(volume: v.clamp(0.0, 1.0)));

  // Locale yönetimi
  Locale get currentLocale {
    final lang = state.model.language;
    return lang == 'en' ? const Locale('en') : const Locale('tr');
  }

  Future<void> setLocale(Locale locale) async {
    final language = locale.languageCode;
    await _update(state.model.copyWith(language: language));
  }

  Future<void> setPuzzleSource(String source) async {
    await _update(state.model.copyWith(puzzleSource: source));
  }

  Future<void> toggleDaily(bool on) async {
    var m = state.model.copyWith(remindDailyOn: on);
    await _update(m);
    if (on) {
      final granted = await _notifier.requestPermission();
      if (!granted) {
        emit(state.copyWith(status: SettingsStatus.error, errorMessage: 'Bildirim izni gerekli'));
        m = m.copyWith(remindDailyOn: false);
        await _update(m);
        return;
      }
      // await _notifier.scheduleDaily();
    } else {
      await _notifier.cancelDaily();
    }
    emit(state.copyWith(status: SettingsStatus.saved));
  }

  Future<void> toggleWeekly(bool on) async {
    var m = state.model.copyWith(remindWeeklyOn: on);
    await _update(m);
    if (on) {
      final granted = await _notifier.requestPermission();
      if (!granted) {
        emit(state.copyWith(status: SettingsStatus.error, errorMessage: 'Bildirim izni gerekli'));
        m = m.copyWith(remindWeeklyOn: false);
        await _update(m);
        return;
      }
      // await _notifier.scheduleWeekly();
    } else {
      await _notifier.cancelWeekly();
    }
    emit(state.copyWith(status: SettingsStatus.saved));
  }

  Future<void> _update(SettingsModel model) async {
    await _repo.save(model);
    await _audio.apply(model);
    emit(state.copyWith(model: model, status: SettingsStatus.saved));
  }
}
