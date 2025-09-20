import 'dart:convert';

/// Uygulama ayarlarını temsil eden model (sadeleştirilmiş)
class SettingsModel {
  final bool musicOn;
  final bool sfxOn;
  final double volume; // 0.0 - 1.0
  final bool hapticOn;

  final bool remindDailyOn;
  final bool remindWeeklyOn;

  final String language; // 'tr' | 'en'
  final String puzzleSource; // 'local' | 'remote' | 'github' | 'hybrid'

  const SettingsModel({
    required this.musicOn,
    required this.sfxOn,
    required this.volume,
    required this.hapticOn,
    required this.remindDailyOn,
    required this.remindWeeklyOn,
    required this.language,
    required this.puzzleSource,
  });

  factory SettingsModel.defaults() => const SettingsModel(
        musicOn: true,
        sfxOn: true,
        volume: 0.7,
        hapticOn: true,
        remindDailyOn: false,
        remindWeeklyOn: false,
        language: 'tr',
        puzzleSource: 'hybrid',
      );

  SettingsModel copyWith({
    bool? musicOn,
    bool? sfxOn,
    double? volume,
    bool? hapticOn,
    bool? remindDailyOn,
    bool? remindWeeklyOn,
    String? language,
    String? puzzleSource,
  }) {
    return SettingsModel(
      musicOn: musicOn ?? this.musicOn,
      sfxOn: sfxOn ?? this.sfxOn,
      volume: volume ?? this.volume,
      hapticOn: hapticOn ?? this.hapticOn,
      remindDailyOn: remindDailyOn ?? this.remindDailyOn,
      remindWeeklyOn: remindWeeklyOn ?? this.remindWeeklyOn,
      language: language ?? this.language,
      puzzleSource: puzzleSource ?? this.puzzleSource,
    );
  }

  Map<String, dynamic> toJson() => {
        'musicOn': musicOn,
        'sfxOn': sfxOn,
        'volume': volume,
        'hapticOn': hapticOn,
        'remindDailyOn': remindDailyOn,
        'remindWeeklyOn': remindWeeklyOn,
        'language': language,
        'puzzleSource': puzzleSource,
      };

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      musicOn: (json['musicOn'] as bool?) ?? true,
      sfxOn: (json['sfxOn'] as bool?) ?? true,
      volume: ((json['volume'] as num?) ?? 0.7).toDouble(),
      hapticOn: (json['hapticOn'] as bool?) ?? true,
      remindDailyOn: (json['remindDailyOn'] as bool?) ?? false,
      remindWeeklyOn: (json['remindWeeklyOn'] as bool?) ?? false,
      language: (json['language'] as String?) ?? 'tr',
      puzzleSource: (json['puzzleSource'] as String?) ?? 'hybrid',
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory SettingsModel.fromJsonString(String data) => SettingsModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
}
