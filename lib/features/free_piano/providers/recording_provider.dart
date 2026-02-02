import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recording_session.dart';

/// Notifier for recording state
class RecordingNotifier extends StateNotifier<RecordingSession?> {
  final RecordingController _controller;

  RecordingNotifier(this._controller) : super(null) {
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    state = _controller.currentSession;
  }

  void startRecording() => _controller.startRecording();
  void recordNotePress(String note, int octave, double velocity) =>
      _controller.recordNotePress(note, octave, velocity);
  void recordNoteRelease(String note, int octave) =>
      _controller.recordNoteRelease(note, octave);
  void stopRecording() => _controller.stopRecording();
  void startPlayback() => _controller.startPlayback();
  void stopPlayback() => _controller.stopPlayback();
  void clearSession() => _controller.clearSession();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// Provider for recording session state
final recordingProvider = StateNotifierProvider<RecordingNotifier, RecordingSession?>((ref) {
  final controller = RecordingController();
  return RecordingNotifier(controller);
});

/// Provider for recording state (bool)
final isRecordingProvider = Provider<bool>((ref) {
  return ref.watch(recordingProvider)?.isRecording ?? false;
});

/// Provider for playback state (bool)
final isPlayingProvider = Provider<bool>((ref) {
  return ref.watch(recordingProvider)?.isPlaying ?? false;
});

/// Provider for recording duration
final recordingDurationProvider = Provider<Duration>((ref) {
  return ref.watch(recordingProvider)?.duration ?? Duration.zero;
});

/// Provider for playback position
final playbackPositionProvider = Provider<Duration>((ref) {
  return ref.watch(recordingProvider)?.playbackPosition ?? Duration.zero;
});

/// Provider for recorded notes count
final recordedNotesCountProvider = Provider<int>((ref) {
  return ref.watch(recordingProvider)?.recordedNotes.length ?? 0;
});
