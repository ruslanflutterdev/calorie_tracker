import 'package:flutter/material.dart';

class DestinationModel {
  final String title;
  final List<Widget> action;
  final Widget screen;
  final IconData icon;
  final String label;
  final IconData selectedIcon;

  DestinationModel({
    required this.title,
    required this.action,
    required this.screen,
    required this.icon,
    required this.label,
    required this.selectedIcon,
  });
}
