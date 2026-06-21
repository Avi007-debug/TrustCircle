import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/models/pulse_model.dart';
import 'auth_provider.dart';
import 'circle_provider.dart';

/// Has the current user already submitted a pulse today for the active circle?
final hasPulsedTodayProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  final circle = ref.watch(activeCircleProvider);
  if (user == null || circle == null) return false;

  return ref.read(firestoreServiceProvider).hasSubmittedPulseToday(
        userId: user.uid,
        circleId: circle.id,
      );
});

/// Last 7 days of pulses for the current user + active circle
final weeklyPulsesProvider = FutureProvider<List<PulseModel>>((ref) async {
  final user = ref.watch(authStateProvider).asData?.value;
  final circle = ref.watch(activeCircleProvider);
  if (user == null || circle == null) return [];

  return ref.read(firestoreServiceProvider).getLast7DaysPulses(
        userId: user.uid,
        circleId: circle.id,
      );
});

/// Circle-wide pulses for computing overall trust score
final circlePulsesProvider = FutureProvider<List<PulseModel>>((ref) async {
  final circle = ref.watch(activeCircleProvider);
  if (circle == null) return [];

  return ref
      .read(firestoreServiceProvider)
      .getCirclePulses(circleId: circle.id);
});

/// Computed average trust score for the active circle (0–100)
final circleTrustScoreProvider = Provider<double>((ref) {
  final pulses = ref.watch(circlePulsesProvider).asData?.value ?? [];
  if (pulses.isEmpty) return 0.0;
  final total = pulses.map((p) => p.trustScore).reduce((a, b) => a + b);
  return total / pulses.length;
});

/// Computed average trust score for the current user (0-100)
final individualTrustScoreProvider = Provider<double>((ref) {
  final pulses = ref.watch(weeklyPulsesProvider).asData?.value ?? [];
  if (pulses.isEmpty) return 0.0;
  final total = pulses.map((p) => p.trustScore).reduce((a, b) => a + b);
  return total / pulses.length;
});

/// Grouped daily averages for the circle trend graph
final circleDailyAveragesProvider = Provider<List<FlSpot>>((ref) {
  final pulses = ref.watch(circlePulsesProvider).asData?.value ?? [];
  if (pulses.isEmpty) return [];

  // Group by day (YYYY-MM-DD)
  final Map<String, List<double>> grouped = {};
  for (final p in pulses) {
    final dateKey = "${p.timestamp.year}-${p.timestamp.month.toString().padLeft(2, '0')}-${p.timestamp.day.toString().padLeft(2, '0')}";
    grouped.putIfAbsent(dateKey, () => []).add(p.trustScore);
  }

  // Sort keys chronologically
  final sortedKeys = grouped.keys.toList()..sort();
  
  // Create spots
  final List<FlSpot> spots = [];
  for (int i = 0; i < sortedKeys.length; i++) {
    final scores = grouped[sortedKeys[i]]!;
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    spots.add(FlSpot(i.toDouble(), avg));
  }
  return spots;
});

/// Corresponding dates for the circle trend graph's X-axis
final circleDailyDatesProvider = Provider<List<DateTime>>((ref) {
  final pulses = ref.watch(circlePulsesProvider).asData?.value ?? [];
  if (pulses.isEmpty) return [];

  final Map<String, DateTime> grouped = {};
  for (final p in pulses) {
    final dateKey = "${p.timestamp.year}-${p.timestamp.month.toString().padLeft(2, '0')}-${p.timestamp.day.toString().padLeft(2, '0')}";
    if (!grouped.containsKey(dateKey)) grouped[dateKey] = p.timestamp;
  }

  final sortedKeys = grouped.keys.toList()..sort();
  return sortedKeys.map((k) => grouped[k]!).toList();
});

/// Trend: 'Improving', 'Stable', or 'Declining'
final trustTrendProvider = Provider<String>((ref) {
  final pulses = ref.watch(weeklyPulsesProvider).asData?.value ?? [];
  if (pulses.length < 2) return 'Stable';

  final firstHalf = pulses.take(pulses.length ~/ 2).toList();
  final secondHalf = pulses.skip(pulses.length ~/ 2).toList();

  final firstAvg =
      firstHalf.map((p) => p.trustScore).reduce((a, b) => a + b) / firstHalf.length;
  final secondAvg =
      secondHalf.map((p) => p.trustScore).reduce((a, b) => a + b) / secondHalf.length;

  final diff = secondAvg - firstAvg;
  if (diff >= 3) return 'Improving';
  if (diff <= -3) return 'Declining';
  return 'Stable';
});
