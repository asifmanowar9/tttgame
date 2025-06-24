import 'package:flutter/material.dart';
import 'screens/game_mode_screen.dart';
import 'theme/app_theme.dart';

void main() {
  // Ensure proper initialization
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: AppTheme.getTheme(),
      debugShowCheckedModeBanner: false,
      home: const GameModeScreen(),
    );
  }
}
