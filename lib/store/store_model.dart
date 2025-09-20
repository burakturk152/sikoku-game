class StoreItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String type; // 'hint', 'undo', 'check', 'time', 'package'
  final int quantity;
  final String? icon;
  final bool isPackage;
  final List<StoreItem>? packageItems; // Paket içeriği

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.quantity,
    this.icon,
    this.isPackage = false,
    this.packageItems,
  });

  StoreItem copyWith({
    String? id,
    String? name,
    String? description,
    int? price,
    String? type,
    int? quantity,
    String? icon,
    bool? isPackage,
    List<StoreItem>? packageItems,
  }) {
    return StoreItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      icon: icon ?? this.icon,
      isPackage: isPackage ?? this.isPackage,
      packageItems: packageItems ?? this.packageItems,
    );
  }
}

class DailyReward {
  final DateTime date;
  final bool isClaimed;
  final StoreItem? reward;

  const DailyReward({
    required this.date,
    required this.isClaimed,
    this.reward,
  });

  DailyReward copyWith({
    DateTime? date,
    bool? isClaimed,
    StoreItem? reward,
  }) {
    return DailyReward(
      date: date ?? this.date,
      isClaimed: isClaimed ?? this.isClaimed,
      reward: reward ?? this.reward,
    );
  }
}

class StoreModel {
  final List<StoreItem> items;
  final DailyReward? todayReward;
  final bool isLoading;
  final String? error;

  const StoreModel({
    required this.items,
    this.todayReward,
    this.isLoading = false,
    this.error,
  });

  StoreModel copyWith({
    List<StoreItem>? items,
    DailyReward? todayReward,
    bool? isLoading,
    String? error,
  }) {
    return StoreModel(
      items: items ?? this.items,
      todayReward: todayReward ?? this.todayReward,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
