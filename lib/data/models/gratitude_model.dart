import 'package:cloud_firestore/cloud_firestore.dart';

class GratitudeModel {
  final String id;
  final String authorId;
  final String authorName;
  final String circleId;
  final String message;
  final Map<String, String> userReactions; // { uid: emoji }
  final DateTime timestamp;

  const GratitudeModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.circleId,
    required this.message,
    required this.userReactions,
    required this.timestamp,
  });

  Map<String, int> get reactions {
    final counts = <String, int>{};
    for (final emoji in userReactions.values) {
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    }
    return counts;
  }

  factory GratitudeModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawReactions = map['userReactions'] as Map<String, dynamic>? ?? {};
    return GratitudeModel(
      id: docId,
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? 'Anonymous',
      circleId: map['circleId'] as String? ?? '',
      message: map['message'] as String? ?? '',
      userReactions: rawReactions.map((k, v) => MapEntry(k, v.toString())),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'authorName': authorName,
        'circleId': circleId,
        'message': message,
        'userReactions': userReactions,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  GratitudeModel copyWith({Map<String, String>? userReactions}) => GratitudeModel(
        id: id,
        authorId: authorId,
        authorName: authorName,
        circleId: circleId,
        message: message,
        userReactions: userReactions ?? this.userReactions,
        timestamp: timestamp,
      );
}
