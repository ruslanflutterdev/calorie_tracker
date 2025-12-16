import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/meal_model.dart';

class CalorieTrackerStorage {
  static Future<String> _getApplicationDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<void> saveMeals(List<MealModel> meals) async {
    final List<Map<String, dynamic>> data =
        meals.map((meal) => meal.toMap()).toList();
    final json = jsonEncode(data);
    await _saveData('meals', json);
    //mealsNotifier.value = meals;
  }

  static Future<void> saveDailyCalories(int calories) async {
    await _saveData('daily_calories', calories.toString());
  }

  static Future<int> loadDailyCalories() async {
    try {
      final dirPath = await _getApplicationDirectory();
      final filePath = '$dirPath/daily_calories.json';
      final file = File(filePath);
      final data = await file.readAsString();
      return int.parse(data);
    } catch (err) {
      return 2000;
    }
  }

  static Future<void> _saveData(String fileName, String data) async {
    final dirPath = await _getApplicationDirectory();
    final filePath = '$dirPath/$fileName.json';
    final file = File(filePath);
    await file.writeAsString(data);

  }

  static Future<List<MealModel>> loadMeals() async {
    try {
      final dirPath = await _getApplicationDirectory();
      final filePath = '$dirPath/meals.json';
      final file = File(filePath);
      final json = await file.readAsString();
      final List<dynamic> data = jsonDecode(json);
      final _ = data.map((meal) => MealModel.fromMap(meal)).toList();
      //mealsNotifier.value = meals;
      return data.map((meal) => MealModel.fromMap(meal)).toList();
    } catch (err) {
      //mealsNotifier.value = [];
      return [];
    }
  }
}
