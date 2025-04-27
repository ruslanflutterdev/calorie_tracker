class MealModel {
  String description;
  DateTime dateTime;
  int calories;
  int? proteins;
  int? fats;
  int? carbs;

  MealModel({
    required this.description,
    required this.dateTime,
    required this.calories,
    this.proteins,
    this.fats,
    this.carbs,
  });

  MealModel copyWith({
    String? description,
    DateTime? dateTime,
    int? calories,
    int? proteins,
    int? fats,
    int? carbs,
  }) {
    return MealModel(
      description: description ?? this.description,
      dateTime: dateTime ?? this.dateTime,
      calories: calories ?? this.calories,
      proteins: proteins ?? this.proteins,
      fats: fats ?? this.fats,
      carbs: carbs ?? this.carbs,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'dateTime': dateTime.toIso8601String(),
      'calories': calories,
      'proteins': proteins,
      'fats': fats,
      'carbs': carbs,
    };
  }

  static MealModel fromMap(Map<String, dynamic> map) {
    return MealModel(
      description: map['description'],
      dateTime: DateTime.parse(map['dateTime']),
      calories: map['calories'],
      proteins: map['proteins'],
      fats: map['fats'],
      carbs: map['carbs'],
    );
  }
}
