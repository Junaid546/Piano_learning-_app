import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
  } else {
    // Yield default preferences immediately to prevent loading state
    yield UserPreferences.defaultPreferences(user.uid);
  }

  // 2. Stream from Firebase and update cache in background
  try {
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
  } catch (e) {
    debugPrint('Error loading preferences: $e');
    // Keep showing cached or default preferences on error
  }
});

// Provider for profile actions
final profileActionsProvider = Provider<ProfileActions>((ref) {
  return ProfileActions(ref);
});

class ProfileActions {
  final Ref _ref;
  final _syncService = SyncService();

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

      // 1. Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(updates);

      // 2. Update Local Cache (Optimistic or fetch-based)
      // We fetch current cache, merge updates, and save back
      final currentUserData = await _syncService.getUserFromCache(user.uid);

      final Map<String, dynamic> cacheData =
          currentUserData ??
          {
            'email': user.email ?? '',
            'displayName': user.displayName ?? '',
            'profileImageUrl': user.photoURL,
            'createdAt': DateTime.now().toIso8601String(),
          };

      // Merge updates
      if (displayName != null) cacheData['displayName'] = displayName;
      if (bio != null) cacheData['bio'] = bio;
      // learningGoal and skillLevel are likely in preferences or separate fields not in main user table yet,
      // but if we added them to user table we would update them here.
      // For now, based on schema, we only sync displayName and bio to sqlite users table.

      await _syncService.saveUserToCache(user.uid, cacheData);
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

      // 1. Update Firestore
      await FirebaseFirestore.instance
          .collection('user_preferences')
          .doc(user.uid)
          .set(preferences.toJson(), SetOptions(merge: true));

      // 2. Update Cache
      await _syncService.updateUserPreferencesInCache(preferences);
    } catch (e) {
      debugPrint('Error updating preferences: $e');
      rethrow;
    }
  }

  // Upload profile picture
  Future<String?> uploadProfilePicture(File imageFile) async {
    try {
      final user = _ref.read(authProvider).firebaseUser;
      if (user == null) throw Exception('User not logged in');

      // 1. Verify local file exists
      if (!await imageFile.exists()) {
        throw Exception('Image file does not exist at path: ${imageFile.path}');
      }

      // Create a reference to the storage location
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('${user.uid}.jpg');

      // 2. Upload the file using putFile
      final metadata = SettableMetadata(contentType: 'image/jpeg');
      final uploadTask = storageRef.putFile(imageFile, metadata);

      // 3. Wait for the upload to complete
      final snapshot = await uploadTask;

      // 4. Strict success check BEFORE getting download URL
      if (snapshot.state == TaskState.success) {
        // Retry logic for getDownloadURL to handle potential consistency race conditions
        String? downloadUrl;
        int retries = 3;
        while (retries > 0) {
          try {
            downloadUrl = await snapshot.ref.getDownloadURL();
            break; // Success!
          } catch (e) {
            if (retries == 1) rethrow; // If last retry, fail
            debugPrint(
              'getDownloadURL failed, retrying... ($retries left). Error: $e',
            );
            await Future.delayed(const Duration(milliseconds: 1000));
            retries--;
          }
        }

        if (downloadUrl == null) {
          throw Exception('Failed to get download URL after retries');
        }

        debugPrint('Upload successful. Download URL: $downloadUrl');

        // Update user document with new profile image URL in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImageUrl': downloadUrl});

        // Update Cache
        final currentUserData = await _syncService.getUserFromCache(user.uid);
        if (currentUserData != null) {
          currentUserData['profileImageUrl'] = downloadUrl;
          await _syncService.saveUserToCache(user.uid, currentUserData);
        }

        return downloadUrl;
      } else {
        throw Exception(
          'Upload failed. State: ${snapshot.state}, Bytes: ${snapshot.bytesTransferred}',
        );
      }
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      if (e is FirebaseException) {
        debugPrint('Firebase Storage Error: ${e.code} - ${e.message}');
        throw Exception('Upload failed: ${e.message} (Code: ${e.code})');
      }
      rethrow;
    }
  }

  // Change password with re-authentication
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final user = _ref.read(authProvider).firebaseUser;
      if (user == null) {
        throw Exception('User not logged in');
      }

      if (user.email == null) {
        throw Exception('User email not available');
      }

      // Re-authenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
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
