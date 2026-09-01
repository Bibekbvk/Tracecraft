import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:trace_craft/app.dart';
import 'package:trace_craft/models/session_model.dart';
import 'package:trace_craft/models/streak_model.dart';
import 'package:trace_craft/models/user_settings_model.dart';
import 'package:trace_craft/services/database_service.dart';

void main() {
  setUpAll(() async {
    final tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);

    Hive.registerAdapter(SessionAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(StreakRecordAdapter());

    DatabaseService.settingsBox = await Hive.openBox<UserSettings>('settings_test_box');
    DatabaseService.sessionsBox = await Hive.openBox<Session>('sessions_test_box');
    DatabaseService.streakBox = await Hive.openBox<StreakRecord>('streak_test_box');
    DatabaseService.favoritesBox = await Hive.openBox<Map>('favorites_test_box');

    await DatabaseService.settingsBox.put('current', UserSettings());
    await DatabaseService.streakBox.put('current', StreakRecord());
  });

  testWidgets('TraceCraftApp scaffolding smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TraceCraftApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 2000));
    expect(find.byType(TraceCraftApp), findsOneWidget);
  });
}
