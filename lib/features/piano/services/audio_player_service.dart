import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

/// High-performance audio service for piano playback
/// Uses fire-and-forget pattern with preloaded audio for zero-lag playback
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  // Larger player pool for rapid key presses
  final List<AudioPlayer> _playerPool = [];
  final int _maxPlayers = 20; // Increased for smoother playback
  int _currentPlayerIndex = 0;

  double _volume = 0.8;
  bool _isMuted = false;
  bool _isInitialized = false;
  bool _isDisposed = false;

  // Cache for preloaded audio sources
  final Map<String, Source> _audioCache = {};

  // Keys for SharedPreferences
  static const String _volumeKey = 'audio_volume';
  static const String _mutedKey = 'audio_muted';

  /// Initialize the audio service
  Future<void> initialize() async {
    if (_isInitialized || _isDisposed) return;

    try {
      // Load saved preferences
      await _loadPreferences();

      // Create player pool with optimized settings
      for (int i = 0; i < _maxPlayers; i++) {
        final player = AudioPlayer();
        player.setVolume(_isMuted ? 0.0 : _volume);
        player.setReleaseMode(ReleaseMode.stop);
        player.setPlayerMode(PlayerMode.lowLatency); // Low latency for piano
        _playerPool.add(player);
      }

      // Preload common notes for faster playback
      await _preloadCommonNotes();

      _isInitialized = true;
      debugPrint('AudioPlayerService initialized with $_maxPlayers players');
    } catch (e) {
      debugPrint('Error initializing AudioPlayerService: $e');
      _isInitialized = true; // Mark as initialized to prevent retry loops
    }
  }

  /// Preload common piano notes (octave 4 and 5)
  Future<void> _preloadCommonNotes() async {
    final notesToPreload = [
      'audio/piano/C4.mp3',
      'audio/piano/D4.mp3',
      'audio/piano/E4.mp3',
      'audio/piano/F4.mp3',
      'audio/piano/G4.mp3',
      'audio/piano/A4.mp3',
      'audio/piano/B4.mp3',
      'audio/piano/Db4.mp3',
      'audio/piano/Eb4.mp3',
      'audio/piano/Gb4.mp3',
      'audio/piano/Ab4.mp3',
      'audio/piano/Bb4.mp3',
      'audio/piano/C5.mp3',
      'audio/piano/D5.mp3',
      'audio/piano/E5.mp3',
      'audio/piano/F5.mp3',
      'audio/piano/G5.mp3',
      'audio/piano/A5.mp3',
      'audio/piano/B5.mp3',
      'audio/piano/Db5.mp3',
      'audio/piano/Eb5.mp3',
      'audio/piano/Gb5.mp3',
      'audio/piano/Ab5.mp3',
      'audio/piano/Bb5.mp3',
    ];

    for (final path in notesToPreload) {
      _audioCache[path] = AssetSource(path);
    }
    debugPrint('Preloaded ${_audioCache.length} audio files');
  }

  /// Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _volume = prefs.getDouble(_volumeKey) ?? 0.8;
      _isMuted = prefs.getBool(_mutedKey) ?? false;
    } catch (e) {
      debugPrint('Error loading audio preferences: $e');
    }
  }

  /// Save preferences to SharedPreferences (fire-and-forget)
  void _savePreferencesAsync() {
    SharedPreferences.getInstance()
        .then((prefs) {
          prefs.setDouble(_volumeKey, _volume);
          prefs.setBool(_mutedKey, _isMuted);
        })
        .catchError((e) {
          debugPrint('Error saving audio preferences: $e');
        });
  }

  /// Get the correct asset path (strip 'assets/' prefix if present)
  String _getAssetPath(String path) {
    if (path.startsWith('assets/')) {
      return path.substring(7);
    }
    return path;
  }

  /// Play a note - FIRE AND FORGET for zero lag
  void playNote(Note note) {
    if (_isDisposed || _isMuted) return;

    // Fire-and-forget initialization
    if (!_isInitialized) {
      initialize().then((_) => _playNoteInternal(note));
      return;
    }

    _playNoteInternal(note);
  }

  /// Internal method to play note without blocking
  void _playNoteInternal(Note note) {
    try {
      // Get next player from pool (round-robin)
      final player = _playerPool[_currentPlayerIndex % _maxPlayers];
      _currentPlayerIndex++;

      // Get correct asset path
      final assetPath = _getAssetPath(note.audioAssetPath);

      // Use cached source if available, otherwise create new
      final source = _audioCache[assetPath] ?? AssetSource(assetPath);

      // Play without awaiting - fire and forget for zero lag
      player.stop().then((_) {
        player.play(source).catchError((e) {
          debugPrint('Error playing note ${note.fullName}: $e');
        });
      });
    } catch (e) {
      debugPrint('Error in playNote: $e');
    }
  }

  /// Play note by name (e.g., "C4", "D#4")
  void playNoteByName(String noteName) {
    try {
      // Convert note name to asset path
      String fileName;
      if (noteName.contains('#')) {
        // Sharp notes use flat naming: C#4 -> Db4
        final sharpToFlat = {
          'C#': 'Db',
          'D#': 'Eb',
          'F#': 'Gb',
          'G#': 'Ab',
          'A#': 'Bb',
        };
        final notePart = noteName.substring(0, 2);
        final octave = noteName.substring(2);
        fileName = '${sharpToFlat[notePart] ?? notePart}$octave';
      } else {
        fileName = noteName;
      }

      if (_isDisposed || _isMuted || !_isInitialized) return;

      final player = _playerPool[_currentPlayerIndex % _maxPlayers];
      _currentPlayerIndex++;

      final assetPath = 'audio/piano/$fileName.mp3';
      final source = _audioCache[assetPath] ?? AssetSource(assetPath);

      player.stop().then((_) {
        player.play(source);
      });
    } catch (e) {
      debugPrint('Error playing note $noteName: $e');
    }
  }

  /// Stop all sounds
  void stopAll() {
    if (_isDisposed) return;
    for (final player in _playerPool) {
      player.stop();
    }
  }

  /// Set volume (0.0 to 1.0) - non-blocking
  void setVolume(double volume) {
    if (_isDisposed) return;

    _volume = volume.clamp(0.0, 1.0);
    final actualVolume = _isMuted ? 0.0 : _volume;

    for (final player in _playerPool) {
      player.setVolume(actualVolume);
    }

    _savePreferencesAsync();
  }

  /// Get current volume
  double get volume => _volume;

  /// Mute audio - non-blocking
  void mute() {
    if (_isDisposed || _isMuted) return;

    _isMuted = true;
    for (final player in _playerPool) {
      player.setVolume(0.0);
    }
    _savePreferencesAsync();
  }

  /// Unmute audio - non-blocking
  void unmute() {
    if (_isDisposed || !_isMuted) return;

    _isMuted = false;
    for (final player in _playerPool) {
      player.setVolume(_volume);
    }
    _savePreferencesAsync();
  }

  /// Toggle mute state
  void toggleMute() {
    if (_isMuted) {
      unmute();
    } else {
      mute();
    }
  }

  /// Get mute state
  bool get isMuted => _isMuted;

  /// Get initialization state
  bool get isInitialized => _isInitialized;

  /// Dispose all players
  Future<void> dispose() async {
    if (_isDisposed) return;

    _isDisposed = true;
    for (final player in _playerPool) {
      await player.dispose();
    }
    _playerPool.clear();
    _audioCache.clear();
    _isInitialized = false;
  }

  /// Play feedback sound (correct/incorrect)
  void playFeedbackSound(bool isCorrect) {
    if (_isDisposed || _isMuted || !_isInitialized) return;

    try {
      final soundPath = isCorrect
          ? 'audio/feedback/correct.mp3'
          : 'audio/feedback/incorrect.mp3';

      final player = _playerPool[_currentPlayerIndex % _maxPlayers];
      _currentPlayerIndex++;

      player.stop().then((_) {
        player.play(AssetSource(soundPath)).catchError((e) {
          // Silently fail for feedback sounds
        });
      });
    } catch (e) {
      // Don't throw - feedback sounds are optional
    }
  }

  /// Play a test sound (for settings)
  void playTestSound() {
    if (_isDisposed) return;
    playNote(Note.c4);
  }
}
