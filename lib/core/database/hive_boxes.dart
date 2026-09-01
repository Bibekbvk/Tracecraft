import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trace_craft/core/constants/app_constants.dart';
import 'package:trace_craft/features/settings_drawer/domain/models/user_settings.dart';
import 'package:trace_craft/features/streak_achievements/domain/models/achievement_badge.dart';
import 'package:trace_craft/features/tracing/domain/models/tracing_session.dart';

class HiveDatabase {
  static late Box<UserSettings> settingsBox;
  static late Box<TracingSession> sessionsBox;
  static late Box<StreakRecord> streakBox;
  static late Box<Map> favoritesBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register TypeAdapters
    Hive.registerAdapter(TracingSessionAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(StreakRecordAdapter());

    // Open Boxes
    settingsBox = await Hive.openBox<UserSettings>(AppConstants.settingsBox);
    sessionsBox = await Hive.openBox<TracingSession>(AppConstants.sessionsBox);
    streakBox = await Hive.openBox<StreakRecord>(AppConstants.streakBox);
    favoritesBox = await Hive.openBox<Map>(AppConstants.favoritesBox);

    // Initialize default settings if empty
    if (settingsBox.isEmpty) {
      await settingsBox.put('current', UserSettings());
    }

    // Initialize default streak if empty
    if (streakBox.isEmpty) {
      await streakBox.put(
        'current',
        StreakRecord(
          currentStreakDays: 1,
          maxStreakDays: 1,
          totalDrawingsCompleted: 0,
          lastDrawnDate: DateTime.now(),
          unlockedBadgeIds: [],
        ),
      );
    }

    debugPrint('Hive database initialized with ${sessionsBox.length} saved sessions.');
  }

  static UserSettings getUserSettings() {
    return settingsBox.get('current') ?? UserSettings();
  }

  static Future<void> saveUserSettings(UserSettings settings) async {
    await settingsBox.put('current', settings);
  }

  static StreakRecord getStreakRecord() {
    return streakBox.get('current') ?? StreakRecord();
  }

  static Future<void> saveStreakRecord(StreakRecord record) async {
    await streakBox.put('current', record);
  }
}
