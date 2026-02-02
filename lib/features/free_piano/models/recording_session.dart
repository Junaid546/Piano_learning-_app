import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math' as math;

/// Represents a recording session for the piano.
/// This model is designed for future recording feature implementation.
@immutable
class RecordingSession {
  /// Unique session identifier
  final String sessionId;

  /// When the recording started
  final DateTime startTime;

  /// All recorded notes in this session
  final List<RecordedNote> recordedNotes;

  /// Total duration of the recording
  final Duration duration;

  /// Whether recording is currently active
  final bool isRecording;

  /// Whether playback is currently active
  final bool isPlaying;

  /// Current playback position
  final Duration playbackPosition;

  /// Name of the recording (user-defined)
  final String name;

  const RecordingSession({
    required this.sessionId,
    required this.startTime,
    this.recordedNotes = const [],
    this.duration = Duration.zero,
    this.isRecording = false,
    this.isPlaying = false,
    this.playbackPosition = Duration.zero,
    this.name = '',
  });

  /// Create a new recording session
  factory RecordingSession.startNew() {
    return RecordingSession(
      sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
      startTime: DateTime.now(),
      isRecording: true,
      name: 'Recording ${DateTime.now().toString().substring(0, 16)}',
    );
  }

  /// Add a note to the recording
  RecordingSession addNote(RecordedNote note) {
    return RecordingSession(
      sessionId: sessionId,
      startTime: startTime,
      recordedNotes: [...recordedNotes, note],
      duration: duration,
      isRecording: isRecording,
      isPlaying: isPlaying,
      playbackPosition: playbackPosition,
      name: name,
    );
  }

  /// Stop recording and calculate final duration
  RecordingSession stopRecording() {
    final finalDuration = DateTime.now().difference(startTime);
    return RecordingSession(
      sessionId: sessionId,
      startTime: startTime,
      recordedNotes: recordedNotes,
      duration: finalDuration,
      isRecording: false,
      isPlaying: isPlaying,
      playbackPosition: playbackPosition,
      name: name,
    );
  }

  /// Start playback
  RecordingSession startPlayback() {
    return RecordingSession(
      sessionId: sessionId,
      startTime: startTime,
      recordedNotes: recordedNotes,
      duration: duration,
      isRecording: false,
      isPlaying: true,
      playbackPosition: Duration.zero,
      name: name,
    );
  }

  /// Stop playback
  RecordingSession stopPlayback() {
    return RecordingSession(
      sessionId: sessionId,
      startTime: startTime,
      recordedNotes: recordedNotes,
      duration: duration,
      isRecording: false,
      isPlaying: false,
      playbackPosition: Duration.zero,
      name: name,
    );
  }

  /// Update playback position
  RecordingSession updatePlaybackPosition(Duration position) {
    return RecordingSession(
      sessionId: sessionId,
      startTime: startTime,
      recordedNotes: recordedNotes,
      duration: duration,
      isRecording: false,
      isPlaying: isPlaying,
      playbackPosition: position,
      name: name,
    );
  }

  /// Rename the recording
  RecordingSession rename(String newName) {
    return RecordingSession(
      sessionId: sessionId,
      startTime: startTime,
      recordedNotes: recordedNotes,
      duration: duration,
      isRecording: isRecording,
      isPlaying: isPlaying,
      playbackPosition: playbackPosition,
      name: newName,
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'startTime': startTime.toIso8601String(),
      'recordedNotes': recordedNotes.map((n) => n.toJson()).toList(),
      'duration': duration.inMilliseconds,
      'name': name,
    };
  }

  /// Create from JSON
  factory RecordingSession.fromJson(Map<String, dynamic> json) {
    return RecordingSession(
      sessionId: json['sessionId'],
      startTime: DateTime.parse(json['startTime']),
      recordedNotes: (json['recordedNotes'] as List)
          .map((n) => RecordedNote.fromJson(n))
          .toList(),
      duration: Duration(milliseconds: json['duration'] ?? 0),
      name: json['name'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecordingSession &&
        other.sessionId == sessionId &&
        other.isRecording == isRecording &&
        other.isPlaying == isPlaying;
  }

  @override
  int get hashCode => Object.hash(sessionId, isRecording, isPlaying);
}

/// Represents a single recorded note event.
@immutable
class RecordedNote {
  /// The note name
  final String note;

  /// The octave number
  final int octave;

  /// Timestamp when the note was pressed (milliseconds from session start)
  final int timestamp;

  /// Duration the key was held (milliseconds)
  final int duration;

  /// Velocity of the note (0.0 to 1.0)
  final double velocity;

  const RecordedNote({
    required this.note,
    required this.octave,
    required this.timestamp,
    required this.duration,
    this.velocity = 0.8,
  });

  /// Full note name
  String get fullName => '$note$octave';

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'note': note,
      'octave': octave,
      'timestamp': timestamp,
      'duration': duration,
      'velocity': velocity,
    };
  }

