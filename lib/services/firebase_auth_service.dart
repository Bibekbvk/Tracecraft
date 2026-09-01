import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseAuthService {
  static String? _cachedUserId;

  /// Signs in anonymously without friction for attribution of likes and ratings
  static Future<String> signInAnonymously() async {
    if (_cachedUserId != null) return _cachedUserId!;

    try {
      if (Firebase.apps.isNotEmpty) {
        final auth = FirebaseAuth.instance;
        if (auth.currentUser != null) {
          _cachedUserId = auth.currentUser!.uid;
          return _cachedUserId!;
        }
        final cred = await auth.signInAnonymously();
        if (cred.user != null) {
          _cachedUserId = cred.user!.uid;
          return _cachedUserId!;
        }
      }
    } catch (e) {
      debugPrint('FirebaseAuthService note: $e');
    }

    _cachedUserId = 'device_artist_${DateTime.now().millisecondsSinceEpoch % 100000}';
    return _cachedUserId!;
  }

  /// Current active user ID
  static String getCurrentUserId() {
    if (Firebase.apps.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) return user.uid;
    }
    return _cachedUserId ?? 'device_artist_default';
  }
}
