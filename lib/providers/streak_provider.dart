import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trace_craft/models/streak_model.dart';
import 'package:trace_craft/services/database_service.dart';

final streakProvider = StateNotifierProvider<StreakNotifier, StreakRecord>((ref) {
  return StreakNotifier();
});

class StreakNotifier extends StateNotifier<StreakRecord> {
  StreakNotifier() : super(DatabaseService.streakBox.get('current') ?? StreakRecord());

  void incrementStreak() {
    final updated = state.copyWith(
      currentStreakDays: state.currentStreakDays + 1,
      totalDrawingsCompleted: state.totalDrawingsCompleted + 1,
      lastDrawnDate: DateTime.now(),
    );
    state = updated;
    DatabaseService.streakBox.put('current', updated);
  }
}
