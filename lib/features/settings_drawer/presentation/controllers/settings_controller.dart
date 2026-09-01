import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_craft/core/database/hive_boxes.dart';
import 'package:trace_craft/features/settings_drawer/domain/models/user_settings.dart';

final settingsControllerProvider = StateNotifierProvider<SettingsController, UserSettings>((ref) {
  return SettingsController();
});

class SettingsController extends StateNotifier<UserSettings> {
  SettingsController() : super(HiveDatabase.getUserSettings());

  void toggleTheme() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
    _save();
  }

  void setDefaultOpacity(double val) {
    state = state.copyWith(defaultOpacity: val);
    _save();
  }

  void toggleKeepScreenOn(bool val) {
    state = state.copyWith(enableKeepScreenOn: val);
    _save();
  }

  void toggleAutoSave(bool val) {
    state = state.copyWith(autoSaveSessions: val);
    _save();
  }

  void setDefaultGridDivisions(int divisions) {
    state = state.copyWith(defaultGridDivisions: divisions);
    _save();
  }

  void toggleHaptic(bool val) {
    state = state.copyWith(hapticFeedbackEnabled: val);
    _save();
  }

  void setCustomApiKeys({String? pexelsKey, String? pixabayKey}) {
    state = state.copyWith(
      customPexelsKey: pexelsKey ?? state.customPexelsKey,
      customPixabayKey: pixabayKey ?? state.customPixabayKey,
    );
    _save();
  }

  void setOnboardingCompleted() {
    state = state.copyWith(showOnboardingTutorial: false);
    _save();
  }

  void _save() {
    HiveDatabase.saveUserSettings(state);
  }
}
