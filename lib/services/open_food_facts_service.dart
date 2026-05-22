import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class OpenFoodFactsService {
  Future<ProductModel?> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse(
        'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final product = data['product'];

      if (data['status'] != 1 || product is! Map<String, dynamic>) {
        return null;
      }

      return ProductModel.fromOpenFoodFactsJson(barcode, product);
    } catch (_) {
      return null;
    }
  }

  Future<ProductModel?> fetchProductByBarcode(String barcode) {
    return getProductByBarcode(barcode);
  }

  Future<List<ProductModel>> fetchHealthierAlternatives(
    ProductModel product,
  ) async {
    try {
      final searchTerms = product.name
          .split(RegExp(r'\s+'))
          .where((word) => word.length > 3)
          .take(3)
          .join(' ');

      final url = Uri.https('world.openfoodfacts.org', '/cgi/search.pl', {
        'search_simple': '1',
        'action': 'process',
        'json': '1',
        'page_size': '30',
        'search_terms': searchTerms.isEmpty ? product.brand : searchTerms,
        'fields':
            'code,product_name,brands,image_url,ingredients_text,allergens_tags,nutriments,nutriscore_grade',
      });

      final response = await http.get(url);
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final products = data['products'] as List<dynamic>? ?? [];

      final alternatives = products.whereType<Map<String, dynamic>>().map((
        json,
      ) {
        final barcode = json['code']?.toString() ?? '';
        return ProductModel.fromOpenFoodFactsJson(barcode, json);
      }).where((alternative) {
        if (alternative.barcode.isEmpty) return false;
        if (alternative.barcode == product.barcode) return false;
        if (alternative.name == 'Unknown product') return false;
        return _isHealthier(product, alternative);
      }).toList();

      alternatives.sort((a, b) {
        final scoreComparison = a.nutriScoreRank.compareTo(b.nutriScoreRank);
        if (scoreComparison != 0) return scoreComparison;
        return a.caloriesNumber.compareTo(b.caloriesNumber);
      });

      return alternatives.take(5).toList();
    } catch (_) {
      return [];
    }
  }

  bool _isHealthier(ProductModel original, ProductModel alternative) {
    final betterScore = alternative.nutriScoreRank < original.nutriScoreRank;
    final lowerCalories = alternative.calories > 0 &&
        original.calories > 0 &&
        alternative.calories < original.calories;
    final lowerSugar = alternative.sugar > 0 &&
        original.sugar > 0 &&
        alternative.sugar < original.sugar;
    final lowerFat = alternative.fat > 0 &&
        original.fat > 0 &&
        alternative.fat < original.fat;

    return betterScore || lowerCalories || lowerSugar || lowerFat;
  }
}
