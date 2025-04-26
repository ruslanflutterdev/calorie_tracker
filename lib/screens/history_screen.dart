import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal_model.dart';
import '../utils/calorie_tracker_storage.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<MealModel> _meals = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final meals = await CalorieTrackerStorage.loadMeals();
    setState(() {
      _meals = meals;
    });
  }

  Future<void> _deleteMeal(int index) async {
    setState(() {
      _meals.removeAt(index);
    });
    await CalorieTrackerStorage.saveMeals(_meals);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История приемов пищи')),
      body:
          _meals.isEmpty
              ? const Center(child: Text('Нет данных'))
              : ListView.builder(
                itemCount: _meals.length,
                itemBuilder: (context, index) {
                  final meal = _meals[index];
                  return Dismissible(
                    key: UniqueKey(),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) => _deleteMeal(index),
                    child: ListTile(
                      title: Text(meal.description),
                      subtitle: Text(
                        '${DateFormat('dd.MM.yyyy HH:mm').format(meal.dateTime)} - ${meal.calories} ккал',
                      ),
                    ),
                  );
                },
              ),
    );
  }
}
