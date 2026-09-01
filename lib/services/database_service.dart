import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trace_craft/models/session_model.dart';
import 'package:trace_craft/models/streak_model.dart';
import 'package:trace_craft/models/user_settings_model.dart';

class DatabaseService {
  static const String settingsBoxName = 'settings_box';
  static const String sessionsBoxName = 'sessions_box';
  static const String streakBoxName = 'streak_box';
  static const String favoritesBoxName = 'favorites_box';

  static late Box<UserSettings> settingsBox;
  static late Box<Session> sessionsBox;
  static late Box<StreakRecord> streakBox;
  static late Box<Map> favoritesBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Hive Adapters
    Hive.registerAdapter(SessionAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(StreakRecordAdapter());

    // Open persistent boxes
    settingsBox = await Hive.openBox<UserSettings>(settingsBoxName);
    sessionsBox = await Hive.openBox<Session>(sessionsBoxName);
    streakBox = await Hive.openBox<StreakRecord>(streakBoxName);
    favoritesBox = await Hive.openBox<Map>(favoritesBoxName);

    // Populate defaults if empty
    if (settingsBox.isEmpty) {
      await settingsBox.put('current', UserSettings(currentStreakDays: 1, totalDrawingsCompleted: 0, lastDrawnDate: DateTime.now()));
    }
    if (streakBox.isEmpty) {
      await streakBox.put('current', StreakRecord(currentStreakDays: 1, maxStreakDays: 1));
    }

    debugPrint('DatabaseService: Hive initialized (${sessionsBox.length} saved sessions).');
  }

  static UserSettings getUserSettings() {
    return settingsBox.get('current') ?? UserSettings();
  }

  static Future<void> saveUserSettings(UserSettings settings) async {
    await settingsBox.put('current', settings);
  }

  static List<Session> getAllSessions() {
    final list = sessionsBox.values.toList();
    list.sort((a, b) => b.lastModifiedAt.compareTo(a.lastModifiedAt));
    return list;
  }

  static Future<void> saveSession(Session session) async {
    await sessionsBox.put(session.id, session);
    // Update daily streak
    await recordDrawingSession(isCompleted: session.isCompleted);
  }

  static Future<void> deleteSession(String id) async {
    await sessionsBox.delete(id);
  }

  /// Calculates and updates consecutive daily streak in UserSettings
  static Future<UserSettings> recordDrawingSession({bool isCompleted = false}) async {
    final settings = getUserSettings();
    final now = DateTime.now();
    int newStreak = settings.currentStreakDays;

    if (settings.lastDrawnDate == null) {
      newStreak = 1;
    } else {
      final lastDate = DateTime(
        settings.lastDrawnDate!.year,
        settings.lastDrawnDate!.month,
        settings.lastDrawnDate!.day,
      );
      final today = DateTime(now.year, now.month, now.day);
      final difference = today.difference(lastDate).inDays;

      if (difference == 1) {
        newStreak += 1;
      } else if (difference > 1) {
        newStreak = 1;
      }
    }

    final updated = settings.copyWith(
      currentStreakDays: newStreak,
      totalDrawingsCompleted: isCompleted ? settings.totalDrawingsCompleted + 1 : settings.totalDrawingsCompleted,
      lastDrawnDate: now,
    );

    await saveUserSettings(updated);
    return updated;
  }
}
