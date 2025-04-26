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
        meals.map((meal) {
          return {
            'description': meal.description,
            'dateTime': meal.dateTime.toIso8601String(),
            'calories': meal.calories,
          };
        }).toList();

    final json = jsonEncode(data);
    await _saveData('meals', json);
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

      final loadedMeals =
          data.map((meal) {
            return MealModel(
              description: meal['description'],
              dateTime: DateTime.parse(meal['dateTime']),
              calories: meal['calories'],
            );
          }).toList();

      return loadedMeals;
    } catch (err) {
      return [];
    }
  }
}
