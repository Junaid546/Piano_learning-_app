import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/audio_player_service.dart';

/// Provider for the singleton AudioPlayerService
final audioServiceProvider = Provider<AudioPlayerService>((ref) {
  return AudioPlayerService();
});

/// StateNotifier for audio volume (0.0 - 1.0)
class AudioVolumeNotifier extends StateNotifier<double> {
  final AudioPlayerService _audioService;

  AudioVolumeNotifier(this._audioService) : super(_audioService.volume);

  /// Set volume and update audio service (non-blocking)
  void setVolume(double volume) {
    final clampedVolume = volume.clamp(0.0, 1.0);
    state = clampedVolume;
    _audioService.setVolume(clampedVolume);
  }

  /// Initialize volume from audio service
  void initialize() {
    state = _audioService.volume;
  }
}

/// Provider for audio volume state
final audioVolumeProvider = StateNotifierProvider<AudioVolumeNotifier, double>((
  ref,
) {
  final audioService = ref.watch(audioServiceProvider);
  return AudioVolumeNotifier(audioService);
});

/// StateNotifier for audio mute state
class AudioMutedNotifier extends StateNotifier<bool> {
  final AudioPlayerService _audioService;

  AudioMutedNotifier(this._audioService) : super(_audioService.isMuted);

  /// Toggle mute state (non-blocking)
  void toggleMute() {
    _audioService.toggleMute();
    state = _audioService.isMuted;
  }

  /// Mute audio (non-blocking)
  void mute() {
    _audioService.mute();
    state = true;
  }

  /// Unmute audio (non-blocking)
  void unmute() {
    _audioService.unmute();
    state = false;
  }

  /// Initialize mute state from audio service
  void initialize() {
    state = _audioService.isMuted;
  }
}

/// Provider for audio muted state
final audioMutedProvider = StateNotifierProvider<AudioMutedNotifier, bool>((
  ref,
) {
  final audioService = ref.watch(audioServiceProvider);
  return AudioMutedNotifier(audioService);
});

/// Provider to initialize audio service on app start
final audioInitializationProvider = FutureProvider<void>((ref) async {
  final audioService = ref.watch(audioServiceProvider);
  await audioService.initialize();

  // Initialize state notifiers with loaded values
  ref.read(audioVolumeProvider.notifier).initialize();
  ref.read(audioMutedProvider.notifier).initialize();
});
