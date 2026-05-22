import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/firebase_product_service.dart';
import '../services/open_food_facts_service.dart';
import 'product_result_screen.dart';

class HealthierAlternativesScreen extends StatefulWidget {
  final ProductModel originalProduct;

  const HealthierAlternativesScreen({
    super.key,
    required this.originalProduct,
  });

  @override
  State<HealthierAlternativesScreen> createState() =>
      _HealthierAlternativesScreenState();
}

class _HealthierAlternativesScreenState
    extends State<HealthierAlternativesScreen> {
  final OpenFoodFactsService _service = OpenFoodFactsService();

  late Future<List<ProductModel>> _alternativesFuture;

  @override
  void initState() {
    super.initState();
    _alternativesFuture =
        _service.fetchHealthierAlternatives(widget.originalProduct);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF031F13),
      appBar: AppBar(
        title: const Text('Healthier Alternatives'),
        backgroundColor: const Color(0xFF031F13),
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: _alternativesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF24C676)),
            );
          }

          if (snapshot.hasError) {
            return _MessagePanel(
              icon: Icons.cloud_off,
              title: 'Could not load alternatives',
              message: 'Please check your connection and try again.',
              action: FilledButton(
                onPressed: () {
                  setState(() {
                    _alternativesFuture = _service.fetchHealthierAlternatives(
                      widget.originalProduct,
                    );
                  });
                },
                child: const Text('Try Again'),
              ),
            );
          }

          final alternatives = snapshot.data ?? [];

          if (alternatives.isEmpty) {
            return const _MessagePanel(
              icon: Icons.search_off,
              title: 'No better alternatives found',
              message:
                  'Open Food Facts did not return a clearly healthier match yet.',
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
            children: [
              _OriginalProductCard(product: widget.originalProduct),
              const SizedBox(height: 18),
              const Text(
                'Suggested swaps',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ranked by better Nutri-Score, then lower calories.',
                style: TextStyle(color: Color(0xFFCBEFDB)),
              ),
              const SizedBox(height: 16),
              for (final alternative in alternatives)
                _AlternativeCard(
                  original: widget.originalProduct,
                  alternative: alternative,
                ),
            ],
          );
        },
      ),
    );
  }
}

class _OriginalProductCard extends StatelessWidget {
  final ProductModel product;

  const _OriginalProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF073D25),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF1A7A4A)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: _scoreColor(product.nutriScore),
            child: Text(
              _scoreLabel(product.nutriScore),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current product',
                  style: TextStyle(color: Color(0xFFCBEFDB)),
                ),
                Text(
                  product.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${product.caloriesNumber} kcal',
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _AlternativeCard extends StatelessWidget {
  final ProductModel original;
  final ProductModel alternative;

  const _AlternativeCard({
    required this.original,
    required this.alternative,
  });

  @override
  Widget build(BuildContext context) {
    final reason = _reasonText();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: _scoreColor(alternative.nutriScore),
                child: Text(
                  _scoreLabel(alternative.nutriScore),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alternative.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alternative.brand,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CompareRow(
            label: 'Calories',
            originalValue: '${original.caloriesNumber}',
            alternativeValue: '${alternative.caloriesNumber}',
            unit: 'kcal',
          ),
          _CompareRow(
            label: 'Sugar',
            originalValue: original.sugars,
            alternativeValue: alternative.sugars,
            unit: 'g',
          ),
          _CompareRow(
            label: 'Fat',
            originalValue: _formatNutritionValue(original.fat),
            alternativeValue: _formatNutritionValue(alternative.fat),
            unit: 'g',
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF8F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.eco, color: Color(0xFF16A05D)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reason,
                    style: const TextStyle(color: Color(0xFF0B5A34)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      await FirebaseProductService()
                          .saveFavoriteProduct(alternative);

                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Alternative saved.')),
                      );
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not save alternative.'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Save'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () async {
                    try {
                      await FirebaseProductService()
                          .saveScannedProduct(alternative);

                      if (!context.mounted) return;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductResultScreen(product: alternative),
                        ),
                      );
                    } catch (error) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open alternative.'),
                        ),
                      );
                    }
                  },
                  child: const Text('View'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _reasonText() {
    if (alternative.nutriScoreRank < original.nutriScoreRank) {
      return 'Better Nutri-Score than the scanned product.';
    }

    if (alternative.caloriesNumber < original.caloriesNumber) {
      return 'Lower calories per 100g than the scanned product.';
    }

    final sugar = double.tryParse(alternative.sugars) ?? 0;
    final originalSugar = double.tryParse(original.sugars) ?? 0;
    if (sugar < originalSugar) {
      return 'Lower sugar than the scanned product.';
    }

    return 'A potentially better option from Open Food Facts.';
  }

  String _formatNutritionValue(double value) {
    if (value == value.roundToDouble()) {
      return value.round().toString();
    }

    return value.toStringAsFixed(1);
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final String originalValue;
  final String alternativeValue;
  final String unit;

  const _CompareRow({
    required this.label,
    required this.originalValue,
    required this.alternativeValue,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              '$originalValue$unit',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          const Icon(Icons.arrow_forward, size: 18, color: Color(0xFF16A05D)),
          Expanded(
            child: Text(
              '$alternativeValue$unit',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessagePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final Widget? action;

  const _MessagePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: const Color(0xFF16A05D)),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            if (action != null) ...[
              const SizedBox(height: 18),
              action!,
            ],
          ],
        ),
      ),
    );
  }
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

String _scoreLabel(String score) {
  final upperScore = score.toUpperCase();
  if (['A', 'B', 'C', 'D', 'E'].contains(upperScore)) return upperScore;
  return '?';
}
