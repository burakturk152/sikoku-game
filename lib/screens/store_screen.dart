import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../store/store_cubit.dart';
import '../store/store_model.dart';
import '../inventory/inventory_cubit.dart';
import '../inventory/inventory_state.dart';
import '../theme/app_themes.dart';
import '../l10n/app_localizations.dart';

@RoutePage()
class StoreScreen extends StatefulWidget {
  const StoreScreen({Key? key}) : super(key: key);

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  @override
  Widget build(BuildContext context) {
    final pal = Theme.of(context).extension<AppPalette>()!;
    final l10n = AppLocalizations.of(context)!;
    
    return BlocProvider(
      create: (context) => StoreCubit(),
      child: Scaffold(
        backgroundColor: pal.puzzleBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: pal.counterTextColor),
            onPressed: () => context.router.pop(),
          ),
          title: Text(
            l10n.market,
            style: TextStyle(
              color: pal.counterTextColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<StoreCubit, StoreModel>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: pal.counterTextColor,
                ),
              );
            }

            if (state.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      state.error!,
                      style: TextStyle(
                        color: pal.counterTextColor,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // StoreCubit'i yeniden oluştur
                        context.read<StoreCubit>();
                      },
                      child: Text(l10n.back),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Günlük Reklam Ödülü
                  if (state.todayReward != null) ...[
                    _buildDailyRewardCard(context, state.todayReward!, pal, l10n),
                    SizedBox(height: 24),
                  ],

                  // Envanter Durumu
                  _buildInventoryStatus(context, pal, l10n),
                  SizedBox(height: 24),

                  // Paketler
                  _buildSectionTitle(l10n.packages, pal),
                  SizedBox(height: 12),
                  _buildPackagesGrid(context, state.items.where((item) => item.isPackage).toList(), pal, l10n),
                  SizedBox(height: 24),

                  // İpucu
                  _buildSectionTitle(l10n.hint, pal),
                  SizedBox(height: 12),
                  _buildItemsGrid(context, state.items.where((item) => item.type == 'hint' && !item.isPackage).toList(), pal, l10n),
                  SizedBox(height: 24),

                  // Geri Al
                  _buildSectionTitle(l10n.undo, pal),
                  SizedBox(height: 12),
                  _buildItemsGrid(context, state.items.where((item) => item.type == 'undo' && !item.isPackage).toList(), pal, l10n),
                  SizedBox(height: 24),

                  // Kontrol
                  _buildSectionTitle(l10n.control, pal),
                  SizedBox(height: 12),
                  _buildItemsGrid(context, state.items.where((item) => item.type == 'check' && !item.isPackage).toList(), pal, l10n),
                  SizedBox(height: 24),

                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getTypeName(String type, AppLocalizations l10n) {
    switch (type) {
      case 'hint': return l10n.hint;
      case 'undo': return l10n.undo;
      case 'check': return l10n.control;
      default: return l10n.dailyReward;
    }
  }

  String _getPackageName(String packageName, AppLocalizations l10n) {
    switch (packageName) {
      case 'Başlangıç Paketi': return '${l10n.package} 1';
      case 'Premium Paket': return '${l10n.package} 2';
      case 'Mega Paket': return '${l10n.package} 3';
      default: return packageName;
    }
  }

  String _getPackageDescription(String packageName, AppLocalizations l10n) {
    switch (packageName) {
      case 'Başlangıç Paketi': return '2 ${l10n.hint} + 2 ${l10n.undo} + 2 ${l10n.control}';
      case 'Premium Paket': return '5 ${l10n.hint} + 5 ${l10n.undo} + 5 ${l10n.control}';
      case 'Mega Paket': return '10 ${l10n.hint} + 10 ${l10n.undo} + 10 ${l10n.control}';
      default: return packageName;
    }
  }

  Widget _buildDailyRewardCard(BuildContext context, DailyReward reward, AppPalette pal, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade400, Colors.orange.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.card_giftcard,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dailyReward,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (reward.reward != null && !reward.isClaimed)
                      Text(
                        '${reward.reward!.quantity} ${_getTypeName(reward.reward!.type, l10n)} ${l10n.rewardClaimed}!',
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          if (reward.isClaimed)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Bugün alındı ✓',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            ElevatedButton.icon(
              onPressed: () => context.read<StoreCubit>().claimDailyReward(context),
              icon: Icon(Icons.play_arrow, color: Colors.amber),
              label: Text(
                l10n.watchAd,
                style: GoogleFonts.poppins(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInventoryStatus(BuildContext context, AppPalette pal, AppLocalizations l10n) {
    return BlocBuilder<InventoryCubit, InventoryState>(
      builder: (context, inventoryState) {
        final model = inventoryState.model;
        
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: pal.counterTextColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.inventory,
                style: GoogleFonts.poppins(
                  color: pal.counterTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: _buildInventoryItem(Icons.lightbulb, l10n.hint, '${model.hintCount}', Colors.amber),
                  ),
                  Expanded(
                    child: _buildInventoryItem(Icons.undo, l10n.undo, '${model.undoCount}', Colors.blue),
                  ),
                  Expanded(
                    child: _buildInventoryItem(Icons.check_circle, l10n.control, '${model.checkCount}', Colors.teal),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInventoryItem(IconData icon, String label, String count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 8,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          count,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, AppPalette pal) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        color: pal.counterTextColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPackagesGrid(BuildContext context, List<StoreItem> packages, AppPalette pal, AppLocalizations l10n) {
    return Column(
      children: packages.map((package) => Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: _buildPackageCard(context, package, pal, l10n),
      )).toList(),
    );
  }

  Widget _buildPackageCard(BuildContext context, StoreItem package, AppPalette pal, AppLocalizations l10n) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.12; // Ekran yüksekliğinin %12'si
    
    return Container(
      height: cardHeight.clamp(80.0, 120.0), // Min 80, max 120
      padding: EdgeInsets.all(screenHeight * 0.015), // Ekran yüksekliğinin %1.5'i
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade600, Colors.purple.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.card_giftcard,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
        Text(
          _getPackageName(package.name, l10n),
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: screenHeight * 0.018, // Ekran yüksekliğinin %1.8'i
            fontWeight: FontWeight.bold,
          ),
        ),
                SizedBox(height: 2),
                Text(
                  _getPackageDescription(package.name, l10n),
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: screenHeight * 0.013, // Ekran yüksekliğinin %1.3'ü
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '₺${package.price}',
                style: GoogleFonts.poppins(
                  color: Colors.amber,
                  fontSize: screenHeight * 0.02, // Ekran yüksekliğinin %2'si
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              ElevatedButton(
                onPressed: () => context.read<StoreCubit>().purchaseItem(package, context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  minimumSize: Size(0, screenHeight * 0.035), // Ekran yüksekliğinin %3.5'i
                ),
                child: Text(
                  l10n.buy,
                  style: GoogleFonts.poppins(
                    fontSize: screenHeight * 0.013, // Ekran yüksekliğinin %1.3'ü
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsGrid(BuildContext context, List<StoreItem> items, AppPalette pal, AppLocalizations l10n) {
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.15; // Ekran yüksekliğinin %15'i
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) => SizedBox(
        width: (MediaQuery.of(context).size.width - 56) / 2, // 16*2 padding + 12 spacing
        height: cardHeight.clamp(100.0, 140.0), // Min 100, max 140
        child: _buildItemCard(context, item, pal, l10n),
      )).toList(),
    );
  }

  Widget _buildItemCard(BuildContext context, StoreItem item, AppPalette pal, AppLocalizations l10n) {
    final color = _getTypeColor(item.type);
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      padding: EdgeInsets.all(screenHeight * 0.01), // Ekran yüksekliğinin %1'i
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            item.icon ?? '🎁',
            style: TextStyle(fontSize: screenHeight * 0.03), // Ekran yüksekliğinin %3'ü
          ),
          Text(
            item.name,
            style: GoogleFonts.poppins(
              color: pal.counterTextColor,
              fontSize: screenHeight * 0.014, // Ekran yüksekliğinin %1.4'ü
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '₺${item.price}',
            style: GoogleFonts.poppins(
              color: color,
              fontSize: screenHeight * 0.016, // Ekran yüksekliğinin %1.6'sı
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: () => context.read<StoreCubit>().purchaseItem(item, context),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: Size(0, screenHeight * 0.035), // Ekran yüksekliğinin %3.5'i
            ),
            child: Text(
              l10n.buy,
              style: GoogleFonts.poppins(
                fontSize: screenHeight * 0.013, // Ekran yüksekliğinin %1.3'ü
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'hint': return Colors.amber;
      case 'undo': return Colors.blue;
      case 'check': return Colors.teal;
      default: return Colors.grey;
    }
  }

}
