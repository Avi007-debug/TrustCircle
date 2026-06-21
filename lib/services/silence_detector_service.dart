import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firestore_service.dart';
import 'notification_service.dart';
import '../providers/circle_provider.dart';
import '../data/models/user_model.dart';

class SilenceDetectorService {
  final FirestoreService _firestoreService;

  SilenceDetectorService(this._firestoreService);

  /// Checks all members of a circle for silence (no pulse in 3+ days).
  /// The "day" boundary is 8 PM (configurable in NotificationService.dayStartHour).
  /// Returns a list of maps with 'uid', 'name', 'daysSilent'.
  /// Also fires a push notification for each silent member.
  Future<List<Map<String, dynamic>>> getSilentMembers(List<String> memberIds) async {
    final List<Map<String, dynamic>> silentMembers = [];
    final now = DateTime.now();

    for (final uid in memberIds) {
      final lastActivity = await _firestoreService.getLastActivityDate(uid);

      int daysSilent = 0;

      if (lastActivity != null) {
        // Adjust for "day starts at 8 PM" logic:
        // If it's past 8 PM, the current trust-day started at today 8 PM.
        // If it's before 8 PM, the current trust-day started at yesterday 8 PM.
        final dayStartHour = NotificationService.dayStartHour;
        DateTime currentDayStart;
        if (now.hour >= dayStartHour) {
          currentDayStart = DateTime(now.year, now.month, now.day, dayStartHour);
        } else {
          currentDayStart = DateTime(now.year, now.month, now.day, dayStartHour)
              .subtract(const Duration(days: 1));
        }

        daysSilent = currentDayStart.difference(lastActivity).inDays;
      } else {
        // Never submitted a pulse — treat as 999 days silent
        daysSilent = 999;
      }

      if (daysSilent >= 3) {
        final UserModel? user = await _firestoreService.getUser(uid);
        if (user != null) {
          final name = user.name.isNotEmpty ? user.name : 'A member';
          silentMembers.add({
            'uid': uid,
            'name': name,
            'daysSilent': daysSilent,
          });

          // Fire a push notification for this silent member
          await notificationService.showSilenceAlert(name, daysSilent);
        }
      }
    }
    return silentMembers;
  }
}

final silenceDetectorProvider = Provider<SilenceDetectorService>((ref) {
  return SilenceDetectorService(ref.read(firestoreServiceProvider));
});
