import 'package:flutter/material.dart';

import '../models/diet_damage_model.dart';
import '../services/diet_damage_service.dart';

class DietDamageScreen extends StatefulWidget {
  const DietDamageScreen({super.key});

  @override
  State<DietDamageScreen> createState() => _DietDamageScreenState();
}

class _DietDamageScreenState extends State<DietDamageScreen> {
  final DietDamageService _service = DietDamageService();

  Future<void> _showAddDamageDialog() async {
    final titleController = TextEditingController();
    final caloriesController = TextEditingController();
    final reasonController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Diet Damage'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Ate fast food',
                    ),
                    validator: (value) {
                      if ((value ?? '').trim().isEmpty) {
                        return 'Enter a title.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Calories',
                      hintText: '500',
                    ),
                    validator: (value) {
                      final calories = int.tryParse(value ?? '');
                      if (calories == null || calories <= 0) {
                        return 'Enter calories.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: reasonController,
                    decoration: const InputDecoration(
                      labelText: 'Reason optional',
                      hintText: 'Cheat meal',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                try {
                  await _service.addDamageLog(
                    title: titleController.text.trim(),
                    calories: int.parse(caloriesController.text.trim()),
                    reason: reasonController.text.trim(),
                  );
                } catch (error) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Could not save damage log.'),
                    ),
                  );
                  return;
                }

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    caloriesController.dispose();
    reasonController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Diet Damage Tracker')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDamageDialog,
        backgroundColor: const Color(0xFF16A05D),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<DietDamageModel>>(
        stream: _service.getDamageLogs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Could not load damage logs.'));
          }

          final logs = snapshot.data ?? [];
          final activePoints = logs
              .where((log) => !log.recovered)
              .fold<int>(0, (total, log) => total + log.damagePoints);
          final recoveredPoints = logs
              .where((log) => log.recovered)
              .fold<int>(0, (total, log) => total + log.damagePoints);
          final totalPoints = activePoints + recoveredPoints;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _DamageSummaryCard(
                totalPoints: totalPoints,
                activePoints: activePoints,
                recoveredPoints: recoveredPoints,
              ),
              const SizedBox(height: 16),
              const _MotivationCard(),
              const SizedBox(height: 18),
              const Text(
                'Damage Logs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              if (logs.isEmpty)
                const _EmptyDamageState()
              else
                for (final log in logs)
                  _DamageLogTile(
                    log: log,
                    onRecover: () async {
                      await _service.recoverDamage(log.id);
                    },
                    onDelete: () async {
                      await _service.deleteDamage(log.id);
                    },
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _DamageSummaryCard extends StatelessWidget {
  final int totalPoints;
  final int activePoints;
  final int recoveredPoints;

  const _DamageSummaryCard({
    required this.totalPoints,
    required this.activePoints,
    required this.recoveredPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF073D25),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Damage',
            style: TextStyle(color: Color(0xFFCBEFDB)),
          ),
          Text(
            '$totalPoints points',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _SummaryPill(label: 'Active', value: activePoints),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SummaryPill(label: 'Recovered', value: recoveredPoints),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  final String label;
  final int value;

  const _SummaryPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFFCBEFDB))),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _MotivationCard extends StatelessWidget {
  const _MotivationCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            backgroundColor: Color(0xFFDDF8E8),
            child: Icon(Icons.favorite, color: Color(0xFF16A05D)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'One bad meal does not ruin progress. Recover this tomorrow and stay consistent.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DamageLogTile extends StatelessWidget {
  final DietDamageModel log;
  final VoidCallback onRecover;
  final VoidCallback onDelete;

  const _DamageLogTile({
    required this.log,
    required this.onRecover,
    required this.onDelete,
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
        leading: CircleAvatar(
          backgroundColor:
              log.recovered ? const Color(0xFFDDF8E8) : const Color(0xFFFFF2CC),
          child: Icon(
            log.recovered ? Icons.check : Icons.warning_amber,
            color: log.recovered
                ? const Color(0xFF16A05D)
                : const Color(0xFFE59D00),
          ),
        ),
        title: Text(log.title),
        subtitle: Text(
          '${log.calories} kcal - ${log.damagePoints} damage points'
          '${log.reason.isEmpty ? '' : '\n${log.reason}'}',
        ),
        isThreeLine: log.reason.isNotEmpty,
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'recover') onRecover();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => [
            if (!log.recovered)
              const PopupMenuItem(
                value: 'recover',
                child: Text('Mark recovered'),
              ),
            const PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyDamageState extends StatelessWidget {
  const _EmptyDamageState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        children: [
          Icon(Icons.track_changes, size: 72, color: Color(0xFF16A05D)),
          SizedBox(height: 14),
          Text(
            'No diet damage logged yet. Stay consistent.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
