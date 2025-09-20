import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/universe_config.dart';
import '../l10n/app_localizations.dart';

class UniverseSelector extends StatefulWidget {
  final int currentUniverseId;
  final Function(int) onUniverseSelected;

  const UniverseSelector({
    Key? key,
    required this.currentUniverseId,
    required this.onUniverseSelected,
  }) : super(key: key);

  @override
  State<UniverseSelector> createState() => _UniverseSelectorState();
}

class _UniverseSelectorState extends State<UniverseSelector> {
  
  Future<List<bool>> _getUniverseUnlockStatus() async {
    final List<bool> unlockStatus = [];
    
    for (int i = 1; i <= UniverseConfig.getUniverseCount(); i++) {
      final isUnlocked = await UniverseConfig.isUniverseUnlockedFromPrefs(i);
      unlockStatus.add(isUnlocked);
    }
    
    return unlockStatus;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.9;
    final dialogWidth = maxWidth > 400 ? 400.0 : maxWidth;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: dialogWidth,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Başlık
              Text(
                AppLocalizations.of(context)!.selectUniverse,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              
              // Evren listesi
              FutureBuilder<List<bool>>(
                future: _getUniverseUnlockStatus(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  final unlockStatus = snapshot.data!;
                  return Column(
                    children: UniverseConfig.getAllUniverses(context).asMap().entries.map((entry) {
                      final index = entry.key;
                      final universe = entry.value;
                      final universeId = index + 1; // Index + 1 = Universe ID
                      final isSelected = universeId == widget.currentUniverseId;
                      final isUnlocked = unlockStatus[index];
                
                      return _UniverseCard(
                        universe: universe,
                        universeId: universeId,
                        isSelected: isSelected,
                        isUnlocked: isUnlocked,
                        onTap: isUnlocked ? () {
                          Navigator.of(context).pop();
                          widget.onUniverseSelected(universeId);
                        } : null,
                      );
                    }).toList(),
                  );
                },
              ),
              
              const SizedBox(height: 10),
              
              // Kapat butonu
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  AppLocalizations.of(context)!.close,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 16,
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

class _UniverseCard extends StatelessWidget {
  final UniverseData universe;
  final int universeId;
  final bool isSelected;
  final bool isUnlocked;
  final VoidCallback? onTap;

  const _UniverseCard({
    required this.universe,
    required this.universeId,
    required this.isSelected,
    required this.isUnlocked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected 
                  ? Colors.amber 
                  : isUnlocked 
                    ? Colors.white.withOpacity(0.3)
                    : Colors.grey.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
              color: isUnlocked 
                ? (isSelected ? Colors.amber.withOpacity(0.1) : Colors.white.withOpacity(0.05))
                : Colors.grey.withOpacity(0.1),
            ),
            child: Row(
              children: [
                // Evren ikonu/önizleme
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: isUnlocked 
                      ? DecorationImage(
                          image: AssetImage(universe.backgroundImage),
                          fit: BoxFit.cover,
                        )
                      : null,
                    color: isUnlocked ? null : Colors.grey.withOpacity(0.3),
                  ),
                  child: !isUnlocked 
                    ? Icon(
                        Icons.lock,
                        color: Colors.grey.shade600,
                        size: 30,
                      )
                    : null,
                ),
                
                const SizedBox(width: 16),
                
                // Evren bilgileri
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              universe.name,
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isUnlocked ? Colors.white : Colors.grey.shade400,
                              ),
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle,
                              color: Colors.amber,
                              size: 20,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        universe.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: isUnlocked ? Colors.white70 : Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${universe.maxLevels} Level',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: isUnlocked ? Colors.white60 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Kilit durumu
                if (!isUnlocked)
                  Icon(
                    Icons.lock_outline,
                    color: Colors.grey.shade500,
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
