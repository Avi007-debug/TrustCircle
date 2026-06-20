import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../data/models/circle_model.dart';
import 'auth_provider.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

/// Active circle ID chosen by the user (persists during session)
final activeCircleIdProvider = NotifierProvider<_ActiveCircleNotifier, String?>(
  _ActiveCircleNotifier.new,
);

class _ActiveCircleNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? id) => state = id;
}

/// Stream of all circles the current user belongs to
final userCirclesProvider = StreamProvider<List<CircleModel>>((ref) {
  final authState = ref.watch(authStateProvider);
  final user = authState.asData?.value;
  if (user == null) return const Stream.empty();
  return ref.read(firestoreServiceProvider).getUserCircles(user.uid);
});

/// The currently active circle model
final activeCircleProvider = Provider<CircleModel?>((ref) {
  final activeId = ref.watch(activeCircleIdProvider);
  final circles = ref.watch(userCirclesProvider).asData?.value ?? [];
  if (circles.isEmpty) return null;
  if (activeId != null) {
    return circles.firstWhere(
      (c) => c.id == activeId,
      orElse: () => circles.first,
    );
  }
  return circles.first;
});
