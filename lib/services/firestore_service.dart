import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../data/models/circle_model.dart';
import '../data/models/pulse_model.dart';
import '../data/models/gratitude_model.dart';
import '../data/models/insight_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // ════════════════════════════════════════════════════════════════════════════
  // CIRCLES
  // ════════════════════════════════════════════════════════════════════════════

  String _generateInviteCode() {
    final uuid = _uuid.v4().replaceAll('-', '').toUpperCase();
    return uuid.substring(0, 6);
  }

  Future<CircleModel> createCircle({
    required String name,
    required String type,
    required String createdByUid,
  }) async {
    final inviteCode = _generateInviteCode();
    final ref = _db.collection(AppConstants.circlesCollection).doc();
    final model = CircleModel(
      id: ref.id,
      name: name,
      type: type,
      inviteCode: inviteCode,
      createdBy: createdByUid,
      members: [createdByUid],
      createdAt: DateTime.now(),
    );
    await ref.set(model.toMap());
    return model;
  }

  Future<CircleModel?> joinCircleByCode({
    required String inviteCode,
    required String uid,
  }) async {
    final query = await _db
        .collection(AppConstants.circlesCollection)
        .where('inviteCode', isEqualTo: inviteCode.toUpperCase().trim())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;

    final doc = query.docs.first;
    await doc.reference.update({
      'members': FieldValue.arrayUnion([uid]),
    });

    final updated = await doc.reference.get();
    return CircleModel.fromMap(updated.data()!, updated.id);
  }

  Stream<List<CircleModel>> getUserCircles(String uid) {
    return _db
        .collection(AppConstants.circlesCollection)
        .where('members', arrayContains: uid)
        .snapshots()
        .map((snap) {
      final list = snap.docs.map((d) => CircleModel.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  Future<CircleModel?> getCircle(String circleId) async {
    final snap =
        await _db.collection(AppConstants.circlesCollection).doc(circleId).get();
    if (!snap.exists) return null;
    return CircleModel.fromMap(snap.data()!, snap.id);
  }

  Future<List<Map<String, dynamic>>> getUsersByIds(List<String> uids) async {
    if (uids.isEmpty) return [];
    
    // Firestore whereIn limits to 10. For larger groups, we'd need batching.
    // For this prototype, we'll assume circles are <= 10 members or batch it simply.
    final List<Map<String, dynamic>> users = [];
    for (var i = 0; i < uids.length; i += 10) {
      final chunk = uids.sublist(i, i + 10 > uids.length ? uids.length : i + 10);
      final snap = await _db
          .collection(AppConstants.usersCollection)
          .where('uid', whereIn: chunk)
          .get();
      users.addAll(snap.docs.map((d) => d.data()));
    }
    return users;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // PULSES
  // ════════════════════════════════════════════════════════════════════════════

  Future<bool> hasSubmittedPulseToday({
    required String userId,
    required String circleId,
  }) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final snap = await _db
        .collection(AppConstants.pulsesCollection)
        .where('userId', isEqualTo: userId)
        .where('circleId', isEqualTo: circleId)
        .get();

    return snap.docs.any((doc) {
      final timestamp = (doc.data()['timestamp'] as Timestamp).toDate();
      return timestamp.isAfter(startOfDay);
    });
  }

  Future<PulseModel> submitPulse({
    required String userId,
    required String circleId,
    required double heard,
    required double respected,
    required double safe,
    required double connected,
  }) async {
    final ref = _db.collection(AppConstants.pulsesCollection).doc();
    final model = PulseModel(
      id: ref.id,
      userId: userId,
      circleId: circleId,
      heard: heard,
      respected: respected,
      safe: safe,
      connected: connected,
      timestamp: DateTime.now(),
    );
    await ref.set(model.toMap());
    return model;
  }

  Future<List<PulseModel>> getLast7DaysPulses({
    required String userId,
    required String circleId,
  }) async {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    final snap = await _db
        .collection(AppConstants.pulsesCollection)
        .where('userId', isEqualTo: userId)
        .where('circleId', isEqualTo: circleId)
        .get();
    
    final list = snap.docs
        .map((d) => PulseModel.fromMap(d.data(), d.id))
        .where((p) => p.timestamp.isAfter(sevenDaysAgo))
        .toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  /// Returns pulses for ALL members in a circle for the last N days
  Future<List<PulseModel>> getCirclePulses({
    required String circleId,
    int days = 7,
  }) async {
    final since = DateTime.now().subtract(Duration(days: days));
    final snap = await _db
        .collection(AppConstants.pulsesCollection)
        .where('circleId', isEqualTo: circleId)
        .get();
    
    final list = snap.docs
        .map((d) => PulseModel.fromMap(d.data(), d.id))
        .where((p) => p.timestamp.isAfter(since))
        .toList();
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }

  // ════════════════════════════════════════════════════════════════════════════
  // GRATITUDE
  // ════════════════════════════════════════════════════════════════════════════

  Future<GratitudeModel> postGratitude({
    required String authorId,
    required String authorName,
    required String circleId,
    required String message,
  }) async {
    final ref = _db.collection(AppConstants.gratitudeCollection).doc();
    final model = GratitudeModel(
      id: ref.id,
      authorId: authorId,
      authorName: authorName,
      circleId: circleId,
      message: message,
      userReactions: {},
      timestamp: DateTime.now(),
    );
    await ref.set(model.toMap());
    return model;
  }

  Stream<List<GratitudeModel>> getGratitudeFeed(String circleId) {
    return _db
        .collection(AppConstants.gratitudeCollection)
        .where('circleId', isEqualTo: circleId)
        .snapshots()
        .map((snap) {
      final list = snap.docs
          .map((d) => GratitudeModel.fromMap(d.data(), d.id))
          .toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Future<void> addReaction({
    required String gratitudeId,
    required String emoji,
    required String uid,
  }) async {
    await _db
        .collection(AppConstants.gratitudeCollection)
        .doc(gratitudeId)
        .update({'userReactions.$uid': emoji});
  }

  // ════════════════════════════════════════════════════════════════════════════
  // INSIGHTS
  // ════════════════════════════════════════════════════════════════════════════

  Future<void> saveInsight(InsightModel insight) async {
    final ref = _db.collection(AppConstants.insightsCollection).doc();
    await ref.set({...insight.toMap(), 'id': ref.id});
  }

  Future<InsightModel?> getLatestInsight(String circleId) async {
    final snap = await _db
        .collection(AppConstants.insightsCollection)
        .where('circleId', isEqualTo: circleId)
        .get();
    if (snap.docs.isEmpty) return null;
    
    final list = snap.docs.map((d) => InsightModel.fromMap(d.data(), d.id)).toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list.first;
  }
}
