import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import '../routes/app_router.dart';
import '../bloc/level_progress_cubit.dart';
import '../bloc/game_stats_cubit.dart';
import '../l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../inventory/inventory_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuccessDialogWidget {
  static Future<void> show({
    required BuildContext context,
    required int level,
    required int elapsedSeconds,
    required int stage,
    required bool isDaily,
    required bool isWeekly,
    required VoidCallback onBackToMenu,
  }) async {
    final stars = _calculateStars(elapsedSeconds);
    final l10n = AppLocalizations.of(context)!;
    
    // Günlük ve haftalık bulmaca için rastgele ödül seç
    String? dailyReward;
    String? weeklyReward;
    bool canClaimDailyReward = false;
    bool canClaimWeeklyReward = false;
    
    if (isDaily) {
      // Günlük bulmaca ödülü daha önce alınmış mı kontrol et
      canClaimDailyReward = await _canClaimDailyReward();
      if (canClaimDailyReward) {
        final rewards = ['Hint', 'Check', 'Undo'];
        dailyReward = rewards[Random().nextInt(rewards.length)];
      }
    }
    
    if (isWeekly) {
      // Haftalık bulmaca ödülü daha önce alınmış mı kontrol et
      canClaimWeeklyReward = await _canClaimWeeklyReward();
      if (canClaimWeeklyReward) {
        final rewards = ['Hint', 'Check', 'Undo'];
        weeklyReward = rewards[Random().nextInt(rewards.length)];
      }
    }
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          '${l10n.winsCongratsTitle} 🎉',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.puzzleCompletedIn(_formatTime(elapsedSeconds)),
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            // Günlük bulmaca için ödül, normal seviyeler için yıldız
            if (isDaily) ...[
              if (canClaimDailyReward) ...[
                Text(
                  '🎁 ${AppLocalizations.of(context)!.rewardEarned(dailyReward!)}',
                  style: TextStyle(color: Colors.green, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Icon(
                  _getRewardIcon(dailyReward!),
                  color: Colors.green,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.congratulationsReward(dailyReward!),
                  style: TextStyle(color: Colors.green, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  '🎁 ${AppLocalizations.of(context)!.dailyRewardTitle}',
                  style: TextStyle(color: Colors.orange, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Icon(
                  Icons.check_circle,
                  color: Colors.orange,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.alreadyCompletedDaily,
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ] else if (isWeekly) ...[
              if (canClaimWeeklyReward) ...[
                Text(
                  '🎁 ${AppLocalizations.of(context)!.rewardEarned(weeklyReward!)}',
                  style: TextStyle(color: Colors.purple, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Icon(
                  _getRewardIcon(weeklyReward!),
                  color: Colors.purple,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.congratulationsReward(weeklyReward!),
                  style: TextStyle(color: Colors.purple, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ] else ...[
                Text(
                  '🎁 ${AppLocalizations.of(context)!.weeklyRewardTitle}',
                  style: TextStyle(color: Colors.purple, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Icon(
                  Icons.check_circle,
                  color: Colors.orange,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)!.alreadyCompletedWeekly,
                  style: TextStyle(color: Colors.orange, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ] else ...[
              Text(
                '⭐ Kazanılan Yıldız: $stars',
                style: TextStyle(color: Colors.amber, fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(stars, (_) => 
                  Icon(Icons.star, color: Colors.amber, size: 24)
                ),
              ),
              SizedBox(height: 8),
              Text(
                _getStarMessage(stars, context),
                style: TextStyle(color: Colors.amber, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          // Günlük ve haftalık bulmaca için ödülü al butonu
          if (isDaily && canClaimDailyReward) ...[
            TextButton(
              onPressed: () async {
                // Direkt reklam izle ve ödülü al
                await _watchAdAndClaimReward(context, dailyReward!, isDaily: true);
              },
              child: Text(
                AppLocalizations.of(context)!.claimReward,
                style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          if (isWeekly && canClaimWeeklyReward) ...[
            TextButton(
              onPressed: () async {
                // Direkt reklam izle ve ödülü al
                await _watchAdAndClaimReward(context, weeklyReward!, isWeekly: true);
              },
              child: Text(
                AppLocalizations.of(context)!.claimReward,
                style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          TextButton(
            onPressed: () async {
              print('=== SUCCESS DIALOG DEBUG ===');
              print('Level: $level, Elapsed: $elapsedSeconds');
              
              // GameStatsCubit'i al
              final gameStatsCubit = context.read<GameStatsCubit>();
              
              if (isDaily) {
                // Günlük puzzle tamamlandı
                await gameStatsCubit.onDailyCompleted(elapsedSeconds);
                print('Daily puzzle completed, stats updated');
              } else if (isWeekly) {
                // Haftalık puzzle tamamlandı
                await gameStatsCubit.onWeeklyCompleted(elapsedSeconds);
                print('Weekly puzzle completed, stats updated');
              } else {
                // Normal level tamamlandı
                await gameStatsCubit.onLevelCompleted(level, elapsedSeconds);
                print('Normal level completed, stats updated');
                // LevelProgress için yıldızları da güncelle (map üzerindeki yıldızlar için)
                final levelProgressCubit = context.read<LevelProgressCubit>();
                await levelProgressCubit.onLevelCompleted(level, elapsedSeconds);
              }
              
              Navigator.of(context).pop();
              
              // MapScreen'e dön
              onBackToMenu();
              
              // Haritayı yenile
              await Future.delayed(Duration(milliseconds: 200));
              if (context.mounted) {
                context.router.replace(MapRoute(stage: stage));
              }
              
              print('=== SUCCESS DIALOG END ===');
            },
            child: Text(
              AppLocalizations.of(context)!.continueButton,
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  static String _getStarMessage(int starCount, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    switch (starCount) {
      case 3:
        return l10n.perfect3Stars;
      case 2:
        return l10n.great2Stars;
      case 1:
        return l10n.good1Star;
      default:
        return l10n.puzzleCompleted;
    }
  }

  // Yıldız hesaplama mantığı
  static int _calculateStars(int elapsedSeconds) {
    // Yeni kural:
    // <45 sn => 3 yıldız
    // 45..70 sn (70 dahil) => 2 yıldız
    // >70 sn => 1 yıldız
    if (elapsedSeconds < 45) return 3;
    if (elapsedSeconds <= 70) return 2;
    return 1;
  }

  // Ödül ikonu getir
  static IconData _getRewardIcon(String reward) {
    switch (reward) {
      case 'Hint':
        return Icons.lightbulb;
      case 'Check':
        return Icons.check_circle;
      case 'Undo':
        return Icons.undo;
      default:
        return Icons.card_giftcard;
    }
  }


  // Reklam izle ve ödülü al
  static Future<void> _watchAdAndClaimReward(BuildContext context, String reward, {bool isDaily = false, bool isWeekly = false}) async {
    // Reklam izleme simülasyonu
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Reklam izleniyor...',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    // 1.5 saniye reklam simülasyonu (daha hızlı)
    await Future.delayed(Duration(milliseconds: 1500));

    if (context.mounted) {
      Navigator.of(context).pop(); // Loading dialog'u kapat
      
      // Ödülü envantere ekle
      await _addRewardToInventory(context, reward, isDaily: isDaily, isWeekly: isWeekly);
      
      // Başarı mesajı göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reklam izlendi! $reward ödülü envanterinize eklendi!',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green.shade700,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      
      // Success dialog'u kapat
      Navigator.of(context).pop();
      
      // MapScreen'e dön
      context.router.navigate(MapRoute());
    }
  }

  // Ödülü envantere ekle
  static Future<void> _addRewardToInventory(BuildContext context, String reward, {bool isDaily = false, bool isWeekly = false}) async {
    try {
      final inventoryCubit = context.read<InventoryCubit>();
      
      switch (reward) {
        case 'Hint':
          await inventoryCubit.addHints(1);
          print('Daily reward added to inventory: 1 Hint');
          break;
        case 'Check':
          await inventoryCubit.addChecks(1);
          print('Daily reward added to inventory: 1 Check');
          break;
        case 'Undo':
          await inventoryCubit.addUndos(1);
          print('Daily reward added to inventory: 1 Undo');
          break;
      }
      
      // Ödül alındı olarak işaretle (günlük veya haftalık)
      if (isDaily) {
        await _markDailyRewardClaimed();
      } else if (isWeekly) {
        await _markWeeklyRewardClaimed();
      }
    } catch (e) {
      print('Error adding reward to inventory: $e');
    }
  }

  // Günlük ödül alınabilir mi kontrol et
  static Future<bool> _canClaimDailyReward() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = 'daily_reward_${today.year}_${today.month}_${today.day}';
      
      final claimed = prefs.getBool(todayKey) ?? false;
      return !claimed;
    } catch (e) {
      print('Error checking daily reward claim: $e');
      return true; // Hata durumunda ödül ver
    }
  }

  // Günlük ödül alındı olarak işaretle
  static Future<void> _markDailyRewardClaimed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = 'daily_reward_${today.year}_${today.month}_${today.day}';
      
      await prefs.setBool(todayKey, true);
      print('Daily reward marked as claimed for ${todayKey}');
    } catch (e) {
      print('Error marking daily reward as claimed: $e');
    }
  }

  // Haftalık ödül alınabilir mi kontrol et
  static Future<bool> _canClaimWeeklyReward() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      // Haftalık bulmaca için haftanın başlangıcını al (Pazartesi)
      final monday = now.subtract(Duration(days: (now.weekday + 6) % 7));
      final weekKey = 'weekly_reward_${monday.year}_${monday.month}_${monday.day}';
      
      final claimed = prefs.getBool(weekKey) ?? false;
      return !claimed;
    } catch (e) {
      print('Error checking weekly reward claim: $e');
      return true; // Hata durumunda ödül ver
    }
  }

  // Haftalık ödül alındı olarak işaretle
  static Future<void> _markWeeklyRewardClaimed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      // Haftalık bulmaca için haftanın başlangıcını al (Pazartesi)
      final monday = now.subtract(Duration(days: (now.weekday + 6) % 7));
      final weekKey = 'weekly_reward_${monday.year}_${monday.month}_${monday.day}';
      
      await prefs.setBool(weekKey, true);
      print('Weekly reward marked as claimed for ${weekKey}');
    } catch (e) {
      print('Error marking weekly reward as claimed: $e');
    }
  }
} 