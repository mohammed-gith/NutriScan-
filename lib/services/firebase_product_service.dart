import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/product_model.dart';

class FirebaseProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveScannedProduct(ProductModel product) async {
    try {
      await _firestore.collection('scan_history').add({
        ...product.toFirestoreMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw Exception('Could not save scanned product: $error');
    }
  }

  Future<void> saveFavoriteProduct(ProductModel product) async {
    try {
      await _firestore.collection('saved_products').doc(product.barcode).set({
        ...product.toFirestoreMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (error) {
      throw Exception('Could not save favorite product: $error');
    }
  }

  Stream<List<ProductModel>> getScanHistory() {
    return _firestore
        .collection('scan_history')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromFirestoreMap(doc.data());
      }).toList();
    });
  }

  Stream<List<ProductModel>> getSavedProducts() {
    return _firestore
        .collection('saved_products')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ProductModel.fromFirestoreMap(doc.data());
      }).toList();
    });
  }
}
