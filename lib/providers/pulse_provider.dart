import 'package:flutter_riverpod/flutter_riverpod.dart';
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
