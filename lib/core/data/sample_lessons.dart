import 'package:cloud_firestore/cloud_firestore.dart';

/// Comprehensive sample lessons for the piano app
/// Covers beginner to advanced levels with complete content
class SampleLessons {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Seeds sample lessons to Firestore
  static Future<void> seedLessons() async {
    final batch = _firestore.batch();

    for (int i = 0; i < lessons.length; i++) {
      final docRef = _firestore.collection('lessons').doc();
      batch.set(docRef, lessons[i]);
    }

    await batch.commit();
    print('✅ Successfully seeded ${lessons.length} lessons');
  }

  static final List<Map<String, dynamic>> lessons = [
    // BEGINNER LESSONS
    {
      'id': 'lesson_001',
      'title': 'Introduction to Piano',
      'description': 'Learn the basics of piano and proper hand positioning',
      'category': 'Beginner',
      'difficulty': 'beginner',
      'difficultyLevel': 1,
      'order': 1,
      'estimatedDuration': 15,
      'objectives': [
        'Understand piano key layout',
        'Learn proper hand positioning',
        'Identify middle C',
        'Play your first note',
      ],
      'notesToLearn': ['C4'],
      'content': {
        'theoryText':
            'The piano has 88 keys, consisting of white and black keys arranged in a repeating pattern. Each key produces a unique sound. The white keys represent natural notes (C, D, E, F, G, A, B), while black keys are sharps and flats. Middle C is your reference point - it\'s near the center of the keyboard.',
        'tips': [
          'Sit at the center of the keyboard with good posture',
          'Keep your wrists level with the keys',
          'Curve your fingers naturally, like holding a ball',
          'Use the tips of your fingers, not the pads',
        ],
        'illustrationUrl': null,
        'demoNotes': ['C4', 'C4', 'C4'],
        'practiceNotes': ['C4', 'C4', 'C4', 'C4'],
      },
      'isLocked': false,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'lesson_002',
      'title': 'The Musical Alphabet',
      'description': 'Learn the note names C through G',
      'category': 'Beginner',
      'difficulty': 'beginner',
      'difficultyLevel': 1,
      'order': 2,
      'estimatedDuration': 20,
      'objectives': [
        'Learn note names C, D, E, F, G',
        'Play ascending scales',
        'Understand the musical alphabet',
      ],
      'notesToLearn': ['C4', 'D4', 'E4', 'F4', 'G4'],
      'content': {
        'theoryText':
            'Music uses only seven letter names: C, D, E, F, G, A, and B. After G, the pattern repeats with C again. This is called the musical alphabet. On piano, these are the white keys. The distance between keys creates different intervals.',
        'tips': [
          'Practice saying note names as you play',
          'Notice the pattern of 2 black keys, then 3 black keys',
          'C is always to the left of the 2 black keys',
          'Play slowly and evenly at first',
        ],
        'illustrationUrl': null,
        'demoNotes': ['C4', 'D4', 'E4', 'F4', 'G4'],
        'practiceNotes': ['C4', 'D4', 'E4', 'F4', 'G4', 'F4', 'E4', 'D4', 'C4'],
      },
      'isLocked': false,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'lesson_003',
      'title': 'Playing Mary Had a Little Lamb',
      'description': 'Your first complete song using E, D, and C',
      'category': 'Beginner',
      'difficulty': 'beginner',
      'difficultyLevel': 1,
      'order': 3,
      'estimatedDuration': 25,
      'objectives': [
        'Play a complete song',
        'Practice finger transitions',
        'Develop rhythm sense',
      ],
      'notesToLearn': ['C4', 'D4', 'E4'],
      'content': {
        'theoryText':
            'Songs are made of notes played in sequence (melody) and sometimes together (harmony). Mary Had a Little Lamb uses only three notes, making it perfect for beginners. Focus on playing each note clearly and evenly.',
        'tips': [
          'Start very slowly until you memorize the pattern',
          'Count "1, 2, 3, 4" to keep steady timing',
          'Practice the tricky parts separately',
          'Gradually increase speed as you improve',
        ],
        'illustrationUrl': null,
        'demoNotes': ['E4', 'D4', 'C4', 'D4', 'E4', 'E4', 'E4'],
        'practiceNotes': [
          'E4',
          'D4',
          'C4',
          'D4',
          'E4',
          'E4',
          'E4',
          'D4',
          'D4',
          'D4',
          'E4',
          'E4',
          'E4',
        ],
      },
      'isLocked': false,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'lesson_004',
      'title': 'Introduction to Rhythm',
      'description': 'Learn quarter notes and half notes',
      'category': 'Beginner',
      'difficulty': 'beginner',
      'difficultyLevel': 2,
      'order': 4,
      'estimatedDuration': 20,
      'objectives': [
        'Understand note duration',
        'Count beats correctly',
        'Play with consistent rhythm',
      ],
      'notesToLearn': ['C4', 'D4', 'E4', 'F4'],
      'content': {
        'theoryText':
            'Rhythm determines how long each note lasts. Quarter notes get 1 beat, half notes get 2 beats, and whole notes get 4 beats. Counting "1, 2, 3, 4" helps maintain steady tempo.',
        'tips': [
          'Tap your foot to keep the beat',
          'Count out loud while playing',
          'Use a metronome for steady tempo',
          'Practice rhythm separately from notes',
        ],
        'illustrationUrl': null,
        'demoNotes': ['C4', 'C4', 'D4', 'E4'],
        'practiceNotes': ['C4', 'D4', 'E4', 'F4', 'E4', 'D4', 'C4'],
      },
      'isLocked': false,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'lesson_005',
      'title': 'Playing Ode to Joy',
      'description': 'Learn Beethoven\'s famous melody',
      'category': 'Beginner',
      'difficulty': 'beginner',
      'difficultyLevel': 2,
      'order': 5,
      'estimatedDuration': 30,
      'objectives': [
        'Play a classical piece',
        'Practice finger independence',
        'Develop musical expression',
      ],
      'notesToLearn': ['C4', 'D4', 'E4', 'F4', 'G4'],
      'content': {
        'theoryText':
            'Ode to Joy is a beautiful melody by Beethoven. It uses five notes and teaches you to play smoothly (legato). Focus on connecting notes without gaps and keeping a steady rhythm.',
        'tips': [
          'Learn the melody in small 4-note chunks',
          'Practice hands separately before combining',
          'Listen to the original to understand phrasing',
          'Add dynamics (loud/soft) once comfortable',
        ],
        'illustrationUrl': null,
        'demoNotes': ['E4', 'E4', 'F4', 'G4', 'G4', 'F4', 'E4', 'D4'],
        'practiceNotes': [
          'E4',
          'E4',
          'F4',
          'G4',
          'G4',
          'F4',
          'E4',
          'D4',
          'C4',
          'C4',
          'D4',
          'E4',
        ],
      },
      'isLocked': false,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    },

    // INTERMEDIATE LESSONS
    {
      'id': 'lesson_006',
      'title': 'Introduction to Black Keys',
      'description': 'Learn sharps and flats',
      'category': 'Intermediate',
      'difficulty': 'intermediate',
      'difficultyLevel': 3,
      'order': 6,
      'estimatedDuration': 25,
      'objectives': [
        'Understand sharps and flats',
        'Play black keys correctly',
        'Learn chromatic scale',
      ],
      'notesToLearn': ['C4', 'Db4', 'D4', 'Eb4', 'E4'],
      'content': {
        'theoryText':
            'Black keys are sharps (#) or flats (♭). A sharp raises a note by one half-step, a flat lowers it. The same black key can be called by two names (e.g., C# and D♭ are the same key). This is called enharmonic equivalence.',
        'tips': [
          'Use the side of your finger tip for black keys',
          'Black keys require slightly more finger lift',
          'Practice chromatic scales (all 12 notes)',
          'Notice patterns in black key groupings',
        ],
        'illustrationUrl': null,
        'demoNotes': ['C4', 'Db4', 'D4', 'Eb4', 'E4', 'F4'],
        'practiceNotes': ['C4', 'Db4', 'D4', 'Eb4', 'E4', 'F4', 'Gb4', 'G4'],
      },
      'isLocked': false,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'lesson_007',
      'title': 'Playing Chords - Major Triads',
      'description': 'Learn to play three notes together',
      'category': 'Intermediate',
      'difficulty': 'intermediate',
      'difficultyLevel': 3,
      'order': 7,
      'estimatedDuration': 30,
      'objectives': [
        'Understand chord construction',
        'Play major triads',
        'Develop hand strength',
      ],
      'notesToLearn': ['C4', 'E4', 'G4'],
      'content': {
        'theoryText':
            'A chord is three or more notes played together. A major triad consists of the root, major third, and perfect fifth. For C major: C (root), E (major 3rd), G (perfect 5th). Chords form the harmony in music.',
        'tips': [
          'Press all three keys simultaneously',
          'Keep fingers curved and relaxed',
          'Practice chord progressions slowly',
          'Listen for all three notes sounding clearly',
        ],
        'illustrationUrl': null,
        'demoNotes': ['C4', 'E4', 'G4'],
        'practiceNotes': ['C4', 'E4', 'G4'],
      },
      'isLocked': false,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'lesson_008',
      'title': 'Hand Independence',
      'description': 'Play different rhythms with each hand',
      'category': 'Intermediate',
      'difficulty': 'intermediate',
      'difficultyLevel': 4,
      'order': 8,
      'estimatedDuration': 35,
      'objectives': [
        'Develop hand independence',
        'Play simple two-hand pieces',
        'Coordinate left and right hands',
      ],
      'notesToLearn': ['C4', 'D4', 'E4', 'F4', 'G4'],
      'content': {
        'theoryText':
            'Hand independence means each hand can play different patterns simultaneously. Typically, the right hand plays melody while the left plays accompaniment. This is a crucial skill for piano mastery.',
        'tips': [
          'Practice each hand separately first',
          'Start extremely slowly when combining hands',
          'Use a metronome to keep steady tempo',
          'Isolate difficult measures and repeat',
        ],
        'illustrationUrl': null,
        'demoNotes': ['C4', 'E4', 'G4'],
        'practiceNotes': ['C4', 'D4', 'E4', 'F4', 'G4'],
      },
      'isLocked': false,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    },

    // ADVANCED LESSONS
    {
      'id': 'lesson_009',
      'title': 'Advanced Scales - Major Scales',
      'description': 'Master all major scales across two octaves',
      'category': 'Advanced',
      'difficulty': 'advanced',
      'difficultyLevel': 5,
      'order': 9,
      'estimatedDuration': 40,
      'objectives': [
        'Learn all 12 major scales',
        'Understand key signatures',
        'Develop finger technique',
      ],
      'notesToLearn': ['C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4'],
      'content': {
        'theoryText':
            'Major scales follow the pattern: whole-whole-half-whole-whole-whole-half. Each scale has a unique key signature. Practicing scales builds finger strength, dexterity, and musical understanding.',
        'tips': [
          'Use proper fingering (thumb under technique)',
          'Practice hands separately at first',
          'Gradually increase tempo with metronome',
          'Play with even dynamics and rhythm',
        ],
        'illustrationUrl': null,
        'demoNotes': ['C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4'],
        'practiceNotes': ['C4', 'D4', 'E4', 'F4', 'G4', 'A4', 'B4'],
      },
      'isLocked': false,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
    {
      'id': 'lesson_010',
      'title': 'Playing Für Elise',
      'description': 'Learn the famous Beethoven piece',
      'category': 'Advanced',
      'difficulty': 'advanced',
      'difficultyLevel': 6,
      'order': 10,
      'estimatedDuration': 60,
      'objectives': [
        'Play a complete classical piece',
        'Master complex rhythms',
        'Develop musical interpretation',
      ],
      'notesToLearn': ['E4', 'Eb4', 'E4', 'Eb4', 'B4'],
      'content': {
        'theoryText':
            'Für Elise is one of Beethoven\'s most recognizable compositions. It combines melody, harmony, and dynamic expression. The piece requires coordination, finger independence, and musical sensitivity.',
        'tips': [
          'Break into small 2-4 measure sections',
          'Practice slowly with correct fingering',
          'Listen to professional recordings for interpretation',
          'Add pedal only after mastering the notes',
        ],
        'illustrationUrl': null,
        'demoNotes': ['E4', 'Eb4', 'E4', 'Eb4', 'E4'],
        'practiceNotes': ['E4', 'Eb4', 'E4', 'Eb4', 'E4', 'B4', 'D4', 'C4'],
      },
      'isLocked': false,
      'isCompleted': false,
      'createdAt': FieldValue.serverTimestamp(),
    },
  ];
}
