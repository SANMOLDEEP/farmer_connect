import 'package:flutter/material.dart';
import '../main.dart';

// This is just a wrapper to use the existing HomeScreen
class HomeScreenWrapper extends StatelessWidget {
  const HomeScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return const HomeScreen();
  }
}