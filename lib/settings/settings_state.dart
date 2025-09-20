import 'package:equatable/equatable.dart';
import 'settings_model.dart';

enum SettingsStatus { idle, loading, saved, error }

class SettingsState extends Equatable {
  final SettingsModel model;
  final SettingsStatus status;
  final String? errorMessage;

  const SettingsState({
    required this.model,
    required this.status,
    this.errorMessage,
  });

  factory SettingsState.initial() => SettingsState(
        model: SettingsModel.defaults(),
        status: SettingsStatus.idle,
      );

  SettingsState copyWith({
    SettingsModel? model,
    SettingsStatus? status,
    String? errorMessage,
  }) {
    return SettingsState(
      model: model ?? this.model,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [model, status, errorMessage];
}
