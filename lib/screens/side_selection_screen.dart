import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'game_board_screen.dart';

class SideSelectionScreen extends StatelessWidget {
  final bool isAI;
  
  const SideSelectionScreen({super.key, required this.isAI});

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
                const Text(
                  'Choose a side',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // Circle button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameBoardScreen(
                          isAI: isAI,
                          playerSymbol: 'O',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 10),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Cross button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameBoardScreen(
                          isAI: isAI,
                          playerSymbol: 'X',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: _buildCross(size: 70, thickness: 15, color: AppTheme.primaryColor),
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Start game button
                SizedBox(
                  width: 220,
                  child: ElevatedButton(
                    onPressed: () {
                      // Default to X if they don't select
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GameBoardScreen(
                            isAI: isAI,
                            playerSymbol: 'X',
                          ),
                        ),
                      );
                    },
                    child: const Text('Start game'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCross({required double size, required double thickness, required Color color}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned(
            top: (size - thickness) / 2,
            child: Transform.rotate(
              angle: 45 * 3.14159 / 180,
              child: Container(
                width: size,
                height: thickness,
                color: color,
              ),
            ),
          ),
          Positioned(
            top: (size - thickness) / 2,
            child: Transform.rotate(
              angle: -45 * 3.14159 / 180,
              child: Container(
                width: size,
                height: thickness,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}