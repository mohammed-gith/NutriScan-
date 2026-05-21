class ProductModel {
  final String barcode;
  final String productName;
  final String brand;
  final String ingredients;
  final String allergens;
  final String calories;
  final String carbohydrates;
  final String sugars;
  final String fat;
  final String saturatedFat;
  final String protein;
  final String salt;
  final String nutriScore;
  final String category;

  const ProductModel({
    required this.barcode,
    required this.productName,
    required this.brand,
    required this.ingredients,
    required this.allergens,
    required this.calories,
    required this.carbohydrates,
    required this.sugars,
    required this.fat,
    required this.saturatedFat,
    required this.protein,
    required this.salt,
    required this.nutriScore,
    required this.category,
  });

  factory ProductModel.fromJson({
    required String barcode,
    required Map<String, dynamic> json,
  }) {
    final nutriments = json['nutriments'] as Map<String, dynamic>? ?? {};
    final allergensText = json['allergens']?.toString() ?? '';
    final categories = json['categories_tags'] as List<dynamic>? ?? [];
    final categoryText = categories.isEmpty
        ? json['main_category']?.toString() ?? ''
        : categories.last.toString();

    return ProductModel(
      barcode: barcode,
      productName: json['product_name']?.toString() ?? 'Unknown product',
      brand: json['brands']?.toString() ?? 'Unknown brand',
      ingredients: json['ingredients_text']?.toString() ?? 'No ingredients listed',
      allergens: allergensText.isEmpty ? 'No allergens listed' : allergensText,
      calories: _readNutrient(nutriments, 'energy-kcal_100g'),
      carbohydrates: _readNutrient(nutriments, 'carbohydrates_100g'),
      sugars: _readNutrient(nutriments, 'sugars_100g'),
      fat: _readNutrient(nutriments, 'fat_100g'),
      saturatedFat: _readNutrient(nutriments, 'saturated-fat_100g'),
      protein: _readNutrient(nutriments, 'proteins_100g'),
      salt: _readNutrient(nutriments, 'salt_100g'),
      nutriScore:
          json['nutriscore_grade']?.toString().toUpperCase() ?? 'Not available',
      category: categoryText,
    );
  }

  int get caloriesNumber {
    return double.tryParse(calories)?.round() ?? 0;
  }

  int get nutriScoreRank {
    switch (nutriScore.toUpperCase()) {
      case 'A':
        return 1;
      case 'B':
        return 2;
      case 'C':
        return 3;
      case 'D':
        return 4;
      case 'E':
        return 5;
      default:
        return 99;
    }
  }

  double nutrientNumber(String value) {
    return double.tryParse(value) ?? 0;
  }

  static String _readNutrient(Map<String, dynamic> nutriments, String key) {
    final value = nutriments[key];
    if (value == null) return '0';

    final number = double.tryParse(value.toString());
    if (number == null) return '0';

    if (number == number.roundToDouble()) {
      return number.round().toString();
    }

    return number.toStringAsFixed(1);
  }
}
