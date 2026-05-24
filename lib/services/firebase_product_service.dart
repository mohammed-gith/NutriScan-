import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';
import 'auth_service.dart';

class FirebaseProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  CollectionReference<Map<String, dynamic>>? _userCollection(String name) {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return null;

    return _firestore.collection('users').doc(uid).collection(name);
  }

  Future<void> saveScannedProduct(ProductModel product) async {
    try {
      final collection = _userCollection('scan_history');
      if (collection == null) return;

      await collection.add({
        ...product.toFirestoreMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Could not save scanned product.');
    }
  }

  Future<void> saveFavoriteProduct(ProductModel product) async {
    try {
      final collection = _userCollection('saved_products');
      if (collection == null) return;

      await collection.doc(product.barcode).set({
        ...product.toFirestoreMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      throw Exception('Could not save favorite product.');
    }
  }

  Stream<List<ProductModel>> getScanHistory() {
    final collection = _userCollection('scan_history');
    if (collection == null) return Stream.value([]);

    return collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromFirestoreMap(doc.data());
      }).toList();
    });
  }

  Stream<List<ProductModel>> getSavedProducts() {
    final collection = _userCollection('saved_products');
    if (collection == null) return Stream.value([]);

    return collection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromFirestoreMap(doc.data());
      }).toList();
    });
  }
}
