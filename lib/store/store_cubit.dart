import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';

import 'store_model.dart';
import '../inventory/inventory_cubit.dart';
import '../inventory/inventory_state.dart';

class StoreCubit extends Cubit<StoreModel> {
  StoreCubit() : super(StoreModel(items: _getDefaultItems())) {
    _loadDailyReward();
  }

  static List<StoreItem> _getDefaultItems() {
    return [
      // Paketler
      StoreItem(
        id: 'starter_pack',
        name: 'Başlangıç Paketi',
        description: '2 İpucu + 2 Geri Al + 2 Kontrol',
        price: 15,
        type: 'package',
        quantity: 1,
        isPackage: true,
        packageItems: [
          StoreItem(id: 'hint_2', name: 'İpucu', type: 'hint', quantity: 2, price: 0, description: ''),
          StoreItem(id: 'undo_2', name: 'Geri Al', type: 'undo', quantity: 2, price: 0, description: ''),
          StoreItem(id: 'check_2', name: 'Kontrol', type: 'check', quantity: 2, price: 0, description: ''),
        ],
      ),
      StoreItem(
        id: 'premium_pack',
        name: 'Premium Paket',
        description: '5 İpucu + 5 Geri Al + 5 Kontrol',
        price: 35,
        type: 'package',
        quantity: 1,
        isPackage: true,
        packageItems: [
          StoreItem(id: 'hint_5', name: 'İpucu', type: 'hint', quantity: 5, price: 0, description: ''),
          StoreItem(id: 'undo_5', name: 'Geri Al', type: 'undo', quantity: 5, price: 0, description: ''),
          StoreItem(id: 'check_5', name: 'Kontrol', type: 'check', quantity: 5, price: 0, description: ''),
        ],
      ),
      StoreItem(
        id: 'mega_pack',
        name: 'Mega Paket',
        description: '10 İpucu + 10 Geri Al + 10 Kontrol',
        price: 65,
        type: 'package',
        quantity: 1,
        isPackage: true,
        packageItems: [
          StoreItem(id: 'hint_10', name: 'İpucu', type: 'hint', quantity: 10, price: 0, description: ''),
          StoreItem(id: 'undo_10', name: 'Geri Al', type: 'undo', quantity: 10, price: 0, description: ''),
          StoreItem(id: 'check_10', name: 'Kontrol', type: 'check', quantity: 10, price: 0, description: ''),
        ],
      ),

      // Tek tek alımlar - İpucu
      StoreItem(
        id: 'hint_1',
        name: '1 Hint',
        description: '1 hint',
        price: 3,
        type: 'hint',
        quantity: 1,
        icon: '💡',
      ),
      StoreItem(
        id: 'hint_3',
        name: '3 Hints',
        description: '3 hints',
        price: 8,
        type: 'hint',
        quantity: 3,
        icon: '💡',
      ),
      StoreItem(
        id: 'hint_5',
        name: '5 Hints',
        description: '5 hints',
        price: 12,
        type: 'hint',
        quantity: 5,
        icon: '💡',
      ),
      StoreItem(
        id: 'hint_10',
        name: '10 Hints',
        description: '10 hints',
        price: 22,
        type: 'hint',
        quantity: 10,
        icon: '💡',
      ),
      StoreItem(
        id: 'hint_50',
        name: '50 Hints',
        description: '50 hints',
        price: 95,
        type: 'hint',
        quantity: 50,
        icon: '💡',
      ),
      StoreItem(
        id: 'hint_100',
        name: '100 Hints',
        description: '100 hints',
        price: 180,
        type: 'hint',
        quantity: 100,
        icon: '💡',
      ),

      // Tek tek alımlar - Geri Al
      StoreItem(
        id: 'undo_1',
        name: '1 Undo',
        description: '1 undo',
        price: 3,
        type: 'undo',
        quantity: 1,
        icon: '↶',
      ),
      StoreItem(
        id: 'undo_3',
        name: '3 Undos',
        description: '3 undos',
        price: 8,
        type: 'undo',
        quantity: 3,
        icon: '↶',
      ),
      StoreItem(
        id: 'undo_5',
        name: '5 Undos',
        description: '5 undos',
        price: 12,
        type: 'undo',
        quantity: 5,
        icon: '↶',
      ),
      StoreItem(
        id: 'undo_10',
        name: '10 Undos',
        description: '10 undos',
        price: 22,
        type: 'undo',
        quantity: 10,
        icon: '↶',
      ),
      StoreItem(
        id: 'undo_50',
        name: '50 Undos',
        description: '50 undos',
        price: 95,
        type: 'undo',
        quantity: 50,
        icon: '↶',
      ),
      StoreItem(
        id: 'undo_100',
        name: '100 Undos',
        description: '100 undos',
        price: 180,
        type: 'undo',
        quantity: 100,
        icon: '↶',
      ),

      // Tek tek alımlar - Kontrol
      StoreItem(
        id: 'check_1',
        name: '1 Check',
        description: '1 check',
        price: 3,
        type: 'check',
        quantity: 1,
        icon: '✓',
      ),
      StoreItem(
        id: 'check_3',
        name: '3 Checks',
        description: '3 checks',
        price: 8,
        type: 'check',
        quantity: 3,
        icon: '✓',
      ),
      StoreItem(
        id: 'check_5',
        name: '5 Checks',
        description: '5 checks',
        price: 12,
        type: 'check',
        quantity: 5,
        icon: '✓',
      ),
      StoreItem(
        id: 'check_10',
        name: '10 Checks',
        description: '10 checks',
        price: 22,
        type: 'check',
        quantity: 10,
        icon: '✓',
      ),
      StoreItem(
        id: 'check_50',
        name: '50 Checks',
        description: '50 checks',
        price: 95,
        type: 'check',
        quantity: 50,
        icon: '✓',
      ),
      StoreItem(
        id: 'check_100',
        name: '100 Checks',
        description: '100 checks',
        price: 180,
        type: 'check',
        quantity: 100,
        icon: '✓',
      ),

    ];
  }

