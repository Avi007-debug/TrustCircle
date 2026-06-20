import 'package:cloud_firestore/cloud_firestore.dart';

class PulseModel {
  final String id;
  final String userId;
  final String circleId;
  final double heard;
  final double respected;
  final double safe;
  final double connected;
  final DateTime timestamp;

  const PulseModel({
    required this.id,
    required this.userId,
    required this.circleId,
    required this.heard,
    required this.respected,
    required this.safe,
    required this.connected,
    required this.timestamp,
  });

  double get trustScore => (heard + respected + safe + connected) / 4.0 * 10;

  factory PulseModel.fromMap(Map<String, dynamic> map, String docId) {
    return PulseModel(
      id: docId,
      userId: map['userId'] as String? ?? '',
      circleId: map['circleId'] as String? ?? '',
      heard: (map['heard'] as num?)?.toDouble() ?? 5.0,
      respected: (map['respected'] as num?)?.toDouble() ?? 5.0,
      safe: (map['safe'] as num?)?.toDouble() ?? 5.0,
      connected: (map['connected'] as num?)?.toDouble() ?? 5.0,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'circleId': circleId,
        'heard': heard,
        'respected': respected,
        'safe': safe,
        'connected': connected,
        'timestamp': Timestamp.fromDate(timestamp),
      };
}
