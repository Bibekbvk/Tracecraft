import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_craft/models/user_settings_model.dart';
import 'package:trace_craft/services/database_service.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, UserSettings>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<UserSettings> {
  SettingsNotifier() : super(DatabaseService.getUserSettings());

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    DatabaseService.saveUserSettings(state);
  }

  void setOpacity(double opacity) {
    state = state.copyWith(defaultOpacity: opacity);
    DatabaseService.saveUserSettings(state);
  }

  void setKeepScreenOn(bool val) {
    state = state.copyWith(enableKeepScreenOn: val);
    DatabaseService.saveUserSettings(state);
  }
}
