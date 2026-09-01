import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_craft/core/theme/app_theme.dart';
import 'package:trace_craft/providers/settings_provider.dart';
import 'package:trace_craft/screens/splash_screen.dart';

class TraceCraftApp extends ConsumerWidget {
  const TraceCraftApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'TraceCraft - Camera Lucida Tracing',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
