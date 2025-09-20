import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import '../settings/settings_cubit.dart';
import '../settings/settings_state.dart';
import '../settings/settings_repository.dart';
import '../bloc/level_progress_cubit.dart';
import '../bloc/game_stats_cubit.dart';
import '../inventory/inventory_cubit.dart';
import '../admin/admin_mode_cubit.dart';
import '../store/store_cubit.dart';
import '../core/notification_service.dart';
import '../services/haptic_service.dart';
import '../l10n/app_localizations.dart';
import '../config/universe_config.dart';

@RoutePage()
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Locale? _selectedLocale;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<SettingsCubit, SettingsState>(
      listener: (context, state) {
        if (state.status == SettingsStatus.saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.close)),
          );
        } else if (state.status == SettingsStatus.error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage ?? 'Hata oluştu')),
          );
        }
      },
      builder: (context, state) {
        if (state.status == SettingsStatus.loading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final m = state.model;
        final currentLocale = context.select((SettingsCubit c) => c.currentLocale);
        
        // İlk yüklemede seçili locale'i ayarla
        if (_selectedLocale == null) {
          _selectedLocale = currentLocale;
        }
        
        return Scaffold(
          appBar: AppBar(title: Text(l10n.settings)),
          body: state.status == SettingsStatus.loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Section(
                        title: l10n.soundMusic,
                        child: Column(
                          children: [
                            SwitchListTile(
                              value: m.musicOn,
                              title: Text(l10n.music),
                              onChanged: (_) => context.read<SettingsCubit>().toggleMusic(),
                            ),
                            SwitchListTile(
                              value: m.sfxOn,
                              title: Text(l10n.soundEffects),
                              onChanged: (_) => context.read<SettingsCubit>().toggleSfx(),
                            ),
                            ListTile(
                              title: Text(l10n.soundVolume),
                              subtitle: Slider(
                                value: m.volume,
                                min: 0.0,
                                max: 1.0,
                                divisions: 10,
                                onChanged: (v) => context.read<SettingsCubit>().setVolume(v),
                              ),
                            ),
                            SwitchListTile(
                              value: m.hapticOn,
                              title: Text(l10n.vibration),
                              onChanged: (_) => context.read<SettingsCubit>().toggleHaptic(),
                            ),
                            // Titreşim test butonu
                            if (m.hapticOn) ...[
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () async {
                                  await HapticService().testAllVibrations(context: context);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context)!.vibrationTestCompleted),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                },
                                icon: const Icon(Icons.vibration),
                                label: Text(AppLocalizations.of(context)!.vibrationTest),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade100,
                                  foregroundColor: Colors.blue.shade800,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      _Section(
                        title: l10n.notifications,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SwitchListTile(
                              value: m.remindDailyOn,
                              title: Text(l10n.remindDailyPuzzle),
                              onChanged: (on) async {
                                context.read<SettingsCubit>().toggleDaily(on);
                                if (on) {
                                  final granted = await NotificationService().requestPermission();
                                  if (granted && context.mounted) {
                                    await NotificationService().scheduleDaily(context);
                                  }
                                } else {
                                  await NotificationService().cancelDaily();
                                }
                              },
                            ),
                            SwitchListTile(
                              value: m.remindWeeklyOn,
                              title: Text(l10n.remindWeeklyPuzzle),
                              onChanged: (on) async {
                                context.read<SettingsCubit>().toggleWeekly(on);
                                if (on) {
                                  final granted = await NotificationService().requestPermission();
                                  if (granted && context.mounted) {
                                    await NotificationService().scheduleWeekly(context);
                                  }
                                } else {
                                  await NotificationService().cancelWeekly();
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      _Section(
                        title: l10n.adminModeTitle,
                        child: BlocBuilder<AdminModeCubit, bool>(
                          builder: (context, isAdmin) {
                            return SwitchListTile.adaptive(
                              title: Text(l10n.adminModeTitle),
                              subtitle: Text(l10n.adminModeDesc),
                              value: isAdmin,
                              onChanged: (v) => context.read<AdminModeCubit>().set(v),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      _Section(
                        title: 'Bulmaca Kaynağı',
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: const Text('Yerel (Assets)'),
                              subtitle: const Text('Sadece uygulama içi dosyalar'),
                              value: 'local',
                              groupValue: m.puzzleSource,
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<SettingsCubit>().setPuzzleSource(value);
                                }
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('GitHub'),
                              subtitle: const Text('GitHub\'dan otomatik indirme'),
                              value: 'github',
                              groupValue: m.puzzleSource,
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<SettingsCubit>().setPuzzleSource(value);
                                }
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Uzak Sunucu'),
                              subtitle: const Text('Uzak CDN\'den indirme'),
                              value: 'remote',
                              groupValue: m.puzzleSource,
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<SettingsCubit>().setPuzzleSource(value);
                                }
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Otomatik'),
                              subtitle: const Text('GitHub → Uzak → Yerel (önerilen)'),
                              value: 'hybrid',
                              groupValue: m.puzzleSource,
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<SettingsCubit>().setPuzzleSource(value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      _Section(
                        title: l10n.language,
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButton<Locale>(
                                value: _selectedLocale,
                                items: [
                                  DropdownMenuItem(
                                    value: const Locale('tr'),
                                    child: Text('Türkçe'),
                                  ),
                                  DropdownMenuItem(
                                    value: const Locale('en'),
                                    child: Text('English'),
                                  ),
                                ],
                                onChanged: (locale) {
                                  if (locale == null) return;
                                  setState(() {
                                    _selectedLocale = locale;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _selectedLocale != currentLocale ? () {
                                context.read<SettingsCubit>().setLocale(_selectedLocale!);
                              } : null,
                              child: Text(l10n.apply),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      _Section(
                        title: l10n.resetProgress,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () async {
                              final ok = await showDialog<bool>(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('Onay'),
                                    content: Text('Tüm yerel veriler silinsin mi? (Geri alınamaz)'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.back)),
                                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Evet, sil')),
                                    ],
                                  );
                                },
                              );
                              if (ok == true) {
                                await SettingsRepository().reset();
                                await context.read<LevelProgressCubit>().resetAllProgress();
                                await context.read<GameStatsCubit>().resetStats();
                                await context.read<InventoryCubit>().reset();
                                await context.read<StoreCubit>().resetDailyRewards();
                                await NotificationService().cancelDaily();
                                await NotificationService().cancelWeekly();
                                
                                // Evren 2'yi tekrar kilitle
                                await UniverseConfig.lockUniverse(2);
                                print('=== UNIVERSE 2 LOCKED AFTER RESET ===');
                                
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Veriler sıfırlandı.')),
                                  );
                                }
                                context.read<SettingsCubit>().init();
                              }
                            },
                            child: Text(l10n.resetProgress),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.cardColor.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}


