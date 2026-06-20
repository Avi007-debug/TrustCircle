import 'package:cloud_firestore/cloud_firestore.dart';

class InsightModel {
  final String id;
  final String circleId;
  final String summary;
  final String riskLevel; // 'Low', 'Medium', 'High'
  final String suggestion;
  final String conversationStarter;
  final DateTime timestamp;

  const InsightModel({
    required this.id,
    required this.circleId,
    required this.summary,
    required this.riskLevel,
    required this.suggestion,
    required this.conversationStarter,
    required this.timestamp,
  });

  factory InsightModel.fromMap(Map<String, dynamic> map, String docId) {
    return InsightModel(
      id: docId,
      circleId: map['circleId'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      riskLevel: map['riskLevel'] as String? ?? 'Low',
      suggestion: map['suggestion'] as String? ?? '',
      conversationStarter: map['conversationStarter'] as String? ?? '',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'circleId': circleId,
        'summary': summary,
        'riskLevel': riskLevel,
        'suggestion': suggestion,
        'conversationStarter': conversationStarter,
        'timestamp': Timestamp.fromDate(timestamp),
      };
}
