import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_craft/models/session_model.dart';
import 'package:trace_craft/services/database_service.dart';

class TracingState {
  final Session? currentSession;
  final double opacity;
  final bool isLocked;
  final bool isFlippedHorizontal;
  final bool isFlippedVertical;
  final bool isEdgeDetectionEnabled;
  final bool isGridEnabled;
  final bool isTorchEnabled;

  TracingState({
    this.currentSession,
    this.opacity = 0.45,
    this.isLocked = false,
    this.isFlippedHorizontal = false,
    this.isFlippedVertical = false,
    this.isEdgeDetectionEnabled = false,
    this.isGridEnabled = false,
    this.isTorchEnabled = false,
  });

  TracingState copyWith({
    Session? currentSession,
    double? opacity,
    bool? isLocked,
    bool? isFlippedHorizontal,
    bool? isFlippedVertical,
    bool? isEdgeDetectionEnabled,
    bool? isGridEnabled,
    bool? isTorchEnabled,
  }) {
    return TracingState(
      currentSession: currentSession ?? this.currentSession,
      opacity: opacity ?? this.opacity,
      isLocked: isLocked ?? this.isLocked,
      isFlippedHorizontal: isFlippedHorizontal ?? this.isFlippedHorizontal,
      isFlippedVertical: isFlippedVertical ?? this.isFlippedVertical,
      isEdgeDetectionEnabled: isEdgeDetectionEnabled ?? this.isEdgeDetectionEnabled,
      isGridEnabled: isGridEnabled ?? this.isGridEnabled,
      isTorchEnabled: isTorchEnabled ?? this.isTorchEnabled,
    );
  }
}

final tracingProvider = StateNotifierProvider<TracingNotifier, TracingState>((ref) {
  return TracingNotifier();
});

class TracingNotifier extends StateNotifier<TracingState> {
  TracingNotifier() : super(TracingState());

  void initSession(Session session) {
    state = state.copyWith(
      currentSession: session,
      opacity: session.opacity,
      isLocked: session.isLocked,
      isFlippedHorizontal: session.isFlippedHorizontal,
      isFlippedVertical: session.isFlippedVertical,
      isEdgeDetectionEnabled: session.isEdgeDetectionEnabled,
      isGridEnabled: session.isGridEnabled,
    );
  }

  void updateOpacity(double value) {
    state = state.copyWith(opacity: value);
  }

  void toggleLock() {
    state = state.copyWith(isLocked: !state.isLocked);
  }

  void toggleGrid() {
    state = state.copyWith(isGridEnabled: !state.isGridEnabled);
  }

  void toggleEdgeDetection() {
    state = state.copyWith(isEdgeDetectionEnabled: !state.isEdgeDetectionEnabled);
  }

  void toggleTorch() {
    state = state.copyWith(isTorchEnabled: !state.isTorchEnabled);
  }

  Future<void> saveCurrentSession() async {
    if (state.currentSession != null) {
      await DatabaseService.saveSession(state.currentSession!);
    }
  }
}
