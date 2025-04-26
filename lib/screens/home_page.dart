import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import 'history_page.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  late List<DestinationModel> destinations = [
    DestinationModel(
      title: 'Home Screen',
      action: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
        IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
      ],
      screen: HomePage(),
      icon: Icons.task,
      label: 'Home Screen',
      selectedIcon: Icons.home,
    ),
    DestinationModel(
      title: 'History Page',
      action: [],
      screen: const HistoryPage(),
      icon: Icons.history_edu,
      label: 'History Page',

      selectedIcon: Icons.history_edu,
    ),
    DestinationModel(
      title: 'Settings Page',
      action: [],
      screen: const SettingsPage(),
      icon: Icons.history_edu,
      label: 'Settings Page',
      selectedIcon: Icons.history_edu,
    ),
  ];

  void onSelectedDestination(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentDestination =
    destinations[selectedIndex];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          currentDestination.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.green,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions:
        currentDestination
            .action,
      ),
      body: currentDestination.screen,
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          onSelectedDestination(
            index,
          );
        },
        selectedIndex: selectedIndex,
        destinations:
        destinations.map((element) {
          return NavigationDestination(
            icon: Icon(element.icon),
            label: element.label,
            selectedIcon: Icon(
              element.selectedIcon,
            ),
          );
        }).toList(),
      ),
    );
  }
}
