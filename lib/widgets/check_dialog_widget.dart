import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

class CheckDialogWidget {
  static void show({
    required BuildContext context,
    required int mistakeCount,
    required bool isAdAvailable,
    required VoidCallback onClose,
    VoidCallback? onWatchAd,
  }) {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l10n.controlDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                mistakeCount == 0
                    ? l10n.noErrors
                    : l10n.errorsFound(mistakeCount),
              ),
              if (mistakeCount > 0 && !isAdAvailable)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Reklam şu anda mevcut değil',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                onClose();
              },
              child: Text(l10n.close),
            ),
            if (mistakeCount > 0)
              ElevatedButton(
                onPressed: isAdAvailable ? () {
                  Navigator.of(dialogContext).pop();
                  onWatchAd?.call();
                } : null,
                child: Text(l10n.watchAdToSeeMistakes),
              ),
          ],
        );
      },
    );
  }
}
