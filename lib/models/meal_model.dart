class MealModel {
  String description;
  DateTime dateTime;
  int calories;

  MealModel({
    required this.description,
    required this.dateTime,
    required this.calories,
  });

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'calories': calories,
    };
  }

  static MealModel fromMap(Map<String, dynamic> map) {
    return MealModel(
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
      calories: map['calories'],
    );
  }
}
