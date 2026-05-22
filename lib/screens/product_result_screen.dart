import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/firebase_product_service.dart';
import '../widgets/product_info_row.dart';
import 'healthier_alternatives_screen.dart';

class ProductResultScreen extends StatelessWidget {
  final ProductModel product;
  static const int dailyCalorieTarget = 2000;

  const ProductResultScreen({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    final scoreColor = _scoreColor(product.nutriScore);
    final scoreLabel = _scoreLabel(product.nutriScore);
    final calorieProgress =
        (product.caloriesNumber / dailyCalorieTarget).clamp(0, 1).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFF031F13),
      appBar: AppBar(
        title: const Text('Product Result'),
        backgroundColor: const Color(0xFF031F13),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
        children: [
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFDDF8E8),
                      child: Icon(Icons.restaurant, color: Color(0xFF16A05D)),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: scoreColor,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        scoreLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  product.productName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  product.brand,
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Daily Calories',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${product.caloriesNumber}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 5),
                      child: Text('kcal / 2000 kcal'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: calorieProgress,
                    minHeight: 12,
                    backgroundColor: const Color(0xFFE9F3ED),
                    color: _calorieColor(calorieProgress),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Nutrition Facts per 100g',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 14),
                _NutritionBar(
                  label: 'Calories',
                  value: _formatNutritionValue(product.calories),
                  unit: 'kcal',
                  maxValue: 500,
                  color: const Color(0xFF6B7280),
                ),
                _NutritionBar(
                  label: 'Carbs',
                  value: product.carbohydrates,
                  unit: 'g',
                  maxValue: 80,
                  color: const Color(0xFFE5B400),
                ),
                _NutritionBar(
                  label: 'Sugars',
                  value: product.sugars,
                  unit: 'g',
                  maxValue: 50,
                  color: const Color(0xFFE67E22),
                ),
                _NutritionBar(
                  label: 'Fat',
                  value: _formatNutritionValue(product.fat),
                  unit: 'g',
                  maxValue: 50,
                  color: const Color(0xFF16A05D),
                ),
                _NutritionBar(
                  label: 'Saturated Fat',
                  value: product.saturatedFat,
                  unit: 'g',
                  maxValue: 20,
                  color: const Color(0xFFE74C3C),
                ),
                _NutritionBar(
                  label: 'Protein',
                  value: product.protein,
                  unit: 'g',
                  maxValue: 40,
                  color: const Color(0xFF16A05D),
                ),
                _NutritionBar(
                  label: 'Salt',
                  value: _formatNutritionValue(product.salt),
                  unit: 'g',
                  maxValue: 6,
                  color: const Color(0xFFE5B400),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                ProductInfoRow(
                    label: 'Ingredients', value: product.ingredients),
                ProductInfoRow(
                  label: 'Allergens',
                  value: product.allergens.isEmpty
                      ? 'No allergens listed'
                      : product.allergens.join(', '),
                ),
                ProductInfoRow(
                  label: 'Calories per 100g',
                  value: '${product.calories} kcal',
                ),
                ProductInfoRow(label: 'Nutri-Score', value: product.nutriScore),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: StreamBuilder<List<ProductModel>>(
                  stream: FirebaseProductService().getSavedProducts(),
                  builder: (context, snapshot) {
                    final savedProducts = snapshot.data ?? [];
                    final isSaved = savedProducts.any(
                      (item) => item.barcode == product.barcode,
                    );

                    return FilledButton.icon(
                      onPressed: isSaved
                          ? null
                          : () async {
                              try {
                                await FirebaseProductService()
                                    .saveFavoriteProduct(product);

                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Product saved.'),
                                  ),
                                );
                              } catch (error) {
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Could not save product.'),
                                  ),
                                );
                              }
                            },
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                      ),
                      label: Text(isSaved ? 'Saved' : 'Save'),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HealthierAlternativesScreen(
                          originalProduct: product,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.eco),
                  label: const Text('Healthier Alternatives'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _scoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'A':
        return const Color(0xFF16A05D);
      case 'B':
        return const Color(0xFF7BBF38);
      case 'C':
        return const Color(0xFFE5B400);
      case 'D':
        return const Color(0xFFE67E22);
      case 'E':
        return const Color(0xFFE74C3C);
      default:
        return Colors.grey;
    }
  }

  Color _calorieColor(double progress) {
    if (progress < 0.25) return const Color(0xFF16A05D);
    if (progress < 0.5) return const Color(0xFFE5B400);
    return const Color(0xFFE67E22);
  }

  String _scoreLabel(String score) {
    final upperScore = score.toUpperCase();
    if (['A', 'B', 'C', 'D', 'E'].contains(upperScore)) return upperScore;
    return '?';
  }

  String _formatNutritionValue(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }

    return value.toStringAsFixed(1);
  }
}

class _NutritionBar extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final double maxValue;
  final Color color;

  const _NutritionBar({
    required this.label,
    required this.value,
    required this.unit,
    required this.maxValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(value) ?? 0;
    final progress = (amount / maxValue).clamp(0, 1).toDouble();
    final level = _levelLabel(progress);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 104,
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(99),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE9F3ED),
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 58,
                child: Text(
                  '$value$unit',
                  textAlign: TextAlign.end,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                level,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _levelLabel(double progress) {
    if (progress < 0.25) return 'Low';
    if (progress < 0.6) return 'Moderate';
    return 'High';
  }
}
