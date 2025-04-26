import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/destination_model.dart';
import '../models/meal_model.dart';
import '../utils/calorie_tracker_storage.dart';
import 'calories_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 0;

  final List<DestinationModel> destinations = [
    DestinationModel(
      title: 'Home Page',
      action: [],
      screen: const CaloriesScreen(),
      icon: Icons.home_outlined,
      label: 'Home',
      selectedIcon: Icons.home,
    ),
    DestinationModel(
      title: 'History Page',
      action: [],
      screen: HistoryScreen(),
      icon: Icons.history_edu_rounded,
      label: 'History',
      selectedIcon: Icons.history_edu,
    ),
    DestinationModel(
      title: 'Settings Page',
      action: [],
      screen: SettingsScreen(),
      icon: Icons.settings_outlined,
      label: 'Settings',
      selectedIcon: Icons.settings,
    ),
  ];

  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveMeal() async {
    if (_formKey.currentState!.validate()) {
      final description = _descriptionController.text;
      final calories = int.parse(_caloriesController.text);

      final newMeal = MealModel(
        description: description,
        dateTime: _selectedDateTime,
        calories: calories,
      );

      final List<MealModel> existingMeals =
          await CalorieTrackerStorage.loadMeals();
      existingMeals.add(newMeal);
      await CalorieTrackerStorage.saveMeals(existingMeals);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Прием пищи добавлен')));

      _descriptionController.clear();
      _caloriesController.clear();
      setState(() {
        _selectedDateTime = DateTime.now();
      });
      Navigator.pop(context);
    }
  }

  void _showAddMealBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext bc) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Добавить прием пищи',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => _selectDateTime(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Дата и время приема пищи',
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat(
                              'dd.MM.yyyy HH:mm',
                            ).format(_selectedDateTime),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Описание',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите описание приема пищи';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _caloriesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Калории',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Пожалуйста, введите количество калорий';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Пожалуйста, введите числовое значение';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _saveMeal,
                    child: const Text('Сохранить прием пищи'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final DestinationModel currentDestination = destinations[_currentPageIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentDestination.title),
        actions: [
          if (_currentPageIndex == 0)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddMealBottomSheet(context),
            ),
          ...currentDestination.action,
        ],
      ),
      body: currentDestination.screen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        destinations:
            destinations.map((DestinationModel destination) {
              return NavigationDestination(
                icon: Icon(destination.icon),
                selectedIcon: Icon(destination.selectedIcon),
                label: destination.label,
              );
            }).toList(),
      ),
    );
  }
}
