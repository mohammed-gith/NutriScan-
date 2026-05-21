import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class OpenFoodFactsService {
  Future<ProductModel?> fetchProductByBarcode(String barcode) async {
    final url = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$barcode.json',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to connect to Open Food Facts');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['status'] != 1 || data['product'] == null) {
      return null;
    }

    return ProductModel.fromJson(
      barcode: barcode,
      json: data['product'] as Map<String, dynamic>,
    );
  }

  Future<List<ProductModel>> fetchHealthierAlternatives(
    ProductModel product,
  ) async {
    final queryParameters = _buildAlternativeQueryParameters(product);
    final url = Uri.https(
      'world.openfoodfacts.org',
      '/cgi/search.pl',
      queryParameters,
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch healthier alternatives');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final productsJson = data['products'] as List<dynamic>? ?? [];

    final alternatives = productsJson
        .whereType<Map<String, dynamic>>()
        .map((json) {
          final barcode = json['code']?.toString() ?? '';
          return ProductModel.fromJson(barcode: barcode, json: json);
        })
        .where((alternative) {
          if (alternative.barcode.isEmpty) return false;
          if (alternative.barcode == product.barcode) return false;
          if (alternative.productName == 'Unknown product') return false;
          return _isHealthier(product, alternative);
        })
        .toList();

    alternatives.sort((a, b) {
      final scoreComparison = a.nutriScoreRank.compareTo(b.nutriScoreRank);
      if (scoreComparison != 0) return scoreComparison;
      return a.caloriesNumber.compareTo(b.caloriesNumber);
    });

    return alternatives.take(5).toList();
  }

  Map<String, String> _buildAlternativeQueryParameters(ProductModel product) {
    final parameters = {
      'search_simple': '1',
      'action': 'process',
      'json': '1',
      'page_size': '30',
      'fields':
          'code,product_name,brands,ingredients_text,allergens,nutriments,nutriscore_grade,categories_tags,main_category',
    };

    if (product.category.isNotEmpty) {
      parameters.addAll({
        'tagtype_0': 'categories',
        'tag_contains_0': 'contains',
        'tag_0': product.category.replaceFirst('en:', '').replaceAll('-', ' '),
      });
      return parameters;
    }

    final nameWords = product.productName
        .split(RegExp(r'\s+'))
        .where((word) => word.length > 3)
        .take(3)
        .join(' ');

    parameters['search_terms'] =
        nameWords.isNotEmpty ? nameWords : 'healthy food';
    return parameters;
  }

  bool _isHealthier(ProductModel original, ProductModel alternative) {
    final betterScore = alternative.nutriScoreRank < original.nutriScoreRank;
    final lowerCalories =
        alternative.caloriesNumber > 0 &&
            original.caloriesNumber > 0 &&
            alternative.caloriesNumber < original.caloriesNumber;
    final alternativeSugar = alternative.nutrientNumber(alternative.sugars);
    final originalSugar = original.nutrientNumber(original.sugars);
    final alternativeFat = alternative.nutrientNumber(alternative.fat);
    final originalFat = original.nutrientNumber(original.fat);
    final lowerSugar =
        alternativeSugar > 0 &&
            originalSugar > 0 &&
            alternativeSugar < originalSugar;
    final lowerFat =
        alternativeFat > 0 && originalFat > 0 && alternativeFat < originalFat;

    return betterScore || lowerCalories || lowerSugar || lowerFat;
  }
}
