import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import '../models/note.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final Map<String, AudioPlayer> _playerPool = {};
  final int _maxPlayers = 10;
  int _currentPlayerIndex = 0;
  double _volume = 0.8;

  bool _isInitialized = false;

  /// Initialize the audio service and preload assets
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Create player pool
      for (int i = 0; i < _maxPlayers; i++) {
        final player = AudioPlayer();
        await player.setVolume(_volume);
        await player.setReleaseMode(ReleaseMode.stop);
        _playerPool['player_$i'] = player;
      }

      _isInitialized = true;
      debugPrint('AudioPlayerService initialized with $_maxPlayers players');
    } catch (e) {
      debugPrint('Error initializing AudioPlayerService: $e');
    }
  }

  /// Play a note
  Future<void> playNote(Note note) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Get next available player
      final playerKey = 'player_${_currentPlayerIndex % _maxPlayers}';
      final player = _playerPool[playerKey];

      if (player != null) {
        // Stop current sound if playing
        await player.stop();

        // Play the note
        await player.play(AssetSource(note.audioAssetPath));

        _currentPlayerIndex++;
      }
    } catch (e) {
      debugPrint('Error playing note ${note.fullName}: $e');
    }
  }

  /// Stop all sounds
  Future<void> stopAll() async {
    for (final player in _playerPool.values) {
      await player.stop();
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    for (final player in _playerPool.values) {
      await player.setVolume(_volume);
    }
  }

  /// Get current volume
  double get volume => _volume;

  /// Dispose all players
  Future<void> dispose() async {
    for (final player in _playerPool.values) {
      await player.dispose();
    }
    _playerPool.clear();
    _isInitialized = false;
  }

  /// Preload a specific note (optional optimization)
  Future<void> preloadNote(Note note) async {
    try {
      final player = AudioPlayer();
      await player.setSource(AssetSource(note.audioAssetPath));
      await player.dispose();
    } catch (e) {
      debugPrint('Error preloading note ${note.fullName}: $e');
    }
  }
}
