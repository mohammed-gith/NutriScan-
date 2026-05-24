import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/product_model.dart';
import '../services/auth_service.dart';
import '../services/firebase_product_service.dart';
import '../services/storage_service.dart';
import '../widgets/nutriscan_logo.dart';
import 'diet_damage_screen.dart';
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

  void _openDietDamageTracker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DietDamageScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _DashboardTab(
        onScanPressed: _openScanner,
        onDamagePressed: _openDietDamageTracker,
      ),
      _ProductListTab(
        title: 'Scan History',
        emptyIcon: Icons.history,
        emptyMessage: 'Scanned products will appear here.',
        productsStream: FirebaseProductService().getScanHistory(),
      ),
      _ProductListTab(
        title: 'Saved Items',
        emptyIcon: Icons.bookmark,
        emptyMessage: 'Saved products will appear here.',
        productsStream: FirebaseProductService().getSavedProducts(),
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
  final VoidCallback onDamagePressed;

  const _DashboardTab({
    required this.onScanPressed,
    required this.onDamagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            const NutriScanLogo(
              iconSize: 34,
              textSize: 20,
              alignment: MainAxisAlignment.start,
            ),
            const SizedBox(width: 16),
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
        _ActionTile(
          icon: Icons.track_changes,
          title: 'Diet Damage Tracker',
          subtitle: 'Log cheat meals and recover damage points.',
          onTap: onDamagePressed,
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
  static const int _defaultTarget = 2000;

  const _DailyCaloriesCard();

  Future<void> _editGoal(BuildContext context, int currentGoal) async {
    final controller =
        TextEditingController(text: currentGoal.toString());

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Daily Calorie Goal'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Calories (kcal)',
            hintText: '2000',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final value = int.tryParse(controller.text.trim());
              if (value == null || value < 500 || value > 10000) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(
                      content: Text('Enter a value between 500 and 10,000.')),
                );
                return;
              }
              final uid = AuthService().currentUser?.uid;
              if (uid != null) {
                await FirebaseFirestore.instance
                    .collection('users')
                    .doc(uid)
                    .set({'dailyCalorieGoal': value},
                        SetOptions(merge: true));
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid;

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: uid == null
          ? null
          : FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .snapshots(),
      builder: (context, userSnap) {
        final dailyTarget =
            (userSnap.data?.data()?['dailyCalorieGoal'] as int?) ??
                _defaultTarget;

        return _ProductStreamBuilder(
          stream: FirebaseProductService().getScanHistory(),
          builder: (context, products) {
            final totalCalories = products.fold<int>(
              0,
              (total, product) => total + product.caloriesNumber,
            );
            final progress =
                (totalCalories / dailyTarget).clamp(0, 1).toDouble();
            final overGoal = totalCalories > dailyTarget;

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
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '$totalCalories / $dailyTarget kcal',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: overGoal
                              ? const Color(0xFFD32F2F)
                              : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => _editGoal(context, dailyTarget),
                        child: const Icon(Icons.edit_outlined,
                            size: 18, color: Color(0xFF16A05D)),
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
                      color: overGoal
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFFE5B400),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    overGoal
                        ? 'You exceeded your daily goal by ${totalCalories - dailyTarget} kcal.'
                        : 'Based on scanned products today.',
                    style: TextStyle(
                      color:
                          overGoal ? const Color(0xFFD32F2F) : Colors.black54,
                    ),
                  ),
                ],
              ),
            );
          },
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
          child: _ProductStreamBuilder(
            stream: FirebaseProductService().getScanHistory(),
            builder: (context, products) {
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
          child: _ProductStreamBuilder(
            stream: FirebaseProductService().getSavedProducts(),
            builder: (context, products) {
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
  final VoidCallback? onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
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
      ),
    );
  }
}

class _ProductStreamBuilder extends StatelessWidget {
  final Stream<List<ProductModel>> stream;
  final Widget Function(BuildContext context, List<ProductModel> products)
      builder;

  const _ProductStreamBuilder({
    required this.stream,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ProductModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Could not load products.'));
        }

        return builder(context, snapshot.data ?? []);
      },
    );
  }
}

class _ProductListTab extends StatelessWidget {
  final String title;
  final IconData emptyIcon;
  final String emptyMessage;
  final Stream<List<ProductModel>> productsStream;

