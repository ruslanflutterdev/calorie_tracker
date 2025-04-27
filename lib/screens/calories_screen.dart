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
  int _totalProteins = 0;
  int _totalFats = 0;
  int _totalCarbs = 0;
  String _selectedRange = 'День';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('ru_RU', null);
    _loadDailyCalories();
    _loadWeeklyCalories();
    _loadMealsForRange();
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

  Future<void> _loadMealsForRange() async {
    final allMeals = await CalorieTrackerStorage.loadMeals();
    DateTime start, end;
    final now = DateTime.now();

    switch (_selectedRange) {
      case 'День':
        start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'Неделя':
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day, 0, 0, 0);
        end = now.add(Duration(days: 7 - now.weekday));
        end = DateTime(end.year, end.month, end.day, 23, 59, 59);
        break;
      case 'Месяц':
        start = DateTime(now.year, now.month, 1, 0, 0, 0);
        end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'Интервал':
        if (_startDate != null && _endDate != null) {
          start = DateTime(
            _startDate!.year,
            _startDate!.month,
            _startDate!.day,
            0,
            0,
            0,
          );
          end = DateTime(
            _endDate!.year,
            _endDate!.month,
            _endDate!.day,
            23,
            59,
            59,
          );
        } else {
          start = DateTime.now();
          end = DateTime.now();
        }
        break;
      default:
        start = DateTime.now();
        end = DateTime.now();
    }

    final filteredMeals = allMeals.where(
      (meal) =>
          meal.dateTime.isAfter(
            start.subtract(const Duration(milliseconds: 1)),
          ) &&
          meal.dateTime.isBefore(end.add(const Duration(milliseconds: 1))),
    );

    setState(() {
      _todayMeals = filteredMeals.toList();
      _currentCalories = _todayMeals.fold(
        0,
        (sum, meal) => sum + meal.calories,
      );
      _totalProteins = _todayMeals.fold(
        0,
        (sum, meal) => sum + (meal.proteins ?? 0),
      );
      _totalFats = _todayMeals.fold(0, (sum, meal) => sum + (meal.fats ?? 0));
      _totalCarbs = _todayMeals.fold(0, (sum, meal) => sum + (meal.carbs ?? 0));
    });
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(
        start: _startDate ?? DateTime.now().subtract(const Duration(days: 7)),
        end: _endDate ?? DateTime.now(),
      ),
    );

    if (picked != null &&
        picked !=
            DateTimeRange(
              start:
                  _startDate ??
                  DateTime.now().subtract(const Duration(days: 7)),
              end: _endDate ?? DateTime.now(),
            )) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _selectedRange = 'Интервал';
      });
      _loadMealsForRange();
    }
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
          const SizedBox(height: 32.0),
          Text(
            'Соотношение нутриентов (${_selectedRange})',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              DropdownButton<String>(
                value: _selectedRange,
                items:
                    <String>['День', 'Неделя', 'Месяц', 'Интервал'].map((
                      String value,
                    ) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRange = newValue!;
                    if (_selectedRange != 'Интервал') {
                      _startDate = null;
                      _endDate = null;
                    }
                  });
                  _loadMealsForRange();
                },
              ),
              if (_selectedRange == 'Интервал')
                ElevatedButton(
                  onPressed: _selectDateRange,
                  child: const Text('Выбрать даты'),
                ),
            ],
          ),
          const SizedBox(height: 16.0),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 5,
                centerSpaceRadius: 40,
                sections: _generateNutrientData(),
                borderData: FlBorderData(show: false),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        return;
                      }
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutrientIndicator(Colors.blue, 'Белки: ${_totalProteins}г'),
              _buildNutrientIndicator(Colors.green, 'Жиры: ${_totalFats}г'),
              _buildNutrientIndicator(
                Colors.orange,
                'Углеводы: ${_totalCarbs}г',
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _generateNutrientData() {
    final totalNutrients = _totalProteins + _totalFats + _totalCarbs;
    List<PieChartSectionData> list = [];

    if (totalNutrients > 0) {
      list.add(
        PieChartSectionData(
          value: _totalProteins.toDouble(),
          color: Colors.blue,
          title:
              '${(_totalProteins / totalNutrients * 100).toStringAsFixed(1)}%',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      list.add(
        PieChartSectionData(
          value: _totalFats.toDouble(),
          color: Colors.green,
          title: '${(_totalFats / totalNutrients * 100).toStringAsFixed(1)}%',
          radius: 45,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
      list.add(
        PieChartSectionData(
          value: _totalCarbs.toDouble(),
          color: Colors.orange,
          title: '${(_totalCarbs / totalNutrients * 100).toStringAsFixed(1)}%',
          radius: 40,
          titleStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    } else {
      list.add(
        PieChartSectionData(
          value: 1,
          color: Colors.grey[300]!,
          title: 'Нет данных',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
    }

    return list;
  }

  Widget _buildNutrientIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
