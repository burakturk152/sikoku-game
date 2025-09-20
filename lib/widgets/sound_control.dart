import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/app_themes.dart';
import '../audio/audio_gateway.dart';
import '../settings/settings_cubit.dart';
import '../settings/settings_state.dart';

class SoundControl extends StatefulWidget {
  final double? size;
  final Color? color;
  final EdgeInsets? padding;

  const SoundControl({
    Key? key,
    this.size,
    this.color,
    this.padding,
  }) : super(key: key);

  @override
  State<SoundControl> createState() => _SoundControlState();
}

class _SoundControlState extends State<SoundControl> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final isSoundOn = settingsState.model.musicOn && settingsState.model.sfxOn;
        
        return _buildSoundControl(context, isSoundOn);
      },
    );
  }

  Future<void> _toggleSound() async {
    final settingsCubit = context.read<SettingsCubit>();
    
    // Hem müzik hem de SFX'i aynı anda aç/kapat
    final currentMusic = settingsCubit.state.model.musicOn;
    final currentSfx = settingsCubit.state.model.sfxOn;
    
    // Eğer ikisi de açıksa, ikisini de kapat
    // Eğer ikisi de kapalıysa, ikisini de aç
    // Eğer biri açık biri kapalıysa, ikisini de aç
    if (currentMusic && currentSfx) {
      // İkisi de açık -> ikisini de kapat
      await settingsCubit.toggleMusic();
      await settingsCubit.toggleSfx();
    } else {
      // En az biri kapalı -> ikisini de aç
      if (!currentMusic) await settingsCubit.toggleMusic();
      if (!currentSfx) await settingsCubit.toggleSfx();
    }
  }

  Widget _buildSoundControl(BuildContext context, bool isSoundOn) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final pal = Theme.of(context).extension<AppPalette>();
    
    // Tema renklerini kullan
    final iconColor = widget.color ?? (pal?.counterTextColor ?? Colors.white.withOpacity(0.7));
    final backgroundColor = pal != null 
        ? (Theme.of(context).brightness == Brightness.light 
            ? Colors.white.withOpacity(0.8) 
            : Colors.black.withOpacity(0.3))
        : Colors.black.withOpacity(0.3);
    
    return Padding(
      padding: widget.padding ?? EdgeInsets.only(
        bottom: screenHeight * 0.04,
        right: screenWidth * 0.04,
      ),
      child: IconButton(
        icon: Icon(
          isSoundOn ? Icons.volume_up_rounded : Icons.volume_off_rounded,
          color: iconColor,
          size: widget.size ?? screenHeight * 0.035,
        ),
        onPressed: _toggleSound,
        style: IconButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
} 