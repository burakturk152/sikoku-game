import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import '../settings/settings_model.dart';

class AudioGateway {
  static final AudioGateway _instance = AudioGateway._internal();
  factory AudioGateway() => _instance;
  AudioGateway._internal();

  double _currentVolume = 0.7;
  bool _musicOn = true;
  bool _sfxOn = true;
  bool _hapticOn = true;
  
  // Audio players
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  int _currentMusicIndex = 0;
  final List<String> _musicFiles = [
    'audio/background_music_1.mp3',
    'audio/background_music_2.mp3',
  ];

  // Bu fonksiyon, projenin gerçek ses motoru ile entegre edilecek tek nokta
  Future<void> apply(SettingsModel m) async {
    _musicOn = m.musicOn;
    _sfxOn = m.sfxOn;
    _hapticOn = m.hapticOn;
    _currentVolume = m.volume;

    // Müzik durumunu güncelle
    if (_musicOn) {
      await startBackgroundMusic();
    } else {
      await stopBackgroundMusic();
    }
    
    // Ses seviyesini güncelle
    await _musicPlayer.setVolume(_currentVolume);
  }
  
  // Arka plan müziğini başlat
  Future<void> startBackgroundMusic() async {
    if (!_musicOn) return;
    
    try {
      await _musicPlayer.setReleaseMode(ReleaseMode.loop);
      await _playNextMusic();
    } catch (e) {
      print('Müzik başlatma hatası: $e');
    }
  }
  
  // Arka plan müziğini durdur
  Future<void> stopBackgroundMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (e) {
      print('Müzik durdurma hatası: $e');
    }
  }
  
  // Sıradaki müziği çal
  Future<void> _playNextMusic() async {
    if (!_musicOn) return;
    
    try {
      final musicFile = _musicFiles[_currentMusicIndex];
      await _musicPlayer.play(AssetSource(musicFile));
      
      // Müzik bittiğinde sıradakini çal
      _musicPlayer.onPlayerComplete.listen((_) {
        _currentMusicIndex = (_currentMusicIndex + 1) % _musicFiles.length;
        _playNextMusic();
      });
    } catch (e) {
      print('Müzik çalma hatası: $e');
    }
  }

  // Hücre tıklama ses efekti
  Future<void> playCellClickSound() async {
    if (!_sfxOn) return;
    
    try {
      await _sfxPlayer.stop(); // Önceki sesi durdur
      await _sfxPlayer.play(AssetSource('audio/click-345983.mp3'));
    } catch (e) {
      print('Hücre tıklama ses efekti hatası: $e');
    }
  }

  // Örnek: UI içinden çağrılıp dokunma haptics tetiklemek için
  Future<void> lightHaptic() async {
    if (_hapticOn) {
      await HapticFeedback.lightImpact();
    }
  }

  bool get musicOn => _musicOn;
  bool get sfxOn => _sfxOn;
  double get volume => _currentVolume;
  bool get hapticOn => _hapticOn;
  
  // Dispose method
  void dispose() {
    _musicPlayer.dispose();
    _sfxPlayer.dispose();
  }
}