  /// Create from JSON
  factory RecordedNote.fromJson(Map<String, dynamic> json) {
    return RecordedNote(
      note: json['note'],
      octave: json['octave'],
      timestamp: json['timestamp'] ?? 0,
      duration: json['duration'] ?? 0,
      velocity: (json['velocity'] ?? 0.8).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RecordedNote &&
        other.note == note &&
        other.octave == octave &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(note, octave, timestamp);
}

/// Controller for managing recording sessions.
class RecordingController extends ChangeNotifier {
  RecordingSession? _currentSession;
  Timer? _playbackTimer;
  int _lastNoteTimestamp = 0;

  /// Get the current session
  RecordingSession? get currentSession => _currentSession;

  /// Whether recording is active
  bool get isRecording => _currentSession?.isRecording ?? false;

  /// Whether playback is active
  bool get isPlaying => _currentSession?.isPlaying ?? false;

  /// Start a new recording session
  void startRecording() {
    _currentSession = RecordingSession.startNew();
    _lastNoteTimestamp = 0;
    notifyListeners();
  }

  /// Record a note press
  void recordNotePress(String note, int octave, double velocity) {
    if (_currentSession?.isRecording != true) return;

    final now = DateTime.now();
    final sessionStart = _currentSession!.startTime;
    final timestamp = now.difference(sessionStart).inMilliseconds;

    // Create a placeholder note (duration will be updated on release)
    final recordedNote = RecordedNote(
      note: note,
      octave: octave,
      timestamp: timestamp,
      duration: 0, // Will be updated when key is released
      velocity: velocity,
    );

    _currentSession = _currentSession!.addNote(recordedNote);
    _lastNoteTimestamp = timestamp;
    notifyListeners();
  }

  /// Record a note release and update duration
  void recordNoteRelease(String note, int octave) {
    if (_currentSession?.isRecording != true) return;

    final now = DateTime.now();
    final sessionStart = _currentSession!.startTime;
    final timestamp = now.difference(sessionStart).inMilliseconds;
    final duration = timestamp - _lastNoteTimestamp;

    // Find and update the last note for this key
    final notes = List<RecordedNote>.from(_currentSession!.recordedNotes);
    for (int i = notes.length - 1; i >= 0; i--) {
      if (notes[i].note == note && notes[i].octave == octave) {
        notes[i] = RecordedNote(
          note: notes[i].note,
          octave: notes[i].octave,
          timestamp: notes[i].timestamp,
          duration: duration,
          velocity: notes[i].velocity,
        );
        _currentSession = RecordingSession(
          sessionId: _currentSession!.sessionId,
          startTime: _currentSession!.startTime,
          recordedNotes: notes,
          isRecording: true,
          name: _currentSession!.name,
        );
        break;
      }
    }
    notifyListeners();
  }

  /// Stop recording
  void stopRecording() {
    if (_currentSession?.isRecording == true) {
      _currentSession = _currentSession!.stopRecording();
      notifyListeners();
    }
  }

  /// Start playback
  void startPlayback() {
    if (_currentSession == null || _currentSession!.recordedNotes.isEmpty) return;

    _currentSession = _currentSession!.startPlayback();
    notifyListeners();

    // Start playback timer
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_currentSession?.isPlaying != true) {
        timer.cancel();
        return;
      }

      final newPosition = Duration(
        milliseconds: (_currentSession!.playbackPosition.inMilliseconds + 16),
      );

      if (newPosition >= _currentSession!.duration) {
        // Playback complete
        _currentSession = _currentSession!.stopPlayback();
        notifyListeners();
        timer.cancel();
      } else {
        _currentSession = _currentSession!.updatePlaybackPosition(newPosition);
        notifyListeners();
      }
    });
  }

  /// Stop playback
  void stopPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    if (_currentSession != null) {
      _currentSession = _currentSession!.stopPlayback();
      notifyListeners();
    }
  }

  /// Clear current session
  void clearSession() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
    _currentSession = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}
