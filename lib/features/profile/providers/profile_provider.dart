import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../models/user_preferences.dart';
import '../../../database/sync_service.dart';

// Stream provider for user preferences with cache-first pattern
final userPreferencesProvider = StreamProvider<UserPreferences>((ref) async* {
  final user = ref.watch(authProvider).firebaseUser;
  if (user == null) {
    yield UserPreferences.defaultPreferences('');
    return;
  }

  final syncService = SyncService();

  // 1. Load from cache first (instant UI)
  final cachedPrefs = await syncService.loadUserPreferencesFromCache(user.uid);
  if (cachedPrefs != null) {
    yield cachedPrefs;
  }

  // 2. Stream from Firebase and update cache in background
  await for (final snapshot
      in FirebaseFirestore.instance
          .collection('user_preferences')
          .doc(user.uid)
          .snapshots()) {
    final prefs = snapshot.exists
        ? UserPreferences.fromJson(snapshot.data()!)
        : UserPreferences.defaultPreferences(user.uid);

    // Update cache silently in background
    syncService.updateUserPreferencesInCache(prefs);

    yield prefs;
  }
});

// Provider for profile actions
final profileActionsProvider = Provider<ProfileActions>((ref) {
  return ProfileActions(ref);
});

class ProfileActions {
  final Ref _ref;

  ProfileActions(this._ref);

  // Update user profile information
  Future<void> updateProfile({
    String? displayName,
    String? bio,
    String? learningGoal,
    String? skillLevel,
  }) async {
    try {
      final user = _ref.read(authProvider).firebaseUser;
      if (user == null) return;

      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (bio != null) updates['bio'] = bio;
      if (learningGoal != null) updates['learningGoal'] = learningGoal;
      if (skillLevel != null) updates['skillLevel'] = skillLevel;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updates);
    } catch (e) {
      debugPrint('Error updating profile: $e');
      rethrow;
    }
  }

  // Update user preferences
  Future<void> updatePreferences(UserPreferences preferences) async {
    try {
      final user = _ref.read(authProvider).firebaseUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('user_preferences')
          .doc(user.uid)
          .set(preferences.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('Error updating preferences: $e');
      rethrow;
    }
  }

  // Upload profile picture
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final user = _ref.read(authProvider).firebaseUser;
      if (user == null) return null;

      // Create a reference to the storage location
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      // Upload the file
      final uploadTask = await storageRef.putFile(imageFile);

      // Get the download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      // Update user document with new profile image URL
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'profileImageUrl': downloadUrl},
      );

      return downloadUrl;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      // This would require re-authentication
      // Implementation depends on your auth setup
      // For now, we'll leave this as a placeholder
      throw UnimplementedError('Password change requires re-authentication');
    } catch (e) {
      debugPrint('Error changing password: $e');
      rethrow;
    }
  }

  // Delete account
  Future<void> deleteAccount() async {
    try {
      final user = _ref.read(authProvider).firebaseUser;
      if (user == null) return;

      // Delete user data from Firestore
      final batch = FirebaseFirestore.instance.batch();

      batch.delete(
        FirebaseFirestore.instance.collection('users').doc(user.uid),
      );
      batch.delete(
        FirebaseFirestore.instance.collection('user_preferences').doc(user.uid),
      );
      batch.delete(
        FirebaseFirestore.instance.collection('progress').doc(user.uid),
      );

      await batch.commit();

      // Delete user account
      await user.delete();

      // Sign out
      final authNotifier = _ref.read(authProvider.notifier);
      await authNotifier.logout();
    } catch (e) {
      debugPrint('Error deleting account: $e');
      rethrow;
    }
  }

  // Initialize preferences for new users
  Future<void> initializePreferences(String userId) async {
    try {
      final prefsRef = FirebaseFirestore.instance
          .collection('user_preferences')
          .doc(userId);

      final doc = await prefsRef.get();
      if (!doc.exists) {
        final defaultPrefs = UserPreferences.defaultPreferences(userId);
        await prefsRef.set(defaultPrefs.toJson());
      }
    } catch (e) {
      debugPrint('Error initializing preferences: $e');
    }
  }
}
