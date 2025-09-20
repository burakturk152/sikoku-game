import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/puzzle_bloc.dart';
import '../bloc/puzzle_events.dart';
import '../bloc/puzzle_states.dart';
import '../inventory/inventory_cubit.dart';
import '../inventory/inventory_state.dart';
import '../admin/admin_mode_cubit.dart';
import '../theme/app_themes.dart';
import 'check_dialog_widget.dart';
import '../services/haptic_service.dart';
import '../settings/settings_cubit.dart';
import '../l10n/app_localizations.dart';

class GameControlButtons extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const GameControlButtons({
    Key? key,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pal = Theme.of(context).extension<AppPalette>()!;
    final l10n = AppLocalizations.of(context)!;
    
    return BlocBuilder<PuzzleBloc, PuzzleState>(
      builder: (context, state) {
        return BlocBuilder<InventoryCubit, InventoryState>(
          builder: (context, inventoryState) {
            final model = inventoryState.model;
            final isAdmin = context.watch<AdminModeCubit>().state;
            
            // Admin moduna göre buton durumları
            bool canHint = isAdmin || model.hintCount > 0;
            bool canUndo = isAdmin || model.undoCount > 0;
            bool canCheck = isAdmin || model.checkCount > 0;
            
            // Admin moduna göre görünüm metinleri
            String hintLabelCount = isAdmin ? '∞' : '${model.hintCount}';
            String undoLabelCount = isAdmin ? '∞' : '${model.undoCount}';
            String checkLabelCount = isAdmin ? '∞' : '${model.checkCount}';
            
            // Sabit buton boyutları
            const double buttonWidth = 60.0;
            const double buttonSpacing = 6.0;
            const double totalWidth = (buttonWidth * 5) + (buttonSpacing * 4);
            
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Üst satır: Butonlar - ekranın ortasında
                Center(
                  child: SizedBox(
                    width: totalWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: buttonWidth,
                          child: _buildInventoryButton(
                            l10n.hint,
                            Icons.lightbulb_outline,
                            Colors.amber,
                            canHint ? 1 : 0, // Admin modunda her zaman 1
                            () async {
                              if (!isAdmin) {
                                final success = await context.read<InventoryCubit>().useHint();
                                if (!success) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.of(context)!.insufficientHints),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  return;
                                }
                              }
                              final bloc = context.read<PuzzleBloc>();
                              bloc.add(PuzzleHint());
                            },
                          ),
                        ),
                        SizedBox(
                          width: buttonWidth,
                          child: _buildButton(l10n.delete, Icons.delete_outline, Colors.red, () {
                            final bloc = context.read<PuzzleBloc>();
                            bloc.add(PuzzleReset());
                          }),
                        ),
                        SizedBox(
                          width: buttonWidth,
                          child: _buildInventoryButton(
                            l10n.undo,
                            Icons.undo,
                            Colors.blue,
                            canUndo ? 1 : 0, // Admin modunda her zaman 1
                            () async {
                              if (!isAdmin) {
                                final success = await context.read<InventoryCubit>().useUndo();
                                if (!success) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Yetersiz Undo'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  return;
                                }
                              }
                              final bloc = context.read<PuzzleBloc>();
                              bloc.add(PuzzleUndo());
                            },
                          ),
                        ),
                        SizedBox(
                          width: buttonWidth,
                          child: _buildButton(l10n.redo, Icons.redo, Colors.green, () {
                            final bloc = context.read<PuzzleBloc>();
                            bloc.add(PuzzleRedo());
                          }),
                        ),
                        SizedBox(
                          width: buttonWidth,
                          child: _buildInventoryButton(
                            l10n.control,
                            Icons.check_circle_outline,
                            state is PuzzleLoaded && state.isChecking ? Colors.orange : Colors.teal,
                            canCheck ? 1 : 0, // Admin modunda her zaman 1
                            () async {
                              if (!isAdmin) {
                                final success = await context.read<InventoryCubit>().useCheck();
                                if (!success) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Yetersiz Check'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                  return;
                                }
                              }
                              
                                                             // Yeni kontrol dialog'unu göster
                               if (state is PuzzleLoaded && context.mounted) {
                                 final mistakeCount = PuzzleBloc.calculateMistakeCount(state);
                                 
                                                                   // Hata varsa titreşim tetikle
                                  if (mistakeCount > 0) {
                                    final settingsState = context.read<SettingsCubit>().state;
                                    if (settingsState.model.hapticOn) {
                                      HapticService().vibrateError(
                                        event: 'kontrol hatası - $mistakeCount hata',
                                        context: context,
                                      );
                                    }
                                  }
                                 
                                 CheckDialogWidget.show(
                                   context: context,
                                   mistakeCount: mistakeCount,
                                   isAdAvailable: true, // TODO: Reklam durumunu kontrol et
                                   onClose: () {
                                     // Dialog kapandı, hiçbir şey yapma
                                   },
                                   onWatchAd: mistakeCount > 0 ? () {
                                     // TODO: Reklam sistemi entegrasyonu
                                     _showMockAdAndRevealMistakes(context);
                                   } : null,
                                 );
                               }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 4),
                
                // Alt satır: Sayılar - ekranın ortasında
                Center(
                  child: SizedBox(
                    width: totalWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: buttonWidth,
                          child: _buildCountText(hintLabelCount, context),
                        ),
                        SizedBox(
                          width: buttonWidth,
                          child: _buildCountText(null, context), // Delete için boş
                        ),
                        SizedBox(
                          width: buttonWidth,
                          child: _buildCountText(undoLabelCount, context),
                        ),
                        SizedBox(
                          width: buttonWidth,
                          child: _buildCountText(null, context), // Redo için boş
                        ),
                        SizedBox(
                          width: buttonWidth,
                          child: _buildCountText(checkLabelCount, context),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Grid boyutu bilgisi kaldırıldı
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildInventoryButton(
    String text,
    IconData icon,
    Color color,
    int count,
    VoidCallback onPressed,
  ) {
    final isEnabled = count > 0;
    
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: isEnabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? color : Colors.grey,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14),
            const SizedBox(width: 2),
            Flexible(
              child: Text(
                text,
                style: const TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountText(String? count, BuildContext context) {
    if (count == null) {
      // Delete ve Redo için boş alan
      return const SizedBox.shrink();
    }
    
    final isEnabled = count != '0' && count != '∞';
    final textColor = isEnabled 
        ? Theme.of(context).colorScheme.onSurface 
        : Theme.of(context).disabledColor;
    
    return Center(
      child: Text(
        count,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  // Mock reklam sistemi - gerçek reklam entegrasyonu için placeholder
  void _showMockAdAndRevealMistakes(BuildContext context) {
    // Simulated ad loading time
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reklam yükleniyor...'),
        duration: Duration(seconds: 2),
      ),
    );
    
         // Simulate ad watching
     Future.delayed(Duration(seconds: 2), () {
       if (context.mounted) {
         // Ad watched successfully, show mistakes
         final bloc = context.read<PuzzleBloc>();
         bloc.add(PuzzleRevealMistakes());
         
                   // Titreşim tetikle
          final settingsState = context.read<SettingsCubit>().state;
          if (settingsState.model.hapticOn) {
            HapticService().vibrate(
              event: 'reklam sonrası hatalar',
              context: context,
            );
          }
         
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Text('Hatalı hücreler gösterildi (8 sn)'),
             backgroundColor: Colors.green,
             duration: Duration(seconds: 3),
           ),
         );
       }
     });
  }
}