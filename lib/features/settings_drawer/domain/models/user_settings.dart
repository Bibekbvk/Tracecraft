import 'package:hive/hive.dart';

class UserSettings extends HiveObject {
  final bool isDarkMode;
  final double defaultOpacity;
  final bool enableKeepScreenOn;
  final bool autoSaveSessions;
  final bool showOnboardingTutorial;
  final int defaultGridDivisions;
  final bool hapticFeedbackEnabled;
  final bool isProMember;
  final String customPexelsKey;
  final String customPixabayKey;

  UserSettings({
    this.isDarkMode = true,
    this.defaultOpacity = 0.45,
    this.enableKeepScreenOn = true,
    this.autoSaveSessions = true,
    this.showOnboardingTutorial = true,
    this.defaultGridDivisions = 3,
    this.hapticFeedbackEnabled = true,
    this.isProMember = false,
    this.customPexelsKey = '',
    this.customPixabayKey = '',
  });

  UserSettings copyWith({
    bool? isDarkMode,
    double? defaultOpacity,
    bool? enableKeepScreenOn,
    bool? autoSaveSessions,
    bool? showOnboardingTutorial,
    int? defaultGridDivisions,
    bool? hapticFeedbackEnabled,
    bool? isProMember,
    String? customPexelsKey,
    String? customPixabayKey,
  }) {
    return UserSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      defaultOpacity: defaultOpacity ?? this.defaultOpacity,
      enableKeepScreenOn: enableKeepScreenOn ?? this.enableKeepScreenOn,
      autoSaveSessions: autoSaveSessions ?? this.autoSaveSessions,
      showOnboardingTutorial: showOnboardingTutorial ?? this.showOnboardingTutorial,
      defaultGridDivisions: defaultGridDivisions ?? this.defaultGridDivisions,
      hapticFeedbackEnabled: hapticFeedbackEnabled ?? this.hapticFeedbackEnabled,
      isProMember: isProMember ?? this.isProMember,
      customPexelsKey: customPexelsKey ?? this.customPexelsKey,
      customPixabayKey: customPixabayKey ?? this.customPixabayKey,
    );
  }
}

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 1;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      isDarkMode: (fields[0] as bool?) ?? true,
      defaultOpacity: (fields[1] as num?)?.toDouble() ?? 0.45,
      enableKeepScreenOn: (fields[2] as bool?) ?? true,
      autoSaveSessions: (fields[3] as bool?) ?? true,
      showOnboardingTutorial: (fields[4] as bool?) ?? true,
      defaultGridDivisions: (fields[5] as int?) ?? 3,
      hapticFeedbackEnabled: (fields[6] as bool?) ?? true,
      isProMember: (fields[7] as bool?) ?? false,
      customPexelsKey: (fields[8] as String?) ?? '',
      customPixabayKey: (fields[9] as String?) ?? '',
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.defaultOpacity)
      ..writeByte(2)
      ..write(obj.enableKeepScreenOn)
      ..writeByte(3)
      ..write(obj.autoSaveSessions)
      ..writeByte(4)
      ..write(obj.showOnboardingTutorial)
      ..writeByte(5)
      ..write(obj.defaultGridDivisions)
      ..writeByte(6)
      ..write(obj.hapticFeedbackEnabled)
      ..writeByte(7)
      ..write(obj.isProMember)
      ..writeByte(8)
      ..write(obj.customPexelsKey)
      ..writeByte(9)
      ..write(obj.customPixabayKey);
  }
}
