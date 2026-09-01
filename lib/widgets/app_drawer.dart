import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:trace_craft/models/user_settings_model.dart';
import 'package:trace_craft/screens/about_screen.dart';
import 'package:trace_craft/screens/auth_screen.dart';
import 'package:trace_craft/screens/contact_screen.dart';
import 'package:trace_craft/screens/feedback_screen.dart';
import 'package:trace_craft/screens/onboarding_tutorial_screen.dart';
import 'package:trace_craft/screens/settings_screen.dart';
import 'package:trace_craft/services/database_service.dart';
import 'package:trace_craft/services/firebase_auth_service.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  @override
  Widget build(BuildContext context) {
    final UserSettings settings = DatabaseService.getUserSettings();
    final isGuest = FirebaseAuthService.isGuest;
    final userEmail = FirebaseAuthService.currentUserEmail;

    return Drawer(
      backgroundColor: const Color(0xFF141720),
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 20, 20, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF4834D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.draw_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isGuest ? 'Guest Artist' : (userEmail?.split('@').first ?? 'Artist'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            isGuest ? '⚡ Drawing Mode (No Gallery)' : (userEmail ?? 'Verified Account'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(fontSize: 11, color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF7675), size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${settings.currentStreakDays} Day Streak',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 10),
                      const Text('|', style: TextStyle(color: Colors.white30)),
                      const SizedBox(width: 10),
                      Text(
                        '${settings.totalDrawingsCompleted} Completed',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Drawer Navigation List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              children: [
                if (isGuest)
                  _buildDrawerItem(
                    context,
                    icon: Icons.person_add_alt_1_rounded,
                    iconColor: const Color(0xFF00CEC9),
                    title: 'Sign In / Register with OTP',
                    onTap: () async {
                      Navigator.pop(context);
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AuthScreen(isFromDrawer: true)),
                      );
                      setState(() {});
                    },
                  )
                else
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout_rounded,
                    iconColor: const Color(0xFFFF7675),
                    title: 'Sign Out ($userEmail)',
                    onTap: () async {
                      Navigator.pop(context);
                      await FirebaseAuthService.signOut();
                      setState(() {});
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Signed out. Reverted to Guest Mode.')),
                        );
                      }
                    },
                  ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Divider(color: Colors.white12),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.school_rounded,
                  iconColor: const Color(0xFF00CEC9),
                  title: 'How to Trace (Tutorial)',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnboardingTutorialScreen(isFromDrawer: true),
                      ),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.info_outline_rounded,
                  iconColor: const Color(0xFFA29BFE),
                  title: 'About Us',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AboutScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.alternate_email_rounded,
                  iconColor: const Color(0xFFFF7675),
                  title: 'Contact Us',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ContactScreen()),
                    );
                  },
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.feedback_outlined,
                  iconColor: const Color(0xFFFFB300),
                  title: 'Send Feedback',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FeedbackScreen()),
                    );
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Divider(color: Colors.white12),
                ),
                _buildDrawerItem(
                  context,
                  icon: Icons.settings_outlined,
                  iconColor: Colors.white70,
                  title: 'Settings & Preferences',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // Footer
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'TraceCraft v1.0.0 • Optical Tracing Assistant',
              style: TextStyle(fontSize: 11, color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white24, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onTap: onTap,
    );
  }
}
