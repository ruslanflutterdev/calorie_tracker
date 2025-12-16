import 'package:flutter/material.dart';
import '../utils/calorie_tracker_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _dailyCaloriesController = TextEditingController(
    text: '2000',
  );

  @override
  void initState() {
    super.initState();
    _loadDailyCalories();
  }

  Future<void> _loadDailyCalories() async {
    final calories = await CalorieTrackerStorage.loadDailyCalories();
    setState(() {
      _dailyCaloriesController.text = calories.toString();
    });
  }

  Future<void> _saveDailyCalories() async {
    final calories = int.tryParse(_dailyCaloriesController.text);
    if (calories != null && calories > 0) {
      await CalorieTrackerStorage.saveDailyCalories(calories);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Дневная норма калорий сохранена')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Пожалуйста, введите корректное значение калорий'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _dailyCaloriesController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Дневная норма калорий (ккал)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _saveDailyCalories,
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}
