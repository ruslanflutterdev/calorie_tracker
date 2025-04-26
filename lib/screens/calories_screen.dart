import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
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
  final List<double> _weeklyCalories = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
  ];
  List<MealModel> _todayMeals = [];

  @override
  void initState() {
    super.initState();
    _loadDailyCalories();
    _loadTodayMeals();

  }

  Future<void> _loadDailyCalories() async {
    final calories = await CalorieTrackerStorage.loadDailyCalories();
    setState(() {
      _dailyGoal = calories;
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

  void _incrementCalories() {
    setState(() {
      _currentCalories += 250;
      if (_currentCalories > _dailyGoal * 2) {
        _currentCalories = _dailyGoal * 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double progress = _currentCalories / _dailyGoal;
    final bool isOverLimit = _currentCalories > _dailyGoal;

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
            height: 220,
            child: BarChart(
              BarChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final weekDays = [
                          'Пн',
                          'Вт',
                          'Ср',
                          'Чт',
                          'Пт',
                          'Сб',
                          'Вс',
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            weekDays[value.toInt() % 7],
                            style: const TextStyle(fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
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
              ),
            ),
          ),
          const SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: _incrementCalories,
            child: const Text('Увеличить калории на 250'),
          ),
        ],
      ),
    );
  }
}
