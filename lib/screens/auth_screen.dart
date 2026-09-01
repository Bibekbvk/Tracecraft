import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trace_craft/screens/main_shell_screen.dart';
import 'package:trace_craft/services/firebase_auth_service.dart';
import 'package:trace_craft/widgets/glass_card_widget.dart';

class AuthScreen extends StatefulWidget {
  final bool isFromDrawer;

  const AuthScreen({super.key, this.isFromDrawer = false});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Sign In controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  bool _obscureSignInPassword = true;
  bool _isSignInLoading = false;

  // Sign Up (OTP) state
  final _signUpEmailController = TextEditingController();
  final _otpController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureSignUpPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isOtpSent = false;
  bool _isOtpLoading = false;
  bool _isRegisterLoading = false;
  String? _debugOtpHint;
  int _resendCountdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpEmailController.dispose();
    _otpController.dispose();
    _signUpPasswordController.dispose();
    _confirmPasswordController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() => _resendCountdown = 60);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_resendCountdown > 0) {
        setState(() => _resendCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _handleSignIn() async {
    final email = _signInEmailController.text.trim();
    final password = _signInPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackbar('Please enter your email and password.', isError: true);
      return;
    }

    setState(() => _isSignInLoading = true);
    final result = await FirebaseAuthService.signInWithEmailPassword(
      email: email,
      password: password,
    );
    if (!mounted) return;
    setState(() => _isSignInLoading = false);

    if (result.isSuccess) {
      HapticFeedback.mediumImpact();
      _showSnackbar('Welcome back, ${result.userEmail}!');
      _proceedToApp();
    } else {
      _showSnackbar(result.errorMessage ?? 'Sign in failed.', isError: true);
    }
  }

  Future<void> _handleSendOtp() async {
    final email = _signUpEmailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      _showSnackbar('Please enter a valid email address.', isError: true);
      return;
    }

    setState(() => _isOtpLoading = true);
    final result = await FirebaseAuthService.sendVerificationOtp(email);
    if (!mounted) return;
    setState(() => _isOtpLoading = false);

    if (result.isSuccess) {
      HapticFeedback.lightImpact();
      setState(() {
        _isOtpSent = true;
        _debugOtpHint = result.debugOtpCode;
      });
      _startResendTimer();
      _showSnackbar('6-digit OTP code sent to $email!');
    } else {
      _showSnackbar(result.errorMessage ?? 'Failed to send OTP.', isError: true);
    }
  }

  Future<void> _handleRegisterWithOtp() async {
    final email = _signUpEmailController.text.trim();
    final otp = _otpController.text.trim();
    final password = _signUpPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (otp.length != 6) {
      _showSnackbar('Please enter the 6-digit verification code.', isError: true);
      return;
    }
    if (password.length < 6) {
      _showSnackbar('Password must be at least 6 characters long.', isError: true);
      return;
    }
    if (password != confirmPassword) {
      _showSnackbar('Passwords do not match.', isError: true);
      return;
    }

    setState(() => _isRegisterLoading = true);
    final result = await FirebaseAuthService.verifyOtpAndRegister(
      email: email,
      enteredOtp: otp,
      password: password,
    );
    if (!mounted) return;
    setState(() => _isRegisterLoading = false);

    if (result.isSuccess) {
      HapticFeedback.mediumImpact();
      _showSnackbar('Account created successfully! Welcome, ${result.userEmail}!');
      _proceedToApp();
    } else {
      _showSnackbar(result.errorMessage ?? 'Registration failed.', isError: true);
    }
  }

  Future<void> _continueAsGuest() async {
    HapticFeedback.lightImpact();
    await FirebaseAuthService.signInAsGuest();
    if (!mounted) return;
    _showSnackbar('Continuing in Guest Mode. Gallery publishing will require an account.');
    _proceedToApp();
  }

  void _proceedToApp() {
    if (widget.isFromDrawer) {
      Navigator.pop(context, true);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShellScreen()),
      );
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Stack(
        children: [
          // Background ambient gradient glow
          Positioned(
            top: -100,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF6C5CE7).withValues(alpha: 0.35),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00CEC9).withValues(alpha: 0.25),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Header Logo & Branding
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE), Color(0xFF00CEC9)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6C5CE7).withValues(alpha: 0.5),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.draw_rounded, size: 38, color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'TraceCraft',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Optical AR Camera Lucida Tracing',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Glass Tab Container
                      GlassCardWidget(
                        padding: const EdgeInsets.all(4),
                        borderRadius: 16,
                        child: TabBar(
                          controller: _tabController,
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6C5CE7), Color(0xFF8C7AE6)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6C5CE7).withValues(alpha: 0.4),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.white60,
                          labelStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15),
                          tabs: const [
                            Tab(text: 'Sign In'),
                            Tab(text: 'Create Account'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Tabs Content
                      SizedBox(
                        height: 410,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildSignInTab(),
                            _buildSignUpTab(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Continue as Guest Button
                      OutlinedButton.icon(
                        onPressed: _continueAsGuest,
                        icon: const Icon(Icons.flash_on_rounded, color: Color(0xFF00CEC9), size: 18),
                        label: Text(
                          '⚡ Continue as Guest (Drawing Mode)',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00CEC9),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF00CEC9), width: 1.2),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '*Guest mode gives full access to AR tracing; account needed to publish in Community Gallery.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 11, color: Colors.white38),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInTab() {
    return GlassCardWidget(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome Back',
            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'Sign in to sync streaks & publish drawings',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _signInEmailController,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Email Address',
              prefixIcon: const Icon(Icons.email_outlined, color: Colors.white60),
              labelStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _signInPasswordController,
            obscureText: _obscureSignInPassword,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              labelText: 'Password',
              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white60),
              suffixIcon: IconButton(
                icon: Icon(_obscureSignInPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white60),
                onPressed: () => setState(() => _obscureSignInPassword = !_obscureSignInPassword),
              ),
              labelStyle: const TextStyle(color: Colors.white60),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: _isSignInLoading ? null : _handleSignIn,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF6C5CE7),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: _isSignInLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(
                    'Sign In to Account',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpTab() {
    return GlassCardWidget(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isOtpSent ? 'Verify Email with 6-Digit OTP' : 'Create Artist Account',
              style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 4),
            Text(
              _isOtpSent
                  ? 'Enter the 6-digit code sent to ${_signUpEmailController.text.trim()}'
                  : 'Enter your email to receive a 6-digit OTP verification code',
              style: GoogleFonts.inter(fontSize: 12, color: Colors.white60),
            ),
            const SizedBox(height: 14),

            // Email input
            TextField(
              controller: _signUpEmailController,
              enabled: !_isOtpSent,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Email Address',
                prefixIcon: const Icon(Icons.email_outlined, color: Colors.white60),
                suffixIcon: _isOtpSent
                    ? IconButton(
                        icon: const Icon(Icons.edit, color: Color(0xFF00CEC9), size: 18),
                        onPressed: () => setState(() => _isOtpSent = false),
                      )
                    : null,
                labelStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            if (!_isOtpSent) ...[
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _isOtpLoading ? null : _handleSendOtp,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5CE7),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isOtpLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(
                        'Send 6-Digit OTP Code',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ] else ...[
              if (_debugOtpHint != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C5CE7).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF6C5CE7).withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('OTP Code: $_debugOtpHint', style: const TextStyle(color: Color(0xFFA29BFE), fontWeight: FontWeight.bold, fontSize: 12)),
                      TextButton(
                        onPressed: () => _otpController.text = _debugOtpHint!,
                        child: const Text('Auto-Fill', style: TextStyle(color: Color(0xFF00CEC9), fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 10),

              // 6-digit OTP code field
              TextField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 18, letterSpacing: 6, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: '',
                  labelText: '6-Digit OTP Code',
                  prefixIcon: const Icon(Icons.pin_outlined, color: Colors.white60),
                  labelStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),

              // Password field
              TextField(
                controller: _signUpPasswordController,
                obscureText: _obscureSignUpPassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Set Password (min. 6 chars)',
                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white60),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureSignUpPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white60),
                    onPressed: () => setState(() => _obscureSignUpPassword = !_obscureSignUpPassword),
                  ),
                  labelStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),

              // Confirm Password field
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: const Icon(Icons.lock_reset_outlined, color: Colors.white60),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.white60),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  labelStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _resendCountdown > 0 ? null : _handleSendOtp,
                    child: Text(
                      _resendCountdown > 0 ? 'Resend in ${_resendCountdown}s' : 'Resend Code',
                      style: TextStyle(
                        color: _resendCountdown > 0 ? Colors.white38 : const Color(0xFF00CEC9),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  FilledButton(
                    onPressed: _isRegisterLoading ? null : _handleRegisterWithOtp,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5CE7),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isRegisterLoading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Text('Verify & Register', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
