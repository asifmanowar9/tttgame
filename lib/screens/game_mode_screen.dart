import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'side_selection_screen.dart';

class GameModeScreen extends StatelessWidget {
  const GameModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.gradientStart,
              AppTheme.gradientEnd,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // OX logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCircle(),
                    const SizedBox(width: 10),
                    _buildCross(),
                  ],
                ),
                const SizedBox(height: 40),
                
                const Text(
                  'Choose a play mode',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // With AI button
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SideSelectionScreen(isAI: true),
                        ),
                      );
                    },
                    child: const Text('With AI'),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // With a friend button
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SideSelectionScreen(isAI: false),
                        ),
                      );
                    },
                    child: const Text('With a friend'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircle() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 10),
      ),
    );
  }

  Widget _buildCross() {
    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        children: [
          Positioned(
            top: 28,
            child: Transform.rotate(
              angle: 45 * 3.14159 / 180,
              child: Container(
                width: 60,
                height: 10,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 28,
            child: Transform.rotate(
              angle: -45 * 3.14159 / 180,
              child: Container(
                width: 60,
                height: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}