import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:trace_craft/screens/community_gallery_screen.dart';
import 'package:trace_craft/screens/image_search_screen.dart';
import 'package:trace_craft/screens/onboarding_tutorial_screen.dart';
import 'package:trace_craft/screens/projects_screen.dart';
import 'package:trace_craft/screens/streak_screen.dart';
import 'package:trace_craft/screens/tracing_screen.dart';
import 'package:trace_craft/services/database_service.dart';
import 'package:trace_craft/widgets/app_drawer.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ImageSearchScreen(),
    ProjectsScreen(),
    CommunityGalleryScreen(),
    StreakScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Check if onboarding tutorial should be shown on first launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFirstLaunchTutorial();
    });
  }

  void _checkFirstLaunchTutorial() {
    final settings = DatabaseService.getUserSettings();
    if (settings.showOnboardingTutorial) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const OnboardingTutorialScreen(isFromDrawer: false),
        ),
      );
    }
  }

  void _openLiveTracingCamera() {
    HapticFeedback.mediumImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const TracingScreen(
          title: 'Quick Camera Tracing',
          imagePathOrUrl: 'https://images.pexels.com/photos/1858175/pexels-photo-1858175.jpeg?auto=compress&cs=tinysrgb&w=800',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6C5CE7),
        foregroundColor: Colors.white,
        elevation: 6,
        icon: const Icon(Icons.camera_alt_rounded, size: 22),
        label: const Text(
          'Open Camera & Trace',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
        onPressed: _openLiveTracingCamera,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: 'Gallery',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_fire_department_outlined),
            selectedIcon: Icon(Icons.local_fire_department),
            label: 'Streaks',
          ),
        ],
      ),
    );
  }
}
