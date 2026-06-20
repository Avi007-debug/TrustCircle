import 'package:cloud_firestore/cloud_firestore.dart';

class CircleModel {
  final String id;
  final String name;
  final String type;
  final String inviteCode;
  final String createdBy;
  final List<String> members;
  final DateTime createdAt;

  const CircleModel({
    required this.id,
    required this.name,
    required this.type,
    required this.inviteCode,
    required this.createdBy,
    required this.members,
    required this.createdAt,
  });

  factory CircleModel.fromMap(Map<String, dynamic> map, String docId) {
    return CircleModel(
      id: docId,
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? 'Friends',
      inviteCode: map['inviteCode'] as String? ?? '',
      createdBy: map['createdBy'] as String? ?? '',
      members: List<String>.from(map['members'] as List? ?? []),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'inviteCode': inviteCode,
        'createdBy': createdBy,
        'members': members,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
