import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/diet_damage_model.dart';
import 'auth_service.dart';

class DietDamageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  CollectionReference<Map<String, dynamic>>? get _damageCollection {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return null;

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('diet_damage_logs');
  }

  Future<void> addDamageLog({
    required String title,
    required int calories,
    String reason = '',
  }) async {
    final collection = _damageCollection;
    if (collection == null) return;

    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty || trimmedTitle.length > 200) {
      throw ArgumentError('Title must be between 1 and 200 characters.');
    }
    if (calories <= 0 || calories > 100000) {
      throw ArgumentError('Calories must be between 1 and 100,000.');
    }
    final trimmedReason = reason.trim();
    final safeReason = trimmedReason.length > 500
        ? trimmedReason.substring(0, 500)
        : trimmedReason;

    final damagePoints = (calories / 50).ceil();
    final log = DietDamageModel(
      id: '',
      title: trimmedTitle,
      reason: safeReason,
      calories: calories,
      damagePoints: damagePoints,
      createdAt: DateTime.now(),
      recovered: false,
    );

    await collection.add(log.toFirestoreMap());
  }

  Future<void> recoverDamage(String id) async {
    final collection = _damageCollection;
    if (collection == null) return;

    await collection.doc(id).update({'recovered': true});
  }

  Future<void> deleteDamage(String id) async {
    final collection = _damageCollection;
    if (collection == null) return;

    await collection.doc(id).delete();
  }

  Stream<List<DietDamageModel>> getDamageLogs() {
    final collection = _damageCollection;
    if (collection == null) return Stream.value([]);

    return collection.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      return snapshot.docs.map((doc) {
        return DietDamageModel.fromFirestoreMap(doc.id, doc.data());
      }).toList();
    });
  }

  Stream<int> getTotalDamagePoints() {
    return getDamageLogs().map((logs) {
      return logs.fold<int>(0, (total, log) => total + log.damagePoints);
    });
  }
}
