import 'package:cloud_firestore/cloud_firestore.dart';

class DietDamageModel {
  final String id;
  final String title;
  final String reason;
  final int calories;
  final int damagePoints;
  final DateTime createdAt;
  final bool recovered;

  const DietDamageModel({
    required this.id,
    required this.title,
    required this.reason,
    required this.calories,
    required this.damagePoints,
    required this.createdAt,
    required this.recovered,
  });

  Map<String, dynamic> toFirestoreMap() {
    return {
      'title': title,
      'reason': reason,
      'calories': calories,
      'damagePoints': damagePoints,
      'createdAt': Timestamp.fromDate(createdAt),
      'recovered': recovered,
    };
  }

  factory DietDamageModel.fromFirestoreMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final createdAtValue = map['createdAt'];

    return DietDamageModel(
      id: id,
      title: _asString(map['title'], defaultValue: 'Diet damage'),
      reason: _asString(map['reason']),
      calories: _asInt(map['calories']),
      damagePoints: _asInt(map['damagePoints']),
      createdAt: createdAtValue is Timestamp
          ? createdAtValue.toDate()
          : DateTime.now(),
      recovered: map['recovered'] == true,
    );
  }

  static String _asString(dynamic value, {String defaultValue = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? defaultValue : text;
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
