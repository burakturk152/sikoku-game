import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_states.dart';
import '../services/game_timer_service.dart';
import '../services/haptic_service.dart';
import '../settings/settings_cubit.dart';
import '../l10n/app_localizations.dart';
import 'success_dialog_widget.dart';

class GameErrorHandler {
  static void handlePuzzleError(BuildContext context, PuzzleError state) {
    // Hata durumunda titreşim tetikle
    try {
      final settingsState = context.read<SettingsCubit>().state;
      if (settingsState.model.hapticOn) {
        HapticService().vibrateError(
          event: 'puzzle hatası: ${state.message}',
          context: context,
        );
      }
    } catch (e) {
      print('SettingsCubit not found for error haptic: $e');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.message,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade700,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void handlePuzzleSolved({
    required BuildContext context,
    required GameTimerService timerService,
    required VoidCallback stopTimer,
    required VoidCallback setPuzzleCompleted,
    required VoidCallback showSuccessDialog,
    bool isDaily = false,
  }) {
    stopTimer();
    setPuzzleCompleted();
    timerService.setPuzzleCompleted(true);
    
         // Win durumunda başarı titreşimi tetikle
     try {
       final settingsState = context.read<SettingsCubit>().state;
       if (settingsState.model.hapticOn) {
         HapticService().vibrateSuccess(
           event: AppLocalizations.of(context)!.levelCompleted,
           context: context,
         );
       }
     } catch (e) {
       // SettingsCubit bulunamazsa sessizce devam et
       print('SettingsCubit not found for haptic: $e');
     }
    
    showSuccessDialog();
  }
} 