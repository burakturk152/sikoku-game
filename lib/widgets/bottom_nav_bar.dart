import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_themes.dart';
import '../bloc/profile_cubit.dart';
import '../l10n/app_localizations.dart';

class MapBottomBar extends StatelessWidget {
  final List<Widget>? children;
  final MainAxisAlignment mainAxisAlignment;
  final VoidCallback? onTapDaily;
  final VoidCallback? onTapWeekly;
  final VoidCallback? onTapProfile;
  final VoidCallback? onTapSettings;
  final VoidCallback? onTapMarket;

  const MapBottomBar({
    super.key,
    this.children,
    this.mainAxisAlignment = MainAxisAlignment.spaceAround,
    this.onTapDaily,
    this.onTapWeekly,
    this.onTapProfile,
    this.onTapSettings,
    this.onTapMarket,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double iconSize = (size.width * 0.09).clamp(28.0, 46.0).toDouble();
    final pal = Theme.of(context).extension<AppPalette>()!;
    final l10n = AppLocalizations.of(context)!;
    
    return SafeArea(
      child: Container(
        width: double.infinity,
        height: iconSize + 4 + 14 + 8, // icon + spacing(4) + text(14) + vertical padding total(8)
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        decoration: BoxDecoration(
          color: pal.bottomBarBackground,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive spacing to avoid overflow on small widths
            final double separatorWidth = (constraints.maxWidth < 480) ? 8 : 16;
            final Widget sep = Padding(
              padding: EdgeInsets.symmetric(horizontal: separatorWidth / 2),
              child: Text('|', style: TextStyle(color: pal.bottomBarText.withOpacity(0.7))),
            );
            final bool isTight = constraints.maxWidth < 380;
            final mainAxis = isTight ? MainAxisAlignment.spaceBetween : mainAxisAlignment;
            final Widget tightSep = isTight
                ? SizedBox(width: 4, child: Center(child: Text('|', style: TextStyle(color: pal.bottomBarText.withOpacity(0.7)))))
                : sep;

                         final List<Widget> defaultChildren = [
               _ImageNavItem(
                 assetPath: 'assets/images/daily_button.png',
                 label: l10n.daily,
                 onTap: onTapDaily,
                 textColor: pal.bottomBarText,
                 iconSize: iconSize,
               ),
               isTight ? tightSep : sep,
               _ImageNavItem(
                 assetPath: 'assets/images/weekly_button.png',
                 label: l10n.weekly,
                 onTap: onTapWeekly,
                 textColor: pal.bottomBarText,
                 iconSize: iconSize,
               ),
               isTight ? tightSep : sep,
               BlocBuilder<ProfileCubit, ProfileState>(
                 builder: (context, profileState) {
                   return _ProfileNavItem(
                     avatarPath: profileState.selectedAvatarPath,
                     label: l10n.profile,
                     onTap: onTapProfile,
                     textColor: pal.bottomBarText,
                     iconSize: iconSize,
                   );
                 },
               ),
               isTight ? tightSep : sep,
               _ImageNavItem(
                 assetPath: 'assets/images/settings_button.png',
                 label: l10n.settings,
                 onTap: onTapSettings,
                 textColor: pal.bottomBarText,
                 iconSize: iconSize,
               ),
               isTight ? tightSep : sep,
               _ImageNavItem(
                 assetPath: 'assets/images/market_button.png',
                 label: l10n.market,
                 onTap: onTapMarket,
                 textColor: pal.bottomBarText,
                 iconSize: iconSize,
               ),
             ];

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Row(
                  mainAxisAlignment: (children?.isNotEmpty ?? false) ? mainAxisAlignment : mainAxis,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (children?.isNotEmpty ?? false) ...children! else ...defaultChildren,
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SimpleNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color textColor;
  final double iconSize;
  
  const _SimpleNavItem({
    required this.icon,
    required this.label,
    this.onTap,
    required this.textColor,
    required this.iconSize,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Icon(
            icon,
            size: iconSize,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: textColor,
            fontWeight: FontWeight.w500,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _ImageNavItem extends StatelessWidget {
  final String assetPath;
  final String label;
  final VoidCallback? onTap;
  final Color textColor;
  final double iconSize;
  
  const _ImageNavItem({
    required this.assetPath,
    required this.label,
    this.onTap,
    required this.textColor,
    required this.iconSize,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Image.asset(
            assetPath,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: textColor,
            fontWeight: FontWeight.w500,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}

class _ProfileNavItem extends StatelessWidget {
  final String avatarPath;
  final String label;
  final VoidCallback? onTap;
  final Color textColor;
  final double iconSize;
  
  const _ProfileNavItem({
    required this.avatarPath,
    required this.label,
    this.onTap,
    required this.textColor,
    required this.iconSize,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: iconSize,
            height: iconSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: textColor, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                avatarPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) {
                  return Icon(
                    Icons.person,
                    size: iconSize * 0.6,
                    color: textColor,
                  );
                },
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: textColor,
            fontWeight: FontWeight.w500,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}


