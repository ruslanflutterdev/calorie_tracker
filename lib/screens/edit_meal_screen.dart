import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/meal_model.dart';

class EditMealScreen extends StatefulWidget {
  final MealModel meal;

  const EditMealScreen({super.key, required this.meal});

  @override
  State<EditMealScreen> createState() => _EditMealScreenState();
}

class _EditMealScreenState extends State<EditMealScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _carbsController = TextEditingController();
  DateTime _selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.meal.description;
    _caloriesController.text = widget.meal.calories.toString();
    _proteinsController.text = widget.meal.proteins?.toString() ?? '';
    _fatsController.text = widget.meal.fats?.toString() ?? '';
    _carbsController.text = widget.meal.carbs?.toString() ?? '';
    _selectedDateTime = widget.meal.dateTime;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать прием пищи')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              TextFormField(
                controller: _proteinsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Белки (г)',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fatsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Жиры (г)',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _carbsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Углеводы (г)',
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    Navigator.pop(
                      context,
                      widget.meal.copyWith(
                        description: _descriptionController.text,
                        calories: int.parse(_caloriesController.text),
                        proteins:
                            _proteinsController.text.isNotEmpty
                                ? int.parse(_proteinsController.text)
                                : null,
                        fats:
                            _fatsController.text.isNotEmpty
                                ? int.parse(_fatsController.text)
                                : null,
                        carbs:
                            _carbsController.text.isNotEmpty
                                ? int.parse(_carbsController.text)
                                : null,
                        dateTime: _selectedDateTime,
                      ),
                    );
                  }
                },
                child: const Text('Сохранить изменения'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
