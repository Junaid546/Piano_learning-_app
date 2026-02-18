# Lessons Seed Data

This file contains initial lesson data for the Melodify app.

## How to Add to Firestore

You can add this data to your Firestore database using one of these methods:

### Method 1: Firebase Console (Manual)
1. Go to Firebase Console → Firestore Database
2. Create a collection named `lessons`
3. For each lesson in the JSON file:
   - Click "Add Document"
   - Use the lesson's `id` as the Document ID
   - Add all fields from the lesson object

### Method 2: Using Firebase Admin SDK (Recommended)

Create a script to import the data:

```javascript
const admin = require('firebase-admin');
const serviceAccount = require('./path-to-service-account-key.json');
const lessonsData = require('./lessons_seed_data.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

async function seedLessons() {
  const batch = db.batch();
  
  lessonsData.lessons.forEach((lesson) => {
    const docRef = db.collection('lessons').doc(lesson.id);
    batch.set(docRef, lesson);
  });

  await batch.commit();
  console.log('Lessons seeded successfully!');
}

seedLessons();
```

### Method 3: Flutter Script

You can also create a Flutter script to seed the data:

```dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> seedLessons() async {
  final jsonString = await rootBundle.loadString(
    'lib/features/lessons/data/lessons_seed_data.json',
  );
  final data = json.decode(jsonString);
  final lessons = data['lessons'] as List;

  final batch = FirebaseFirestore.instance.batch();

  for (final lesson in lessons) {
    final docRef = FirebaseFirestore.instance
        .collection('lessons')
        .doc(lesson['id']);
    batch.set(docRef, lesson);
  }

  await batch.commit();
  print('Lessons seeded successfully!');
}
```

## Lesson Structure

Each lesson contains:
- **id**: Unique identifier
- **title**: Lesson name
- **category**: Grouping category
- **description**: Brief description
- **difficulty**: beginner/intermediate/advanced
- **estimatedDuration**: Time in minutes
- **order**: Display order
- **isCompleted**: Completion status
- **isLocked**: Lock status
- **objectives**: Learning objectives
- **notesToLearn**: Notes covered
- **content**: Theory, demo, practice, and tips
- **createdAt**: Creation timestamp

## Current Lessons

### Getting Started (4 lessons)
1. Welcome to Piano
2. Understanding the Keyboard
3. Your First Note: Middle C
4. Playing D and E

### Basic Notes & Scales (3 lessons)
5. Complete C Major Scale
6. Understanding Sharps and Flats
7. F and G Notes

## Adding More Lessons

To add more lessons, follow the same structure and increment the order number. Make sure to:
- Use unique IDs
- Maintain consistent difficulty progression
- Provide clear, actionable objectives
- Include practice notes that match the lesson content
