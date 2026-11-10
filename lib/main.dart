import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

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
      title: 'EFootball Clone Hub',
      theme: AppTheme.sportyTheme,
      home: const DashboardScreen(),
    );
  }
}
