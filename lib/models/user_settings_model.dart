import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class UserSettings extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final double defaultOpacity;

  @HiveField(2)
  final bool enableKeepScreenOn;

  @HiveField(3)
  final bool autoSaveSessions;

  @HiveField(4)
  final bool showOnboardingTutorial;

  @HiveField(5)
  final int defaultGridDivisions;

  @HiveField(6)
  final bool hapticFeedbackEnabled;

  @HiveField(7)
  final bool isProMember;

  @HiveField(8)
  final String customPexelsKey;

  @HiveField(9)
  final String customPixabayKey;

  @HiveField(10)
  final int currentStreakDays;

  @HiveField(11)
  final int totalDrawingsCompleted;

  @HiveField(12)
  final DateTime? lastDrawnDate;

  @HiveField(13)
  final DateTime? adsRemovedUntil;

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
    this.currentStreakDays = 1,
    this.totalDrawingsCompleted = 0,
    this.lastDrawnDate,
    this.adsRemovedUntil,
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
    int? currentStreakDays,
    int? totalDrawingsCompleted,
    DateTime? lastDrawnDate,
    DateTime? adsRemovedUntil,
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
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      totalDrawingsCompleted: totalDrawingsCompleted ?? this.totalDrawingsCompleted,
      lastDrawnDate: lastDrawnDate ?? this.lastDrawnDate,
      adsRemovedUntil: adsRemovedUntil ?? this.adsRemovedUntil,
    );
  }
}

/// Hive TypeAdapter for UserSettings
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
      currentStreakDays: (fields[10] as int?) ?? 1,
      totalDrawingsCompleted: (fields[11] as int?) ?? 0,
      lastDrawnDate: fields[12] != null ? DateTime.fromMillisecondsSinceEpoch(fields[12] as int) : null,
      adsRemovedUntil: fields[13] != null ? DateTime.fromMillisecondsSinceEpoch(fields[13] as int) : null,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(14)
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
      ..write(obj.customPixabayKey)
      ..writeByte(10)
      ..write(obj.currentStreakDays)
      ..writeByte(11)
      ..write(obj.totalDrawingsCompleted)
      ..writeByte(12)
      ..write(obj.lastDrawnDate?.millisecondsSinceEpoch)
      ..writeByte(13)
      ..write(obj.adsRemovedUntil?.millisecondsSinceEpoch);
  }
}
