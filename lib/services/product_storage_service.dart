import 'package:flutter/foundation.dart';

import '../models/product_model.dart';

class ProductStorageService {
  static final ValueNotifier<List<ProductModel>> scanHistory =
      ValueNotifier<List<ProductModel>>([]);

  static final ValueNotifier<List<ProductModel>> savedProducts =
      ValueNotifier<List<ProductModel>>([]);

  static void addToHistory(ProductModel product) {
    final products = List<ProductModel>.from(scanHistory.value);
    products.removeWhere((item) => item.barcode == product.barcode);
    scanHistory.value = [product, ...products];
  }

  static void saveProduct(ProductModel product) {
    final alreadySaved = isSaved(product);
    if (alreadySaved) return;

    savedProducts.value = [product, ...savedProducts.value];
  }

  static bool isSaved(ProductModel product) {
    return savedProducts.value.any((item) => item.barcode == product.barcode);
  }
}
