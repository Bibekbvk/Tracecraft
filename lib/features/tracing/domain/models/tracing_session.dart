import 'package:hive/hive.dart';

class TracingSession extends HiveObject {
  final String id;
  final String title;
  final String sourceImagePath; // Local file path or cached image URL
  final String? localThumbnailPath; // Rendered snap of drawing/session
  final double opacity; // 0.0 - 1.0 (default 0.45)
  final List<double> matrix4Values; // 16 values representing 4x4 Transformation Matrix
  final bool isLocked;
  final bool isFlippedHorizontal;
  final bool isFlippedVertical;
  final bool isEdgeDetectionEnabled;
  final double edgeThreshold; // 0.0 - 1.0
  final bool isGridEnabled;
  final int gridDivision; // e.g. 3 (3x3), 4 (4x4), 8 (8x8)
  final int gridColorValue; // ARGB int
  final DateTime createdAt;
  final DateTime lastModifiedAt;
  final bool isCompleted;
  final int drawingTimeSeconds;

  TracingSession({
    required this.id,
    required this.title,
    required this.sourceImagePath,
    this.localThumbnailPath,
    this.opacity = 0.45,
    required this.matrix4Values,
    this.isLocked = false,
    this.isFlippedHorizontal = false,
    this.isFlippedVertical = false,
    this.isEdgeDetectionEnabled = false,
    this.edgeThreshold = 0.5,
    this.isGridEnabled = false,
    this.gridDivision = 3,
    this.gridColorValue = 0x9900CEC9,
    required this.createdAt,
    required this.lastModifiedAt,
    this.isCompleted = false,
    this.drawingTimeSeconds = 0,
  });

  TracingSession copyWith({
    String? title,
    String? sourceImagePath,
    String? localThumbnailPath,
    double? opacity,
    List<double>? matrix4Values,
    bool? isLocked,
    bool? isFlippedHorizontal,
    bool? isFlippedVertical,
    bool? isEdgeDetectionEnabled,
    double? edgeThreshold,
    bool? isGridEnabled,
    int? gridDivision,
    int? gridColorValue,
    DateTime? lastModifiedAt,
    bool? isCompleted,
    int? drawingTimeSeconds,
  }) {
    return TracingSession(
      id: id,
      title: title ?? this.title,
      sourceImagePath: sourceImagePath ?? this.sourceImagePath,
      localThumbnailPath: localThumbnailPath ?? this.localThumbnailPath,
      opacity: opacity ?? this.opacity,
      matrix4Values: matrix4Values ?? this.matrix4Values,
      isLocked: isLocked ?? this.isLocked,
      isFlippedHorizontal: isFlippedHorizontal ?? this.isFlippedHorizontal,
      isFlippedVertical: isFlippedVertical ?? this.isFlippedVertical,
      isEdgeDetectionEnabled: isEdgeDetectionEnabled ?? this.isEdgeDetectionEnabled,
      edgeThreshold: edgeThreshold ?? this.edgeThreshold,
      isGridEnabled: isGridEnabled ?? this.isGridEnabled,
      gridDivision: gridDivision ?? this.gridDivision,
      gridColorValue: gridColorValue ?? this.gridColorValue,
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      drawingTimeSeconds: drawingTimeSeconds ?? this.drawingTimeSeconds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'sourceImagePath': sourceImagePath,
      'localThumbnailPath': localThumbnailPath,
      'opacity': opacity,
      'matrix4Values': matrix4Values,
      'isLocked': isLocked,
      'isFlippedHorizontal': isFlippedHorizontal,
      'isFlippedVertical': isFlippedVertical,
      'isEdgeDetectionEnabled': isEdgeDetectionEnabled,
      'edgeThreshold': edgeThreshold,
      'isGridEnabled': isGridEnabled,
      'gridDivision': gridDivision,
      'gridColorValue': gridColorValue,
      'createdAt': createdAt.toIso8601String(),
      'lastModifiedAt': lastModifiedAt.toIso8601String(),
      'isCompleted': isCompleted,
      'drawingTimeSeconds': drawingTimeSeconds,
    };
  }