  Future<void> _loadDailyReward() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';
      
      final claimedToday = prefs.getBool('daily_reward_$todayKey') ?? false;
      
      if (!claimedToday) {
        // Rastgele ödül oluştur
        final random = Random();
        final rewardTypes = ['hint', 'undo', 'check'];
        final rewardType = rewardTypes[random.nextInt(rewardTypes.length)];
        final rewardQuantity = random.nextInt(3) + 1; // 1-3 arası
        
        final reward = StoreItem(
          id: 'daily_${rewardType}_$rewardQuantity',
          name: '$rewardQuantity ${_getTypeName(rewardType)}',
          description: 'Günlük reklam ödülü',
          price: 0,
          type: rewardType,
          quantity: rewardQuantity,
          icon: _getTypeIcon(rewardType),
        );
        
        emit(state.copyWith(todayReward: DailyReward(
          date: today,
          isClaimed: false,
          reward: reward,
        )));
      } else {
        emit(state.copyWith(todayReward: DailyReward(
          date: today,
          isClaimed: true,
        )));
      }
    } catch (e) {
      emit(state.copyWith(error: 'Günlük ödül yüklenemedi: $e'));
    }
  }

  String _getTypeName(String type) {
    switch (type) {
      case 'hint': return 'İpucu';
      case 'undo': return 'Geri Al';
      case 'check': return 'Kontrol';
      default: return 'Ödül';
    }
  }

  String _getTypeIcon(String type) {
    switch (type) {
      case 'hint': return '💡';
      case 'undo': return '↶';
      case 'check': return '✓';
      default: return '🎁';
    }
  }

  Future<void> claimDailyReward(BuildContext context) async {
    if (state.todayReward?.isClaimed == true) return;
    
    try {
      emit(state.copyWith(isLoading: true));
      
      // Reklam izleme simülasyonu (2 saniye)
      await Future.delayed(Duration(seconds: 2));
      
      // Ödülü ver
      final reward = state.todayReward!.reward!;
      final inventoryCubit = context.read<InventoryCubit>();
      
      switch (reward.type) {
        case 'hint':
          await inventoryCubit.addHints(reward.quantity);
          break;
        case 'undo':
          await inventoryCubit.addUndos(reward.quantity);
          break;
        case 'check':
          await inventoryCubit.addChecks(reward.quantity);
          break;
      }
      
      // Günlük ödülü işaretle
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now();
      final todayKey = '${today.year}-${today.month}-${today.day}';
      await prefs.setBool('daily_reward_$todayKey', true);
      
      emit(state.copyWith(
        isLoading: false,
        todayReward: state.todayReward!.copyWith(isClaimed: true),
      ));
      
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Ödül alınamadı: $e',
      ));
    }
  }

  Future<void> purchaseItem(StoreItem item, BuildContext context) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      // Satın alma simülasyonu (1 saniye)
      await Future.delayed(Duration(seconds: 1));
      
      final inventoryCubit = context.read<InventoryCubit>();
      
      if (item.isPackage && item.packageItems != null) {
        // Paket satın alma
        for (final packageItem in item.packageItems!) {
          switch (packageItem.type) {
            case 'hint':
              await inventoryCubit.addHints(packageItem.quantity);
              break;
            case 'undo':
              await inventoryCubit.addUndos(packageItem.quantity);
              break;
          case 'check':
            await inventoryCubit.addChecks(packageItem.quantity);
            break;
          }
        }
      } else {
        // Tek ürün satın alma
        switch (item.type) {
          case 'hint':
            await inventoryCubit.addHints(item.quantity);
            break;
          case 'undo':
            await inventoryCubit.addUndos(item.quantity);
            break;
          case 'check':
            await inventoryCubit.addChecks(item.quantity);
            break;
        }
      }
      
      emit(state.copyWith(isLoading: false));
      
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Satın alma başarısız: $e',
      ));
    }
  }

  Future<void> resetDailyRewards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Tüm günlük ödül kayıtlarını sil
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('daily_reward_')) {
          await prefs.remove(key);
        }
      }
      
      // Yeni günlük ödül yükle
      await _loadDailyReward();
      
    } catch (e) {
      emit(state.copyWith(error: 'Günlük ödüller sıfırlanamadı: $e'));
    }
  }
}
