class Note {
  final String noteName; // C, D, E, F, G, A, B
  final int octave;
  final double frequency;
  final String audioAssetPath;
  final bool isSharp;

  const Note({
    required this.noteName,
    required this.octave,
    required this.frequency,
    required this.audioAssetPath,
    required this.isSharp,
  });

  String get fullName => isSharp ? '$noteName#$octave' : '$noteName$octave';

  String get displayName => isSharp ? '$noteName#' : noteName;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          noteName == other.noteName &&
          octave == other.octave &&
          isSharp == other.isSharp;

  @override
  int get hashCode => noteName.hashCode ^ octave.hashCode ^ isSharp.hashCode;

  @override
  String toString() => fullName;

  // Predefined notes for easy access
  static const Note c4 = Note(
    noteName: 'C',
    octave: 4,
    frequency: 261.63,
    audioAssetPath: 'assets/audio/piano/C4.mp3',
    isSharp: false,
  );

  static const Note cSharp4 = Note(
    noteName: 'C',
    octave: 4,
    frequency: 277.18,
    audioAssetPath: 'assets/audio/piano/Db4.mp3',
    isSharp: true,
  );

  static const Note d4 = Note(
    noteName: 'D',
    octave: 4,
    frequency: 293.66,
    audioAssetPath: 'assets/audio/piano/D4.mp3',
    isSharp: false,
  );

  static const Note dSharp4 = Note(
    noteName: 'D',
    octave: 4,
    frequency: 311.13,
    audioAssetPath: 'assets/audio/piano/Eb4.mp3',
    isSharp: true,
  );

  static const Note e4 = Note(
    noteName: 'E',
    octave: 4,
    frequency: 329.63,
    audioAssetPath: 'assets/audio/piano/E4.mp3',
    isSharp: false,
  );

  static const Note f4 = Note(
    noteName: 'F',
    octave: 4,
    frequency: 349.23,
    audioAssetPath: 'assets/audio/piano/F4.mp3',
    isSharp: false,
  );

  static const Note fSharp4 = Note(
    noteName: 'F',
    octave: 4,
    frequency: 369.99,
    audioAssetPath: 'assets/audio/piano/Gb4.mp3',
    isSharp: true,
  );

  static const Note g4 = Note(
    noteName: 'G',
    octave: 4,
    frequency: 392.00,
    audioAssetPath: 'assets/audio/piano/G4.mp3',
    isSharp: false,
  );

  static const Note gSharp4 = Note(
    noteName: 'G',
    octave: 4,
    frequency: 415.30,
    audioAssetPath: 'assets/audio/piano/Ab4.mp3',
    isSharp: true,
  );

  static const Note a4 = Note(
    noteName: 'A',
    octave: 4,
    frequency: 440.00,
    audioAssetPath: 'assets/audio/piano/A4.mp3',
    isSharp: false,
  );

  static const Note aSharp4 = Note(
    noteName: 'A',
    octave: 4,
    frequency: 466.16,
    audioAssetPath: 'assets/audio/piano/Bb4.mp3',
    isSharp: true,
  );

  static const Note b4 = Note(
    noteName: 'B',
    octave: 4,
    frequency: 493.88,
    audioAssetPath: 'assets/audio/piano/B4.mp3',
    isSharp: false,
  );

  // Octave 5
  static const Note c5 = Note(
    noteName: 'C',
    octave: 5,
    frequency: 523.25,
    audioAssetPath: 'assets/audio/piano/C5.mp3',
    isSharp: false,
  );

  static const Note cSharp5 = Note(
    noteName: 'C',
    octave: 5,
    frequency: 554.37,
    audioAssetPath: 'assets/audio/piano/Db5.mp3',
    isSharp: true,
  );

  static const Note d5 = Note(
    noteName: 'D',
    octave: 5,
    frequency: 587.33,
    audioAssetPath: 'assets/audio/piano/D5.mp3',
    isSharp: false,
  );

  static const Note dSharp5 = Note(
    noteName: 'D',
    octave: 5,
    frequency: 622.25,
    audioAssetPath: 'assets/audio/piano/Eb5.mp3',
    isSharp: true,
  );

  static const Note e5 = Note(
    noteName: 'E',
    octave: 5,
    frequency: 659.25,
    audioAssetPath: 'assets/audio/piano/E5.mp3',
    isSharp: false,
  );

  static const Note f5 = Note(
    noteName: 'F',
    octave: 5,
    frequency: 698.46,
    audioAssetPath: 'assets/audio/piano/F5.mp3',
    isSharp: false,
  );

  static const Note fSharp5 = Note(
    noteName: 'F',
    octave: 5,
    frequency: 739.99,
    audioAssetPath: 'assets/audio/piano/Gb5.mp3',
    isSharp: true,
  );

  static const Note g5 = Note(
    noteName: 'G',
    octave: 5,
    frequency: 783.99,
    audioAssetPath: 'assets/audio/piano/G5.mp3',
    isSharp: false,
  );

  static const Note gSharp5 = Note(
    noteName: 'G',
    octave: 5,
    frequency: 830.61,
    audioAssetPath: 'assets/audio/piano/Ab5.mp3',
    isSharp: true,
  );

  static const Note a5 = Note(
    noteName: 'A',
    octave: 5,
    frequency: 880.00,
    audioAssetPath: 'assets/audio/piano/A5.mp3',
    isSharp: false,
  );

  static const Note aSharp5 = Note(
    noteName: 'A',
    octave: 5,
    frequency: 932.33,
    audioAssetPath: 'assets/audio/piano/Bb5.mp3',
    isSharp: true,
  );

  static const Note b5 = Note(
    noteName: 'B',
    octave: 5,
    frequency: 987.77,
    audioAssetPath: 'assets/audio/piano/B5.mp3',
    isSharp: false,
  );

  // Helper to get all notes for an octave
  static List<Note> getOctave(int octave) {
    if (octave == 4) {
      return [
        c4,
        cSharp4,
        d4,
        dSharp4,
        e4,
        f4,
        fSharp4,
        g4,
        gSharp4,
        a4,
        aSharp4,
        b4,
      ];
    } else if (octave == 5) {
      return [
        c5,
        cSharp5,
        d5,
        dSharp5,
        e5,
        f5,
        fSharp5,
        g5,
        gSharp5,
        a5,
        aSharp5,
        b5,
      ];
    }
    return [];
  }
}
