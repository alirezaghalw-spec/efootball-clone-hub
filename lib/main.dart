import 'package:flutter/material.dart';
import 'package:efootball_clone_hub/core/constants/app_constants.dart';
import 'package:efootball_clone_hub/core/theme/app_theme.dart';
import 'package:efootball_clone_hub/screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const EFootballCloneApp());
}

class EFootballCloneApp extends StatelessWidget {
  const EFootballCloneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.sportyTheme,
      home: const DashboardScreen(),
    );
  }
}
