import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firestore_service.dart';
import '../providers/circle_provider.dart';

class SilenceDetectorService {
  final FirestoreService _firestoreService;

  SilenceDetectorService(this._firestoreService);

  Future<List<Map<String, dynamic>>> getSilentMembers(List<String> memberIds) async {
    final List<Map<String, dynamic>> silentMembers = [];
    final now = DateTime.now();

    for (final uid in memberIds) {
      final lastActivity = await _firestoreService.getLastActivityDate(uid);
      if (lastActivity != null) {
        final daysSilent = now.difference(lastActivity).inDays;
        if (daysSilent >= 3) {
          final user = await _firestoreService.getUser(uid);
          if (user != null) {
            silentMembers.add({
              'uid': uid,
              'name': user.name,
              'daysSilent': daysSilent,
            });
          }
        }
      } else {
        // No activity ever, maybe just joined, but let's count it if they joined long ago
      }
    }
    return silentMembers;
  }
}

final silenceDetectorProvider = Provider<SilenceDetectorService>((ref) {
  return SilenceDetectorService(ref.read(firestoreServiceProvider));
});
