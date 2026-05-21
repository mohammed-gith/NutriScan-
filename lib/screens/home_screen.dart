import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../services/product_storage_service.dart';
import 'product_result_screen.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _openScanner() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ScannerScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardTab(onScanPressed: _openScanner),
      _ProductListTab(
        title: 'Scan History',
        emptyIcon: Icons.history,
        emptyMessage: 'Scanned products will appear here.',
        productsNotifier: ProductStorageService.scanHistory,
      ),
      _ProductListTab(
        title: 'Saved Items',
        emptyIcon: Icons.bookmark,
        emptyMessage: 'Saved products will appear here.',
        productsNotifier: ProductStorageService.savedProducts,
      ),
      const _ProfileTab(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[_selectedIndex]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _DashboardTab extends StatelessWidget {
  final VoidCallback onScanPressed;

  const _DashboardTab({required this.onScanPressed});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFDDF8E8),
              child: Icon(Icons.eco, color: Color(0xFF16A05D)),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hello, NutriScan user'),
                  Text(
                    'Choose better food today',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF073D25),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Food transparency starts here',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Scan a barcode to see ingredients, allergens, calories, and Nutri-Score.',
                style: TextStyle(color: Color(0xFFCBEFDB)),
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: onScanPressed,
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Scan Food'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const _DailyCaloriesCard(),
        const SizedBox(height: 14),
        const _DashboardMetrics(),
        const SizedBox(height: 22),
        const Text(
          'Recommended next steps',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const _ActionTile(
          icon: Icons.warning_amber,
          title: 'Allergen alerts',
          subtitle: 'Coming later when profile settings are added.',
        ),
        const _ActionTile(
          icon: Icons.favorite,
          title: 'Healthier alternatives',
          subtitle: 'Coming after the first product lookup is complete.',
        ),
      ],
    );
  }
}

class _DailyCaloriesCard extends StatelessWidget {
  static const int dailyTarget = 2000;

  const _DailyCaloriesCard();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ProductModel>>(
      valueListenable: ProductStorageService.scanHistory,
      builder: (context, products, child) {
        final totalCalories = products.fold<int>(
          0,
          (total, product) => total + product.caloriesNumber,
        );
        final progress = (totalCalories / dailyTarget).clamp(0, 1).toDouble();

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFFFF2CC),
                    child: Icon(Icons.local_fire_department,
                        color: Color(0xFFE59D00)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Daily Calories',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    '$totalCalories / $dailyTarget kcal',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(99),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 12,
                  backgroundColor: const Color(0xFFE9F3ED),
                  color: const Color(0xFFE5B400),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Based on scanned products in this session.',
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardMetrics extends StatelessWidget {
  const _DashboardMetrics();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<List<ProductModel>>(
            valueListenable: ProductStorageService.scanHistory,
            builder: (context, products, child) {
              return _MetricCard(
                icon: Icons.document_scanner,
                label: 'Scans',
                value: products.length.toString(),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ValueListenableBuilder<List<ProductModel>>(
            valueListenable: ProductStorageService.savedProducts,
            builder: (context, products, child) {
              return _MetricCard(
                icon: Icons.bookmark,
                label: 'Saved',
                value: products.length.toString(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFDDF8E8),
            child: Icon(icon, color: const Color(0xFF16A05D)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(label),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFFFF2CC),
            child: Icon(icon, color: const Color(0xFFE59D00)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductListTab extends StatelessWidget {
  final String title;
  final IconData emptyIcon;
  final String emptyMessage;
  final ValueNotifier<List<ProductModel>> productsNotifier;

  const _ProductListTab({
    required this.title,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.productsNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ProductModel>>(
      valueListenable: productsNotifier,
      builder: (context, products, child) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            if (products.isEmpty)
              _EmptyState(icon: emptyIcon, message: emptyMessage)
            else
              for (final product in products)
                _ProductTile(
                  product: product,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProductResultScreen(product: product),
                      ),
                    );
                  },
                ),
          ],
        );
      },
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const _ProductTile({
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFDDF8E8),
          child: Text(
            product.nutriScore.isEmpty ? '?' : product.nutriScore[0],
            style: const TextStyle(
              color: Color(0xFF16A05D),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          product.productName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${product.brand}\nBarcode: ${product.barcode}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(icon, size: 72, color: const Color(0xFF16A05D)),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _ProfileTab extends StatefulWidget {
  const _ProfileTab();

  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  String _name = 'NutriScan User';
  String _email = 'student@example.com';
  String _allergens = 'None set';
  String _goal = 'Eat healthier';
  String _diet = 'General';

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _name);
    final emailController = TextEditingController(text: _email);
    final allergensController = TextEditingController(text: _allergens);
    final goalController = TextEditingController(text: _goal);
    final dietController = TextEditingController(text: _diet);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: allergensController,
                  decoration: const InputDecoration(labelText: 'Allergens'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: goalController,
                  decoration: const InputDecoration(labelText: 'Goal'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dietController,
                  decoration: const InputDecoration(labelText: 'Diet'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  _name = nameController.text.trim();
                  _email = emailController.text.trim();
                  _allergens = allergensController.text.trim();
                  _goal = goalController.text.trim();
                  _diet = dietController.text.trim();
                });

                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    allergensController.dispose();
    goalController.dispose();
    dietController.dispose();
  }

  void _showPhotoMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo upload will be added with image_picker later.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Profile',
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        _ProfileHeader(
          name: _name,
          email: _email,
          onEdit: _editProfile,
          onChangePhoto: _showPhotoMessage,
        ),
        const SizedBox(height: 16),
        _ProfileSection(
          title: 'Health Preferences',
          rows: [
            _ProfileRow(
              icon: Icons.no_food,
              label: 'Allergens',
              value: _allergens,
            ),
            _ProfileRow(icon: Icons.flag, label: 'Goal', value: _goal),
            _ProfileRow(icon: Icons.favorite, label: 'Diet', value: _diet),
          ],
        ),
        const SizedBox(height: 16),
        const _ProfileSection(
          title: 'Account Status',
          rows: [
            _ProfileRow(
              icon: Icons.cloud_off,
              label: 'Storage',
              value: 'Local only until Firebase is added',
            ),
            _ProfileRow(
              icon: Icons.image,
              label: 'Profile Picture',
              value: 'Image upload will be added with image_picker',
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final VoidCallback onEdit;
  final VoidCallback onChangePhoto;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.onEdit,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF073D25),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onChangePhoto,
            child: const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFDDF8E8),
              child: Icon(Icons.person, size: 42, color: Color(0xFF16A05D)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'NutriScan User' : name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email.isEmpty ? 'student@example.com' : email,
                  style: const TextStyle(color: Color(0xFFCBEFDB)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<_ProfileRow> rows;

  const _ProfileSection({
    required this.title,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF16A05D)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
