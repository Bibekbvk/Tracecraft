import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class StreakRecord extends HiveObject {
  @HiveField(0)
  final int currentStreakDays;

  @HiveField(1)
  final int maxStreakDays;

  @HiveField(2)
  final int totalDrawingsCompleted;

  @HiveField(3)
  final DateTime? lastDrawnDate;

  @HiveField(4)
  final List<String> unlockedBadgeIds;

  StreakRecord({
    this.currentStreakDays = 0,
    this.maxStreakDays = 0,
    this.totalDrawingsCompleted = 0,
    this.lastDrawnDate,
    this.unlockedBadgeIds = const [],
  });

  StreakRecord copyWith({
    int? currentStreakDays,
    int? maxStreakDays,
    int? totalDrawingsCompleted,
    DateTime? lastDrawnDate,
    List<String>? unlockedBadgeIds,
  }) {
    return StreakRecord(
      currentStreakDays: currentStreakDays ?? this.currentStreakDays,
      maxStreakDays: maxStreakDays ?? this.maxStreakDays,
      totalDrawingsCompleted: totalDrawingsCompleted ?? this.totalDrawingsCompleted,
      lastDrawnDate: lastDrawnDate ?? this.lastDrawnDate,
      unlockedBadgeIds: unlockedBadgeIds ?? this.unlockedBadgeIds,
    );
  }
}

/// Hive TypeAdapter for StreakRecord
class StreakRecordAdapter extends TypeAdapter<StreakRecord> {
  @override
  final int typeId = 2;

  @override
  StreakRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StreakRecord(
      currentStreakDays: fields[0] as int,
      maxStreakDays: fields[1] as int,
      totalDrawingsCompleted: fields[2] as int,
      lastDrawnDate: fields[3] != null ? DateTime.fromMillisecondsSinceEpoch(fields[3] as int) : null,
      unlockedBadgeIds: (fields[4] as List?)?.cast<String>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, StreakRecord obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.currentStreakDays)
      ..writeByte(1)
      ..write(obj.maxStreakDays)
      ..writeByte(2)
      ..write(obj.totalDrawingsCompleted)
      ..writeByte(3)
      ..write(obj.lastDrawnDate?.millisecondsSinceEpoch)
      ..writeByte(4)
      ..write(obj.unlockedBadgeIds);
  }
}

class AchievementBadge {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color badgeColor;
  final int requiredCount;
  final String category;

  const AchievementBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.badgeColor,
    required this.requiredCount,
    required this.category,
  });

  static const List<AchievementBadge> allBadges = [
    AchievementBadge(
      id: 'first_stroke',
      title: 'First Stroke',
      description: 'Completed your very first drawing project',
      icon: Icons.brush_rounded,
      badgeColor: Color(0xFF6C5CE7),
      requiredCount: 1,
      category: 'drawings',
    ),
    AchievementBadge(
      id: 'three_day_streak',
      title: 'Artisan Discipline',
      description: 'Maintained a 3-day consecutive drawing streak',
      icon: Icons.local_fire_department_rounded,
      badgeColor: Color(0xFFFF7675),
      requiredCount: 3,
      category: 'streak',
    ),
    AchievementBadge(
      id: 'seven_day_streak',
      title: 'Master of Consistency',
      description: 'Maintained a 7-day drawing streak',
      icon: Icons.workspace_premium_rounded,
      badgeColor: Color(0xFFFFB300),
      requiredCount: 7,
      category: 'streak',
    ),
  ];
}