  factory TracingSession.fromMap(Map<dynamic, dynamic> map) {
    return TracingSession(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Untitled Session',
      sourceImagePath: map['sourceImagePath'] ?? '',
      localThumbnailPath: map['localThumbnailPath'],
      opacity: (map['opacity'] as num?)?.toDouble() ?? 0.45,
      matrix4Values: (map['matrix4Values'] as List?)?.map((e) => (e as num).toDouble()).toList() ??
          [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1],
      isLocked: map['isLocked'] ?? false,
      isFlippedHorizontal: map['isFlippedHorizontal'] ?? false,
      isFlippedVertical: map['isFlippedVertical'] ?? false,
      isEdgeDetectionEnabled: map['isEdgeDetectionEnabled'] ?? false,
      edgeThreshold: (map['edgeThreshold'] as num?)?.toDouble() ?? 0.5,
      isGridEnabled: map['isGridEnabled'] ?? false,
      gridDivision: map['gridDivision'] ?? 3,
      gridColorValue: map['gridColorValue'] ?? 0x9900CEC9,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      lastModifiedAt: map['lastModifiedAt'] != null ? DateTime.parse(map['lastModifiedAt']) : DateTime.now(),
      isCompleted: map['isCompleted'] ?? false,
      drawingTimeSeconds: map['drawingTimeSeconds'] ?? 0,
    );
  }
}

/// TypeAdapter for Hive persistence of TracingSession
class TracingSessionAdapter extends TypeAdapter<TracingSession> {
  @override
  final int typeId = 0;

  @override
  TracingSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TracingSession(
      id: fields[0] as String,
      title: fields[1] as String,
      sourceImagePath: fields[2] as String,
      localThumbnailPath: fields[3] as String?,
      opacity: (fields[4] as num).toDouble(),
      matrix4Values: (fields[5] as List).cast<double>(),
      isLocked: fields[6] as bool,
      isFlippedHorizontal: fields[7] as bool,
      isFlippedVertical: fields[8] as bool,
      isEdgeDetectionEnabled: fields[9] as bool,
      edgeThreshold: (fields[10] as num).toDouble(),
      isGridEnabled: fields[11] as bool,
      gridDivision: fields[12] as int,
      gridColorValue: fields[13] as int,
      createdAt: DateTime.fromMillisecondsSinceEpoch(fields[14] as int),
      lastModifiedAt: DateTime.fromMillisecondsSinceEpoch(fields[15] as int),
      isCompleted: fields[16] as bool,
      drawingTimeSeconds: (fields[17] as int?) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, TracingSession obj) {
    writer
      ..writeByte(18)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.sourceImagePath)
      ..writeByte(3)
      ..write(obj.localThumbnailPath)
      ..writeByte(4)
      ..write(obj.opacity)
      ..writeByte(5)
      ..write(obj.matrix4Values)
      ..writeByte(6)
      ..write(obj.isLocked)
      ..writeByte(7)
      ..write(obj.isFlippedHorizontal)
      ..writeByte(8)
      ..write(obj.isFlippedVertical)
      ..writeByte(9)
      ..write(obj.isEdgeDetectionEnabled)
      ..writeByte(10)
      ..write(obj.edgeThreshold)
      ..writeByte(11)
      ..write(obj.isGridEnabled)
      ..writeByte(12)
      ..write(obj.gridDivision)
      ..writeByte(13)
      ..write(obj.gridColorValue)
      ..writeByte(14)
      ..write(obj.createdAt.millisecondsSinceEpoch)
      ..writeByte(15)
      ..write(obj.lastModifiedAt.millisecondsSinceEpoch)
      ..writeByte(16)
      ..write(obj.isCompleted)
      ..writeByte(17)
      ..write(obj.drawingTimeSeconds);
  }
}
