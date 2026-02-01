import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../../progress/providers/progress_provider.dart';
import '../models/practice_challenge.dart';
import '../models/practice_session.dart';
import '../../../database/sync_service.dart';

// Practice state
class PracticeState {
  final PracticeSession session;
  final PracticeChallenge currentChallenge;
  final int currentStreak;
  final bool isCorrect;
  final bool showFeedback;
  final bool isPaused;
  final bool isComplete;

  const PracticeState({
    required this.session,
    required this.currentChallenge,
    this.currentStreak = 0,
    this.isCorrect = false,
    this.showFeedback = false,
    this.isPaused = false,
    this.isComplete = false,
  });

  PracticeState copyWith({
    PracticeSession? session,
    PracticeChallenge? currentChallenge,
    int? currentStreak,
    bool? isCorrect,
    bool? showFeedback,
    bool? isPaused,
    bool? isComplete,
  }) {
    return PracticeState(
      session: session ?? this.session,
      currentChallenge: currentChallenge ?? this.currentChallenge,
      currentStreak: currentStreak ?? this.currentStreak,
      isCorrect: isCorrect ?? this.isCorrect,
      showFeedback: showFeedback ?? this.showFeedback,
      isPaused: isPaused ?? this.isPaused,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

// Practice notifier
class PracticeNotifier extends StateNotifier<PracticeState> {
  final Ref _ref;

  PracticeNotifier(this._ref, String difficulty)
    : super(
        PracticeState(
          session: PracticeSession(
            sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
            startTime: DateTime.now(),
            difficulty: difficulty,
          ),
          currentChallenge: PracticeChallenge.generateRandom(difficulty),
        ),
      );

  // Validate note played
  void checkNote(String playedNote) {
    final isCorrect = playedNote == state.currentChallenge.targetNote;

    int newStreak = isCorrect ? state.currentStreak + 1 : 0;
    int scoreBonus = isCorrect ? _calculateScore(newStreak) : 0;

    final updatedSession = state.session.copyWith(
      totalAttempts: state.session.totalAttempts + 1,
      correctAttempts: state.session.correctAttempts + (isCorrect ? 1 : 0),
      score: state.session.score + scoreBonus,
      notesPlayed: [...state.session.notesPlayed, playedNote],
      longestStreak: newStreak > state.session.longestStreak
          ? newStreak
          : state.session.longestStreak,
      accuracy: _calculateAccuracy(
        state.session.correctAttempts + (isCorrect ? 1 : 0),
        state.session.totalAttempts + 1,
      ),
    );

    state = state.copyWith(
      session: updatedSession,
      currentStreak: newStreak,
      isCorrect: isCorrect,
      showFeedback: true,
    );

    // Hide feedback after delay and generate new challenge
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        state = state.copyWith(
          showFeedback: false,
          currentChallenge: PracticeChallenge.generateRandom(
            state.session.difficulty,
          ),
        );
      }
    });
  }

  int _calculateScore(int streak) {
    int baseScore = 10;
    int streakBonus = streak > 1 ? streak * 2 : 0;

    // Difficulty multiplier
    double multiplier = 1.0;
    switch (state.session.difficulty) {
      case 'medium':
        multiplier = 1.5;
        break;
      case 'hard':
        multiplier = 2.0;
        break;
    }

    return ((baseScore + streakBonus) * multiplier).round();
  }

  double _calculateAccuracy(int correct, int total) {
    if (total == 0) return 0.0;
    return (correct / total * 100);
  }

  void changeDifficulty(String difficulty) {
    state = state.copyWith(
      currentChallenge: PracticeChallenge.generateRandom(difficulty),
      session: state.session.copyWith(difficulty: difficulty),
    );
  }

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  Future<PracticeSession> endSession() async {
    final finalSession = state.session.copyWith(endTime: DateTime.now());

    state = state.copyWith(session: finalSession, isComplete: true);

    // Save to Firestore
    await _saveSession(finalSession);

    return finalSession;
  }

  Future<void> _saveSession(PracticeSession session) async {
    try {
      final user = _ref.read(authProvider).firebaseUser;
      if (user == null) return;

      // Import sync service
      final syncService = SyncService();

      // 1. Save to cache first (instant, works offline)
      await syncService.savePracticeSessionToCache(session, user.uid);

      // 2. Save practice session to Firebase
      await FirebaseFirestore.instance
          .collection('practice_sessions')
          .doc(session.sessionId)
          .set({...session.toJson(), 'userId': user.uid});

      // Import progress actions
      final progressActions = _ref.read(progressActionsProvider);

      // Update progress with practice data
      await progressActions.updateProgress(
        practiceAttempts: 1,
        practiceTime: session.duration.inMinutes,
        accuracy: session.accuracy,
        xpGained: session.xpEarned,
      );

      // Update streak
      await progressActions.updateStreak();
    } catch (e) {
      debugPrint('Error saving practice session: $e');
    }
  }
}

// Provider
final practiceProvider =
    StateNotifierProvider.family<PracticeNotifier, PracticeState, String>(
      (ref, difficulty) => PracticeNotifier(ref, difficulty),
    );
