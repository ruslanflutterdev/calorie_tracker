import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import '../models/meal_model.dart';
import '../utils/calorie_tracker_storage.dart';

class CaloriesScreen extends StatefulWidget {
  const CaloriesScreen({super.key});

  @override
  State<CaloriesScreen> createState() => _CaloriesScreenState();
}

class _CaloriesScreenState extends State<CaloriesScreen> {
  int _currentCalories = 0;
  int _dailyGoal = 2000;
  List<double> _weeklyCalories = [0, 0, 0, 0, 0, 0, 0];
  List<MealModel> _todayMeals = [];
  double _maxYWeeklyCalories = 3000;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru_RU', null);
    _loadDailyCalories();
    _loadWeeklyCalories();
    _loadTodayMeals();
  }

  Future<void> _loadDailyCalories() async {
    final calories = await CalorieTrackerStorage.loadDailyCalories();
    setState(() {
      _dailyGoal = calories;
    });
  }

  Future<void> _loadWeeklyCalories() async {
    final allMeals = await CalorieTrackerStorage.loadMeals();
    final now = DateTime.now();
    List<double> weeklyCalories = [];
    double maxCalories = 0;
    for (int i = 0; i < 7; i++) {
      final day = now.subtract(Duration(days: 6 - i));
      final startOfDay = DateTime(day.year, day.month, day.day, 0, 0, 0);
      final endOfDay = DateTime(day.year, day.month, day.day, 23, 59, 59);
      final dailyMeals = allMeals.where(
        (meal) =>
            meal.dateTime.isAfter(startOfDay) &&
            meal.dateTime.isBefore(endOfDay),
      );
      final dailyTotal =
          dailyMeals.fold(0, (sum, meal) => sum + meal.calories).toDouble();
      weeklyCalories.add(dailyTotal);
      if (dailyTotal > maxCalories) {
        maxCalories = dailyTotal;
      }
    }
    setState(() {
      _weeklyCalories = weeklyCalories;
      _maxYWeeklyCalories = maxCalories > 0 ? maxCalories * 1.3 : 3500;
    });
  }

  Future<void> _loadTodayMeals() async {
    final allMeals = await CalorieTrackerStorage.loadMeals();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    setState(() {
      _todayMeals =
          allMeals
              .where(
                (meal) =>
                    meal.dateTime.year == today.year &&
                    meal.dateTime.month == today.month &&
                    meal.dateTime.day == today.day,
              )
              .toList();
      _currentCalories = _todayMeals.fold(
        0,
        (sum, meal) => sum + meal.calories,
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    final double progress = _currentCalories / _dailyGoal;
    final bool isOverLimit = _currentCalories > _dailyGoal;
    final now = DateTime.now();
    final weekDays = List.generate(
      7,
      (index) => now.subtract(Duration(days: 6 - index)),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              '$_currentCalories / $_dailyGoal ккал',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16.0),
          Stack(
            children: [
              Container(
                height: 24.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.grey[300],
                ),
              ),
              FractionallySizedBox(
                widthFactor: isOverLimit ? 1.0 : progress.clamp(0.0, 1.0),
                child: Container(
                  height: 24.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    color: isOverLimit ? Colors.redAccent : Colors.green,
                  ),
                ),
              ),
              if (isOverLimit)
                Positioned(
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 24.0,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '+${_currentCalories - _dailyGoal} ккал',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 32.0),
          Text(
            'Потребление за неделю',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            DateFormat(
                              'E',
                              'ru_RU',
                            ).format(weekDays[value.toInt() % 7]),
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final weeklyCalorie =
                            _weeklyCalories[value.toInt() % 7].toInt();
                        return weeklyCalorie > 0
                            ? Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                weeklyCalorie.toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                            : const SizedBox.shrink();
                      },
                      reservedSize: 20,
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups:
                    _weeklyCalories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final value = entry.value;
                      return BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: value,
                            color: Colors.deepPurpleAccent,
                            width: 18,
                            borderRadius: const BorderRadius.all(
                              Radius.circular(6),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    tooltipMargin: 8,
                    tooltipPadding: const EdgeInsets.all(8),
                    tooltipBorder: const BorderSide(color: Colors.blueGrey),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${_weeklyCalories[groupIndex].toInt()} ккал',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                maxY: _maxYWeeklyCalories,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
