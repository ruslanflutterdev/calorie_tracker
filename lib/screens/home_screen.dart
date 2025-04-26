import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import 'calories_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPageIndex = 0;

  final List<DestinationModel> destinations = [
    DestinationModel(
      title: 'Home Page',
      action: [],
      screen: const CaloriesPage(),
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
      screen: SettingsPage(),
      icon: Icons.settings_outlined,
      label: 'Settings',
      selectedIcon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final DestinationModel currentDestination = destinations[_currentPageIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(currentDestination.title),
        actions: currentDestination.action,
      ),
      body: currentDestination.screen,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentPageIndex = index;
          });
        },
        destinations: destinations.map((DestinationModel destination) {
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
