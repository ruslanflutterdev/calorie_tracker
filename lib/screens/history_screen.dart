import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/meal_model.dart';
import '../utils/calorie_tracker_storage.dart';
import 'edit_meal_screen.dart';

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

  Future<void> _editMeal(
    BuildContext context,
    int index,
    MealModel meal,
  ) async {
    final updatedMeal = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditMealScreen(meal: meal)),
    );

    if (updatedMeal != null) {
      setState(() {
        _meals[index] = updatedMeal;
      });
      await CalorieTrackerStorage.saveMeals(_meals);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _meals.isEmpty
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
                  '${DateFormat('dd.MM.yyyy HH:mm').format(meal.dateTime)} - ${meal.calories} ккал'
                  '${meal.proteins != null ? ' - Белки: ${meal.proteins}г' : ''}'
                  '${meal.fats != null ? ' - Жиры: ${meal.fats}г' : ''}'
                  '${meal.carbs != null ? ' - Углеводы: ${meal.carbs}г' : ''}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editMeal(context, index, meal),
                ),
              ),
            );
          },
        );
  }
}
