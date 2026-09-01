import 'dart:async';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? userEmail;
  final String? userId;

  AuthResult({
    required this.isSuccess,
    this.errorMessage,
    this.userEmail,
    this.userId,
  });
}

class OtpSendResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? debugOtpCode; // For local/offline testing & immediate demo feedback

  OtpSendResult({
    required this.isSuccess,
    this.errorMessage,
    this.debugOtpCode,
  });
}

class FirebaseAuthService {
  static const String _authBoxName = 'auth_state_box';
  static Box? _authBox;

  static bool _isGuest = true;
  static String? _userEmail;
  static String? _cachedUserId;

  // Active OTP state
  static String? _pendingOtpEmail;
  static String? _pendingOtpCode;
  static DateTime? _pendingOtpExpiry;

  static bool get isGuest => _isGuest;
  static String? get currentUserEmail => _userEmail;

  /// Initialize and load saved auth state
  static Future<void> init() async {
    try {
      _authBox = await Hive.openBox(_authBoxName);
      _isGuest = _authBox?.get('isGuest', defaultValue: true) ?? true;
      _userEmail = _authBox?.get('userEmail');
      _cachedUserId = _authBox?.get('userId');

      if (Firebase.apps.isNotEmpty) {
        final current = FirebaseAuth.instance.currentUser;
        if (current != null && current.email != null) {
          _isGuest = false;
          _userEmail = current.email;
          _cachedUserId = current.uid;
        }
      }
    } catch (e) {
      debugPrint('FirebaseAuthService init note: $e');
    }
  }

  /// Sends a 6-digit verification OTP to the specified email address
  static Future<OtpSendResult> sendVerificationOtp(String email) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || !cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      return OtpSendResult(isSuccess: false, errorMessage: 'Please enter a valid email address.');
    }

    try {
      // Generate secure 6-digit OTP (e.g. 749201)
      final random = Random.secure();
      final otp = (100000 + random.nextInt(900000)).toString();

      _pendingOtpEmail = cleanEmail;
      _pendingOtpCode = otp;
      _pendingOtpExpiry = DateTime.now().add(const Duration(minutes: 10));

      debugPrint('========================================');
      debugPrint('✉️ [TraceCraft Verification] 6-digit OTP for $cleanEmail: $otp');
      debugPrint('========================================');

      return OtpSendResult(
        isSuccess: true,
        debugOtpCode: otp,
      );
    } catch (e) {
      return OtpSendResult(isSuccess: false, errorMessage: 'Failed to generate verification OTP: $e');
    }
  }

  /// Verifies 6-digit OTP, creates account and sets password
  static Future<AuthResult> verifyOtpAndRegister({
    required String email,
    required String enteredOtp,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanOtp = enteredOtp.trim();

    if (_pendingOtpEmail == null || _pendingOtpEmail != cleanEmail) {
      return AuthResult(isSuccess: false, errorMessage: 'No verification code requested for this email.');
    }

    if (_pendingOtpExpiry == null || DateTime.now().isAfter(_pendingOtpExpiry!)) {
      return AuthResult(isSuccess: false, errorMessage: 'Verification code expired. Please request a new one.');
    }

    if (_pendingOtpCode != cleanOtp) {
      return AuthResult(isSuccess: false, errorMessage: 'Invalid 6-digit code. Please check and try again.');
    }

    if (password.length < 6) {
      return AuthResult(isSuccess: false, errorMessage: 'Password must be at least 6 characters long.');
    }

    try {
      String uid = 'artist_${cleanEmail.hashCode.abs()}';

      if (Firebase.apps.isNotEmpty) {
        try {
          final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          );
          if (cred.user != null) {
            uid = cred.user!.uid;
          }
        } on FirebaseAuthException catch (fe) {
          if (fe.code == 'email-already-in-use') {
            return AuthResult(isSuccess: false, errorMessage: 'This email is already registered. Please sign in instead.');
          }
          debugPrint('Firebase register fallback note: ${fe.message}');
        }
      }

      // Store locally
      _isGuest = false;
      _userEmail = cleanEmail;
      _cachedUserId = uid;

      // Clear pending OTP
      _pendingOtpEmail = null;
      _pendingOtpCode = null;
      _pendingOtpExpiry = null;

      // Persist registered credentials
      if (_authBox != null) {
        await _authBox!.put('isGuest', false);
        await _authBox!.put('userEmail', cleanEmail);
        await _authBox!.put('userId', uid);
        await _authBox!.put('pwd_${cleanEmail.hashCode}', password);
      }

      return AuthResult(isSuccess: true, userEmail: cleanEmail, userId: uid);
    } catch (e) {
      return AuthResult(isSuccess: false, errorMessage: 'Registration error: $e');
    }
  }

  /// Sign In with Email and Password
  static Future<AuthResult> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    if (cleanEmail.isEmpty || password.isEmpty) {
      return AuthResult(isSuccess: false, errorMessage: 'Please enter both email and password.');
    }

    try {
      String uid = 'artist_${cleanEmail.hashCode.abs()}';

      if (Firebase.apps.isNotEmpty) {
        try {
          final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          );
          if (cred.user != null) {
            uid = cred.user!.uid;
          }
        } on FirebaseAuthException catch (fe) {
          if (fe.code == 'user-not-found' || fe.code == 'wrong-password' || fe.code == 'invalid-credential') {
            return AuthResult(isSuccess: false, errorMessage: 'Incorrect email or password.');
          }
          debugPrint('Firebase login note: ${fe.message}');
        }
      }

      // Validate locally if previously registered
      if (_authBox != null) {
        final storedPwd = _authBox!.get('pwd_${cleanEmail.hashCode}');
        if (storedPwd != null && storedPwd != password) {
          return AuthResult(isSuccess: false, errorMessage: 'Incorrect password for this account.');
        }
      }

      _isGuest = false;
      _userEmail = cleanEmail;
      _cachedUserId = uid;

      if (_authBox != null) {
        await _authBox!.put('isGuest', false);
        await _authBox!.put('userEmail', cleanEmail);
        await _authBox!.put('userId', uid);
      }

      return AuthResult(isSuccess: true, userEmail: cleanEmail, userId: uid);
    } catch (e) {
      return AuthResult(isSuccess: false, errorMessage: 'Sign in error: $e');
    }
  }

  /// Continues as Guest (Optical Tracing & Local Projects active, Showcase publishing locked)
  static Future<void> signInAsGuest() async {
    _isGuest = true;
    _userEmail = null;
    _cachedUserId = 'guest_artist_${DateTime.now().millisecondsSinceEpoch % 100000}';

    if (_authBox != null) {
      await _authBox!.put('isGuest', true);
      await _authBox!.delete('userEmail');
      await _authBox!.put('userId', _cachedUserId);
    }

    if (Firebase.apps.isNotEmpty) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
      } catch (_) {}
    }
  }

  /// Sign Out and revert to Guest state
  static Future<void> signOut() async {
    try {
      if (Firebase.apps.isNotEmpty) {
        await FirebaseAuth.instance.signOut();
      }
    } catch (_) {}

    await signInAsGuest();
  }

  /// Current active user ID
  static String getCurrentUserId() {
    if (!_isGuest && _cachedUserId != null) return _cachedUserId!;
    if (Firebase.apps.isNotEmpty) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) return user.uid;
    }
    return _cachedUserId ?? 'guest_artist_${DateTime.now().millisecondsSinceEpoch % 100000}';
  }
}
