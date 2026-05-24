class ProductModel {
  final String barcode;
  final String name;
  final String brand;
  final String imageUrl;
  final String ingredients;
  final List<String> allergens;
  final String nutriScore;
  final double calories;
  final double sugar;
  final double fat;
  final double salt;

  const ProductModel({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.ingredients,
    required this.allergens,
    required this.nutriScore,
    required this.calories,
    required this.sugar,
    required this.fat,
    required this.salt,
  });

  String get productName => name;

  int get caloriesNumber => calories.round();

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

  String get sugars => _formatDouble(sugar);

  String get carbohydrates => '0';

  String get saturatedFat => '0';

  String get protein => '0';

  double nutrientNumber(String value) {
    return double.tryParse(value) ?? 0;
  }

  factory ProductModel.fromOpenFoodFactsJson(
    String barcode,
    Map<String, dynamic> json,
  ) {
    final nutriments = _asMap(json['nutriments']);

    return ProductModel(
      barcode: barcode,
      name: _asString(json['product_name'], defaultValue: 'Unknown product'),
      brand: _asString(json['brands'], defaultValue: 'Unknown brand'),
      imageUrl: _asString(json['image_url']),
      ingredients: _asString(json['ingredients_text']),
      allergens: _asStringList(json['allergens_tags']),
      nutriScore: _asString(json['nutriscore_grade']).toUpperCase(),
      calories: _asDouble(nutriments['energy-kcal_100g']),
      sugar: _asDouble(nutriments['sugars_100g']),
      fat: _asDouble(nutriments['fat_100g']),
      salt: _asDouble(nutriments['salt_100g']),
    );
  }

  factory ProductModel.fromJson({
    required String barcode,
    required Map<String, dynamic> json,
  }) {
    return ProductModel.fromOpenFoodFactsJson(barcode, json);
  }

  Map<String, dynamic> toFirestoreMap() {
    return {
      'barcode': _cap(barcode, 20),
      'name': _cap(name, 500),
      'brand': _cap(brand, 200),
      'imageUrl': _cap(imageUrl, 1000),
      'ingredients': _cap(ingredients, 5000),
      'allergens': allergens
          .take(50)
          .map((a) => _cap(a, 100))
          .toList(),
      'nutriScore': _cap(nutriScore, 2),
      'calories': calories,
      'sugar': sugar,
      'fat': fat,
      'salt': salt,
    };
  }

  static String _cap(String value, int maxLength) {
    return value.length > maxLength ? value.substring(0, maxLength) : value;
  }

  factory ProductModel.fromFirestoreMap(Map<String, dynamic> map) {
    return ProductModel(
      barcode: _asString(map['barcode']),
      name: _asString(map['name'], defaultValue: 'Unknown product'),
      brand: _asString(map['brand'], defaultValue: 'Unknown brand'),
      imageUrl: _asString(map['imageUrl']),
      ingredients: _asString(map['ingredients']),
      allergens: _asStringList(map['allergens']),
      nutriScore: _asString(map['nutriScore']).toUpperCase(),
      calories: _asDouble(map['calories']),
      sugar: _asDouble(map['sugar']),
      fat: _asDouble(map['fat']),
      salt: _asDouble(map['salt']),
    );
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return {};
  }

  static String _asString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;

    final text = value.toString().trim();
    return text.isEmpty ? defaultValue : text;
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    final text = value?.toString().trim() ?? '';
    if (text.isEmpty) return [];

    return text
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static String _formatDouble(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }

    return value.toStringAsFixed(1);
  }
}
