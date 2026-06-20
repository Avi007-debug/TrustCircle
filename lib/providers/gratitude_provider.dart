import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/gratitude_model.dart';
import 'circle_provider.dart';

/// Live stream of gratitude posts for the active circle
final gratitudeFeedProvider = StreamProvider<List<GratitudeModel>>((ref) {
  final circle = ref.watch(activeCircleProvider);
  if (circle == null) return const Stream.empty();

  return ref.read(firestoreServiceProvider).getGratitudeFeed(circle.id);
});

final gratitudeCountProvider = Provider<int>((ref) {
  final list = ref.watch(gratitudeFeedProvider).asData?.value;
  return list?.length ?? 0;
});