  const _ProductListTab({
    required this.title,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.productsStream,
  });

  @override
  Widget build(BuildContext context) {
    return _ProductStreamBuilder(
      stream: productsStream,
      builder: (context, products) {
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
  final AuthService _authService = AuthService();
  String _name = 'NutriScan User';
  String _email = '';
  String _allergens = 'None set';
  String _goal = 'Eat healthier';
  String _diet = 'General';
  String? _photoUrl;
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _authService.currentUser;
    if (user == null) return;

    if (mounted) {
      setState(() {
        _email = user.email ?? '';
      });
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;
      final data = doc.data();
      if (data == null) return;

      setState(() {
        final name = (data['displayName'] as String? ?? '').trim();
        if (name.isNotEmpty) _name = name;
        final allergens = (data['allergens'] as String? ?? '').trim();
        if (allergens.isNotEmpty) _allergens = allergens;
        final goal = (data['goal'] as String? ?? '').trim();
        if (goal.isNotEmpty) _goal = goal;
        final diet = (data['diet'] as String? ?? '').trim();
        if (diet.isNotEmpty) _diet = diet;
        final photoUrl = (data['photoUrl'] as String? ?? '').trim();
        if (photoUrl.isNotEmpty) _photoUrl = photoUrl;
      });
    } catch (_) {}
  }

  Future<void> _uploadPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (picked == null || !mounted) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final url = await StorageService().uploadProfilePhoto(picked);
      if (url != null) {
        final uid = _authService.currentUser?.uid;
        if (uid != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .set({'photoUrl': url}, SetOptions(merge: true));
        }
        if (mounted) setState(() => _photoUrl = url);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not upload photo.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  Future<void> _editProfile() async {
    final nameController = TextEditingController(text: _name);
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
              onPressed: () async {
                final newName = nameController.text.trim();
                final newAllergens = allergensController.text.trim();
                final newGoal = goalController.text.trim();
                final newDiet = dietController.text.trim();

                final user = _authService.currentUser;
                if (user != null) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .set({
                      'displayName': newName,
                      'allergens': newAllergens,
                      'goal': newGoal,
                      'diet': newDiet,
                    }, SetOptions(merge: true));
                  } catch (_) {}
                }

                if (context.mounted) {
                  setState(() {
                    _name = newName.isEmpty ? 'NutriScan User' : newName;
                    _allergens = newAllergens;
                    _goal = newGoal;
                    _diet = newDiet;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    nameController.dispose();
    allergensController.dispose();
    goalController.dispose();
    dietController.dispose();
  }

  Future<void> _logout() async {
    await _authService.signOut();
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
          name: _name.isEmpty ? 'NutriScan User' : _name,
          email: _email,
          photoUrl: _photoUrl,
          isUploadingPhoto: _isUploadingPhoto,
          onEdit: _editProfile,
          onChangePhoto: _uploadPhoto,
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
        _ProfileSection(
          title: 'Account Status',
          rows: [
            const _ProfileRow(
              icon: Icons.cloud_done,
              label: 'Storage',
              value: 'Firebase Cloud',
            ),
            _ProfileRow(
              icon: Icons.image,
              label: 'Profile Picture',
              value: (_photoUrl != null && _photoUrl!.isNotEmpty)
                  ? 'Uploaded'
                  : 'Tap photo to upload',
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final bool isUploadingPhoto;
  final VoidCallback onEdit;
  final VoidCallback onChangePhoto;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.onEdit,
    required this.onChangePhoto,
    this.photoUrl,
    this.isUploadingPhoto = false,
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
            onTap: isUploadingPhoto ? null : onChangePhoto,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFDDF8E8),
                  backgroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
                      ? NetworkImage(photoUrl!)
                      : null,
                  child: (photoUrl == null || photoUrl!.isEmpty)
                      ? const Icon(Icons.person,
                          size: 42, color: Color(0xFF16A05D))
                      : null,
                ),
                if (isUploadingPhoto)
                  const Positioned.fill(
                    child: CircleAvatar(
                      backgroundColor: Colors.black45,
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                else
                  const Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 12,
                      backgroundColor: Color(0xFF16A05D),
                      child: Icon(Icons.camera_alt,
                          size: 14, color: Colors.white),
                    ),
                  ),
              ],
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
                  email,
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
