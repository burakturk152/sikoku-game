import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileState extends Equatable {
  final String selectedAvatarPath;
  final String? pendingAvatarPath; // Tıklanan ama henüz onaylanmamış avatar
  final int completedDailyCount;
  final int completedWeeklyCount;
  final int totalStars;
  final int bestTimeSeconds;
  final int flawlessCount;
  final Set<String> achievedBadges; // badge ids
  final String languageCode; // 'tr' | 'en'

  const ProfileState({
    required this.selectedAvatarPath,
    this.pendingAvatarPath,
    required this.completedDailyCount,
    required this.completedWeeklyCount,
    required this.totalStars,
    required this.bestTimeSeconds,
    required this.flawlessCount,
    required this.achievedBadges,
    required this.languageCode,
  });

  factory ProfileState.initial() => ProfileState(
        selectedAvatarPath: 'assets/avatar/avatar1.png',
        pendingAvatarPath: null,
        completedDailyCount: 0,
        completedWeeklyCount: 0,
        totalStars: 0,
        bestTimeSeconds: 9999,
        flawlessCount: 0,
        achievedBadges: <String>{}.toSet(),
        languageCode: 'tr',
      );

  ProfileState copyWith({
    String? selectedAvatarPath,
    String? pendingAvatarPath,
    int? completedDailyCount,
    int? completedWeeklyCount,
    int? totalStars,
    int? bestTimeSeconds,
    int? flawlessCount,
    Set<String>? achievedBadges,
    String? languageCode,
  }) {
    return ProfileState(
      selectedAvatarPath: selectedAvatarPath ?? this.selectedAvatarPath,
      pendingAvatarPath: pendingAvatarPath ?? this.pendingAvatarPath,
      completedDailyCount: completedDailyCount ?? this.completedDailyCount,
      completedWeeklyCount: completedWeeklyCount ?? this.completedWeeklyCount,
      totalStars: totalStars ?? this.totalStars,
      bestTimeSeconds: bestTimeSeconds ?? this.bestTimeSeconds,
      flawlessCount: flawlessCount ?? this.flawlessCount,
      achievedBadges: achievedBadges ?? this.achievedBadges,
      languageCode: languageCode ?? this.languageCode,
    );
  }

  @override
  List<Object?> get props => [
        selectedAvatarPath,
        pendingAvatarPath,
        completedDailyCount,
        completedWeeklyCount,
        totalStars,
        bestTimeSeconds,
        flawlessCount,
        achievedBadges,
        languageCode,
      ];
}

class ProfileCubit extends Cubit<ProfileState> {
  static const String _avatarPathKey = 'profile.avatarPath';
  
  ProfileCubit() : super(ProfileState.initial()) {
    _loadAvatarPath();
  }

  Future<void> _loadAvatarPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPath = prefs.getString(_avatarPathKey);
      if (savedPath != null) {
        emit(state.copyWith(selectedAvatarPath: savedPath));
      }
    } catch (e) {
      // Hata durumunda default avatar kullan
    }
  }

  // Avatar tıklama - pending state'e geçici olarak kaydet
  void setPendingAvatar(String avatarPath) {
    emit(state.copyWith(pendingAvatarPath: avatarPath));
  }

  // Pending avatar'ı temizle (iptal durumu)
  void clearPendingAvatar() {
    emit(state.copyWith(pendingAvatarPath: null));
  }

  // Avatar seçimini onayla ve kalıcı olarak kaydet
  Future<void> confirmAvatarSelection() async {
    if (state.pendingAvatarPath == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_avatarPathKey, state.pendingAvatarPath!);
      emit(state.copyWith(
        selectedAvatarPath: state.pendingAvatarPath!,
        pendingAvatarPath: null,
      ));
    } catch (e) {
      // Hata durumunda sadece state'i güncelle
      emit(state.copyWith(
        selectedAvatarPath: state.pendingAvatarPath!,
        pendingAvatarPath: null,
      ));
    }
  }

  // GameStatsCubit'ten istatistikleri güncelle
  void updateStatsFromGameStats({
    required int dailyCompleted,
    required int weeklyCompleted,
    required int totalStars,
    required int bestTimeSeconds,
    required int flawlessCount,
  }) {
    emit(state.copyWith(
      completedDailyCount: dailyCompleted,
      completedWeeklyCount: weeklyCompleted,
      totalStars: totalStars,
      bestTimeSeconds: bestTimeSeconds,
      flawlessCount: flawlessCount,
    ));
  }

  void setLanguage(String code) {
    emit(state.copyWith(languageCode: code));
  }

  // Mock istatistik güncellemeleri (artık kullanılmıyor, GameStatsCubit kullanılıyor)
  void incrementDaily() {
    emit(state.copyWith(completedDailyCount: state.completedDailyCount + 1));
  }

  void incrementWeekly() {
    emit(state.copyWith(completedWeeklyCount: state.completedWeeklyCount + 1));
  }

  void addStars(int stars) {
    emit(state.copyWith(totalStars: state.totalStars + stars));
  }

  void updateBestTime(int seconds) {
    if (seconds < state.bestTimeSeconds) {
      emit(state.copyWith(bestTimeSeconds: seconds));
    }
  }

  void incrementFlawless() {
    emit(state.copyWith(flawlessCount: state.flawlessCount + 1));
  }

  void achieveBadge(String id) {
    final updated = Set<String>.from(state.achievedBadges)..add(id);
    emit(state.copyWith(achievedBadges: updated));
  }
}


