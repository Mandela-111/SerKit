import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manager for all game audio including sound effects and music
class AudioManager {
  // Singleton instance
  static final AudioManager _instance = AudioManager._internal();

  factory AudioManager() => _instance;

  AudioManager._internal();

  // Audio players
  final AudioPlayer _musicPlayer = AudioPlayer();
  final AudioPlayer _effectPlayer = AudioPlayer();
  
  // Settings
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _soundVolume = 0.8;
  double _musicVolume = 0.6;
  
  // Sound effects paths
  final Map<String, String> _soundEffects = {
    'click': 'audio/click.mp3',
    'connect': 'audio/connect.mp3',
    'disconnect': 'audio/disconnect.mp3',
    'win': 'audio/win.mp3',
    'error': 'audio/error.mp3',
  };
  
  // Background music paths
  final Map<String, String> _backgroundMusic = {
    'menu': 'audio/menu_music.mp3',
    'game': 'audio/game_music.mp3',
  };
  
  /// Initialize the audio manager
  Future<void> init() async {
    await loadSettings();
    
    // Set up music player
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(_musicVolume);
    
    // Set up effect player
    await _effectPlayer.setVolume(_soundVolume);
  }
  
  /// Load audio settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _soundEnabled = prefs.getBool('soundEnabled') ?? true;
      _musicEnabled = prefs.getBool('musicEnabled') ?? true;
      _soundVolume = prefs.getDouble('soundVolume') ?? 0.8;
      _musicVolume = prefs.getDouble('musicVolume') ?? 0.6;
      
      await _effectPlayer.setVolume(_soundVolume);
      await _musicPlayer.setVolume(_musicVolume);
    } catch (e) {
      if (kDebugMode) {
        print('Error loading audio settings: $e');
      }
    }
  }
  
  /// Play a sound effect
  Future<void> playSound(String soundName) async {
    if (!_soundEnabled) return;
    
    try {
      final soundPath = _soundEffects[soundName];
      if (soundPath != null) {
        await _effectPlayer.stop();
        await _effectPlayer.play(AssetSource(soundPath));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing sound: $e');
      }
    }
  }
  
  /// Play background music
  Future<void> playMusic(String musicName) async {
    if (!_musicEnabled) return;
    
    try {
      final musicPath = _backgroundMusic[musicName];
      if (musicPath != null) {
        await _musicPlayer.stop();
        await _musicPlayer.play(AssetSource(musicPath));
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error playing music: $e');
      }
    }
  }
  
  /// Stop background music
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }
  
  /// Pause background music
  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }
  
  /// Resume background music
  Future<void> resumeMusic() async {
    if (!_musicEnabled) return;
    await _musicPlayer.resume();
  }
  
  /// Set sound effects enabled/disabled
  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('soundEnabled', enabled);
  }
  
  /// Set background music enabled/disabled
  Future<void> setMusicEnabled(bool enabled) async {
    _musicEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('musicEnabled', enabled);
    
    if (enabled) {
      await resumeMusic();
    } else {
      await pauseMusic();
    }
  }
  
  /// Set sound effects volume
  Future<void> setSoundVolume(double volume) async {
    _soundVolume = volume;
    await _effectPlayer.setVolume(volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('soundVolume', volume);
  }
  
  /// Set background music volume
  Future<void> setMusicVolume(double volume) async {
    _musicVolume = volume;
    await _musicPlayer.setVolume(volume);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('musicVolume', volume);
  }
  
  /// Clean up resources
  Future<void> dispose() async {
    await _effectPlayer.dispose();
    await _musicPlayer.dispose();
  }
}
