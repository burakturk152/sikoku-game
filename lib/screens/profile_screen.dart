import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/profile_cubit.dart';
import '../bloc/game_stats_cubit.dart';
import '../l10n/app_localizations.dart';

@RoutePage()
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfileView();
  }
}

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final gridCrossAxisCount = size.width < 600 ? 3 : 4;
    // 5 avatar tanımı
    final avatarAssets = [
      'assets/avatar/avatar1.png',
      'assets/avatar/avatar2.png', 
      'assets/avatar/avatar3.png',
      'assets/avatar/avatar4.png',
      'assets/avatar/avatar5.png',
    ];
    
    // Kilitli avatarlar
    final lockedAvatars = {'assets/avatar/avatar4.png', 'assets/avatar/avatar5.png'};

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: theme.appBarTheme.backgroundColor,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          return BlocBuilder<GameStatsCubit, GameStatsState>(
            builder: (context, gameStatsState) {
              final profileCubit = context.read<ProfileCubit>();

              // GameStats'ten istatistikleri ProfileCubit'e senkronize et
              WidgetsBinding.instance.addPostFrameCallback((_) {
                profileCubit.updateStatsFromGameStats(
                  dailyCompleted: gameStatsState.dailyCompleted,
                  weeklyCompleted: gameStatsState.weeklyCompleted,
                  totalStars: gameStatsState.totalStars,
                  bestTimeSeconds: gameStatsState.fastestTime,
                  flawlessCount: gameStatsState.perfectPuzzles,
                );
              });

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar Seçimi
                    Card(
                      color: theme.cardColor.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Avatar Seç',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            GridView.builder(
                              itemCount: avatarAssets.length,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridCrossAxisCount,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                              itemBuilder: (context, index) {
                                final asset = avatarAssets[index];
                                final isLocked = lockedAvatars.contains(asset);
                                final isSelected = profileState.selectedAvatarPath == asset;
                                final isPending = profileState.pendingAvatarPath == asset;
                                
                                return _AvatarTile(
                                  assetPath: asset,
                                  isLocked: isLocked,
                                  isSelected: isSelected,
                                  isPending: isPending,
                                  onTap: () => _handleAvatarTap(context, profileCubit, asset, isLocked),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // İstatistikler
                    Card(
                      color: theme.cardColor.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'İstatistikler',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                                        _StatCard(title: 'Günlük', value: gameStatsState.dailyCompleted.toString()),
                        _StatCard(title: 'Haftalık', value: gameStatsState.weeklyCompleted.toString()),
                        _StatCard(title: 'Toplam Yıldız', value: gameStatsState.totalStars.toString()),
                        _StatCard(title: 'En Hızlı', value: _formatTime(gameStatsState.fastestTime)),
                        _StatCard(title: 'Hatasız', value: gameStatsState.perfectPuzzles.toString()),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Başarımlar
                    Card(
                      color: theme.cardColor.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Başarımlar',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                                            _BadgeChip(label: AppLocalizations.of(context)!.firstDailyPuzzle, unlocked: profileState.achievedBadges.contains('first_daily')),
                            _BadgeChip(label: AppLocalizations.of(context)!.sevenDaysInARow, unlocked: profileState.achievedBadges.contains('streak_7')),
                            _BadgeChip(label: AppLocalizations.of(context)!.hundredPuzzles, unlocked: profileState.achievedBadges.contains('complete_100')),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bağlantılar
                    Card(
                      color: theme.cardColor.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hesap Bağlantıları',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () {}, 
                                  icon: const Icon(Icons.g_mobiledata), 
                                  label: Text('Google')
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {}, 
                                  icon: const Icon(Icons.apple), 
                                  label: Text('Apple')
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {}, 
                                  icon: const Icon(Icons.facebook), 
                                  label: Text('Facebook')
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _handleAvatarTap(BuildContext context, ProfileCubit cubit, String avatarPath, bool isLocked) {
    if (isLocked) {
      _showAvatarLockedDialog(context, avatarPath);
    } else {
      cubit.setPendingAvatar(avatarPath);
      _showAvatarConfirmDialog(context, cubit, avatarPath);
    }
  }

  void _showAvatarConfirmDialog(BuildContext context, ProfileCubit cubit, String avatarPath) {
    final theme = Theme.of(context);

    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text('Avatarı değiştir?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                avatarPath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16),
            Text('Bu avatarı kullanmak istiyor musun?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              cubit.clearPendingAvatar();
              Navigator.of(context).pop();
            },
            child: Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () async {
              await cubit.confirmAvatarSelection();
              Navigator.of(context).pop();
              
              // SnackBar göster
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Avatar güncellendi'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Text('Onay'),
          ),
        ],
      ),
    );
  }

  void _showAvatarLockedDialog(BuildContext context, String avatarPath) {
    final theme = Theme.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text('Kilitli Avatar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix([
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0.2126, 0.7152, 0.0722, 0, 0,
                  0, 0, 0, 1, 0,
                ]),
                child: Image.asset(
                  avatarPath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Bu avatar kilitli. Açmak için satın al.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Vazgeç'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Satın alma akışı buraya bağlanacak
            },
            child: Text('Satın Al'),
          ),
        ],
      ),
    );
  }

  String _formatTime(int seconds) {
    if (seconds >= 9999) return '-';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

class _AvatarTile extends StatelessWidget {
  final String assetPath;
  final bool isLocked;
  final bool isSelected;
  final bool isPending;
  final VoidCallback onTap;

  const _AvatarTile({
    required this.assetPath,
    required this.isLocked,
    required this.isSelected,
    required this.isPending,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isSelected 
          ? Border.all(
              color: theme.colorScheme.primary,
              width: 2,
            )
          : isPending
            ? Border.all(
                color: theme.colorScheme.secondary,
                width: 2,
              )
            : null,
        boxShadow: isSelected 
          ? [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ]
          : isPending
            ? [
                BoxShadow(
                  color: theme.colorScheme.secondary.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: ColorFiltered(
                  colorFilter: isLocked 
                    ? const ColorFilter.matrix([
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0.2126, 0.7152, 0.0722, 0, 0,
                        0, 0, 0, 1, 0,
                      ])
                    : const ColorFilter.mode(Colors.transparent, BlendMode.srcOver),
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stack) {
                      return Container(
                        color: Colors.grey.withOpacity(0.2),
                        child: const Icon(Icons.person, color: Colors.white70),
                      );
                    },
                  ),
                ),
              ),
              if (isLocked)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  
  const _StatCard({required this.title, required this.value});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title, 
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value, 
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final bool unlocked;
  
  const _BadgeChip({required this.label, required this.unlocked});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Chip(
      backgroundColor: unlocked 
        ? theme.colorScheme.primary.withOpacity(0.2)
        : theme.colorScheme.surface.withOpacity(0.1),
      avatar: Icon(
        unlocked ? Icons.emoji_events : Icons.lock_outline,
        size: 16,
        color: unlocked ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.5),
      ),
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: unlocked 
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface.withOpacity(0.7),
        ),
      ),
    );
  }
}


