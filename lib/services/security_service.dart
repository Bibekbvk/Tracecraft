import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';

/// Comprehensive Security Service for TraceCraft
/// - Rate Limiting & Anti-Brute-Force
/// - Man-In-The-Middle (MITM) & HTTPS Protection
/// - Cryptographic Session ID Management
/// - Secret Key & API Key Obfuscation
/// - Input Sanitization & Anti-Injection
class SecurityService {
  // Session State
  static String? _currentSessionId;
  static DateTime? _sessionCreatedAt;
  static const Duration _sessionTtl = Duration(hours: 24);

  // Rate Limiting Storage: actionKey -> List of request timestamps
  static final Map<String, List<DateTime>> _requestLog = {};

  // OTP Brute-force Tracking: email -> list of failed attempt timestamps
  static final Map<String, List<DateTime>> _otpFailedAttempts = {};
  static const int _maxOtpFailures = 5;
  static const Duration _otpLockoutDuration = Duration(minutes: 15);

  // Secret obfuscation salt
  static const String _salt = 'TraceCraft_Security_Salt_2026_KeyShield';

  /// Initializes the security layer and creates the initial secure session
  static void init() {
    _rotateSession();
    debugPrint('🛡️ [SecurityService] Security layer initialized with active session.');
  }

  // ==========================================
  // 1. CRYPTOGRAPHIC SESSION ID MANAGEMENT
  // ==========================================

  /// Returns the current active session ID or creates a fresh one if expired
  static String getSessionId() {
    if (_currentSessionId == null || _isSessionExpired()) {
      _rotateSession();
    }
    return _currentSessionId!;
  }

  /// Rotates the session token (called on login, logout, or TTL expiration)
  static String rotateSession() {
    return _rotateSession();
  }

  static String _rotateSession() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    final token = base64UrlEncode(values).replaceAll('=', '');
    _currentSessionId = 'tc_sess_${DateTime.now().millisecondsSinceEpoch}_$token';
    _sessionCreatedAt = DateTime.now();
    return _currentSessionId!;
  }

  static bool _isSessionExpired() {
    if (_sessionCreatedAt == null) return true;
    return DateTime.now().difference(_sessionCreatedAt!) > _sessionTtl;
  }

  // ==========================================
  // 2. RATE LIMITING & ANTI-BRUTE-FORCE
  // ==========================================

  /// Checks if an action is within allowed rate limits using a sliding window.
  /// Returns `true` if allowed, `false` if rate limit exceeded.
  static bool checkRateLimit(
    String actionKey, {
    int maxRequests = 20,
    Duration window = const Duration(minutes: 1),
  }) {
    final now = DateTime.now();
    final timestamps = _requestLog.putIfAbsent(actionKey, () => []);

    // Remove expired timestamps outside sliding window
    timestamps.removeWhere((ts) => now.difference(ts) > window);

    if (timestamps.length >= maxRequests) {
      debugPrint('⚠️ [RateLimit] Action "$actionKey" exceeded $maxRequests requests in $window.');
      return false;
    }

    timestamps.add(now);
    return true;
  }

  /// Checks if an email is currently locked out due to excessive failed OTP attempts
  static bool isOtpLockedOut(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final failures = _otpFailedAttempts[cleanEmail];
    if (failures == null) return false;

    final now = DateTime.now();
    failures.removeWhere((ts) => now.difference(ts) > _otpLockoutDuration);

    return failures.length >= _maxOtpFailures;
  }

  /// Records a failed OTP verification attempt
  static void recordOtpFailure(String email) {
    final cleanEmail = email.trim().toLowerCase();
    final failures = _otpFailedAttempts.putIfAbsent(cleanEmail, () => []);
    failures.add(DateTime.now());
  }

  /// Resets failed OTP attempts upon successful login/verification
  static void resetOtpFailures(String email) {
    final cleanEmail = email.trim().toLowerCase();
    _otpFailedAttempts.remove(cleanEmail);
  }

  // ==========================================
  // 3. MITM PROTECTION & SECURE HEADERS
  // ==========================================

  /// Strictly enforces HTTPS on all network URLs to prevent Man-In-The-Middle packet interception
  static String enforceHttps(String url) {
    final trimmed = url.trim();
    if (trimmed.startsWith('http://')) {
      return trimmed.replaceFirst('http://', 'https://');
    }
    return trimmed;
  }

  /// Validates whether a URL is secure HTTPS
  static bool isSecureUrl(String url) {
    return url.trim().toLowerCase().startsWith('https://');
  }

  /// Injects secure headers for outbound HTTP requests
  static Map<String, String> getSecureHeaders({
    String? apiKey,
    String? bearerToken,
    Map<String, String>? extraHeaders,
  }) {
    final headers = <String, String>{
      'X-Client-Session-Id': getSessionId(),
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    };

    if (apiKey != null && apiKey.isNotEmpty) {
      headers['Authorization'] = apiKey;
    }
    if (bearerToken != null && bearerToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer $bearerToken';
    }
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }
    return headers;
  }

  // ==========================================
  // 4. API KEY OBFUSCATION & MASKING
  // ==========================================

  /// Obfuscates an API key using dynamic XOR cipher + Base64 with a salt
  static String obfuscateKey(String plainKey) {
    final keyBytes = utf8.encode(plainKey);
    final saltBytes = utf8.encode(_salt);
    final obfuscated = List<int>.generate(keyBytes.length, (i) {
      return keyBytes[i] ^ saltBytes[i % saltBytes.length];
    });
    return base64Encode(obfuscated);
  }

  /// De-obfuscates an encrypted key back to plain text at runtime
  static String deobfuscateKey(String obfuscatedBase64) {
    try {
      final obfuscatedBytes = base64Decode(obfuscatedBase64);
      final saltBytes = utf8.encode(_salt);
      final plainBytes = List<int>.generate(obfuscatedBytes.length, (i) {
        return obfuscatedBytes[i] ^ saltBytes[i % saltBytes.length];
      });
      return utf8.decode(plainBytes);
    } catch (_) {
      return obfuscatedBase64;
    }
  }

  /// Masks sensitive API keys or passwords for UI and logs (e.g. `iK98••••••••5cW`)
  static String maskSecret(String secret) {
    if (secret.length <= 6) return '••••••';
    final prefix = secret.substring(0, 4);
    final suffix = secret.substring(secret.length - 3);
    return '$prefix••••••••$suffix';
  }

  // ==========================================
  // 5. INPUT SANITIZATION & ANTI-INJECTION
  // ==========================================

  /// Sanitizes text input to prevent XSS, script injection, and control character attacks
  static String sanitizeText(String input, {int maxLength = 500}) {
    var sanitized = input.trim();

    // Strip script tags and HTML elements
    sanitized = sanitized.replaceAll(RegExp(r'<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>', caseSensitive: false), '');
    sanitized = sanitized.replaceAll(RegExp(r'<[^>]*>', caseSensitive: false), '');

    // Escape potential SQL/NoSQL payload injections
    sanitized = sanitized.replaceAll("'", "''");
    sanitized = sanitized.replaceAll('"', '""');
    sanitized = sanitized.replaceAll('\$', '');

    // Truncate to maximum safe length
    if (sanitized.length > maxLength) {
      sanitized = sanitized.substring(0, maxLength);
    }

    return sanitized;
  }
}
