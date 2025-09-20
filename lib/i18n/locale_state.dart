import 'package:flutter/material.dart';

class LocaleState {
  final Locale activeLocale;
  final Locale pendingLocale;

  const LocaleState({
    required this.activeLocale,
    required this.pendingLocale,
  });

  factory LocaleState.initial() {
    const defaultLocale = Locale('tr', 'TR');
    return LocaleState(
      activeLocale: defaultLocale,
      pendingLocale: defaultLocale,
    );
  }

  LocaleState copyWith({
    Locale? activeLocale,
    Locale? pendingLocale,
  }) {
    return LocaleState(
      activeLocale: activeLocale ?? this.activeLocale,
      pendingLocale: pendingLocale ?? this.pendingLocale,
    );
  }

  bool get hasPendingChanges => activeLocale != pendingLocale;
}
