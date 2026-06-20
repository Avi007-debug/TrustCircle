import 'package:cloud_firestore/cloud_firestore.dart';

class GratitudeModel {
  final String id;
  final String authorId;
  final String authorName;
  final String circleId;
  final String message;
  final Map<String, int> reactions; // e.g. {'❤️': 3, '👏': 1, '🙏': 0}
  final DateTime timestamp;

  const GratitudeModel({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.circleId,
    required this.message,
    required this.reactions,
    required this.timestamp,
  });

  factory GratitudeModel.fromMap(Map<String, dynamic> map, String docId) {
    final rawReactions = map['reactions'] as Map<String, dynamic>? ?? {};
    return GratitudeModel(
      id: docId,
      authorId: map['authorId'] as String? ?? '',
      authorName: map['authorName'] as String? ?? 'Anonymous',
      circleId: map['circleId'] as String? ?? '',
      message: map['message'] as String? ?? '',
      reactions: rawReactions.map((k, v) => MapEntry(k, (v as num).toInt())),
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'authorId': authorId,
        'authorName': authorName,
        'circleId': circleId,
        'message': message,
        'reactions': reactions,
        'timestamp': Timestamp.fromDate(timestamp),
      };

  GratitudeModel copyWith({Map<String, int>? reactions}) => GratitudeModel(
        id: id,
        authorId: authorId,
        authorName: authorName,
        circleId: circleId,
        message: message,
        reactions: reactions ?? this.reactions,
        timestamp: timestamp,
      );
}
